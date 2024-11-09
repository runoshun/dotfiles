import { exists } from "jsr:@std/fs";
import * as log from "jsr:@std/log";
import { parseArgs } from "jsr:@std/cli";

log.setup({
	handlers: {
		default: new log.ConsoleHandler("DEBUG", {
			formatter: log.formatters.jsonFormatter,
			useColors: false,
		}),
	},
	loggers: {
		default: {
			level: "INFO",
			handlers: ["default"],
		},
	},
});

type GithubToken = {
	expires_at: number;
	token: string;
	endpoints: Record<string, string>;
};

let _oauth_token: string | undefined;
let _github_token: GithubToken | undefined;

async function findConfigPath(): Promise<string | undefined> {
	const tokenPath = Deno.env.get("CODECOMPANION_TOKEN_PATH");
	if (tokenPath) {
		return tokenPath;
	}

	const config = Deno.env.get("XDG_CONFIG_HOME");
	if (config && (await exists(config))) {
		return config;
	} else if (Deno.build.os === "windows") {
		const winConfig = Deno.env.get("LOCALAPPDATA");
		if (winConfig && (await exists(winConfig))) {
			return winConfig;
		}
	} else {
		const homeConfig = `${Deno.env.get("HOME")}/.config`;
		if (await exists(homeConfig)) {
			return homeConfig;
		}
	}
}

async function getGithubToken(): Promise<string | undefined> {
	if (_oauth_token) {
		return _oauth_token;
	}

	const token = Deno.env.get("GITHUB_TOKEN");
	const codespaces = Deno.env.get("CODESPACES");
	if (token && codespaces) {
		return token;
	}

	const configPath = await findConfigPath();
	if (!configPath) {
		return undefined;
	}

	const filePaths = [
		`${configPath}/github-copilot/hosts.json`,
		`${configPath}/github-copilot/apps.json`,
	];

	for (const filePath of filePaths) {
		log.debug(`Checking file: ${filePath}`);
		if (await exists(filePath)) {
			const userdata = JSON.parse(await Deno.readTextFile(filePath));
			for (const key in userdata) {
				if (key.includes("github.com")) {
					return userdata[key].oauth_token;
				}
			}
		}
	}
	return undefined;
}

async function authorizeToken(): Promise<GithubToken | undefined> {
	if (_github_token && _github_token.expires_at > Date.now() / 1000) {
		log.debug("Reusing GitHub Copilot token");
		return _github_token;
	}

	log.debug("Authorizing GitHub Copilot token");

	_oauth_token = await getGithubToken();
	const response = await fetch(
		"https://api.github.com/copilot_internal/v2/token",
		{
			headers: {
				Authorization: `Bearer ${_oauth_token}`,
				Accept: "application/json",
			},
		},
	);

	if (response.status !== 200) {
		log.error(`Copilot Adapter: Token request error ${response.statusText}`);
		return undefined;
	}

	_github_token = await response.json();
	return _github_token;
}

async function handler(req: Request): Promise<Response> {
	log.debug(
		`Request: ${req.method} ${req.url} headers: ${JSON.stringify(req.headers)}`,
	);
	const parsedUrl = new URL(req.url);
	if (parsedUrl.pathname === "/echo") {
		return new Response("Echo", { status: 200 });
	}
	if (parsedUrl.pathname !== "/chat/completions") {
		return new Response("Not Found", { status: 404 });
	}

	try {
		const token = await authorizeToken();
		if (!token?.token) {
			return new Response("Failed to authorize token", { status: 500 });
		}

		const res = await fetch(`${token.endpoints.api}${parsedUrl.pathname}`, {
			method: req.method,
			headers: {
				"content-length": req.headers.get("content-length") || "",
				"content-type": req.headers.get("content-type") || "",
				accept: req.headers.get("accept") || "",
				connection: "keep-alive",
				Host: new URL(token.endpoints.api).host,
				Authorization: `Bearer ${token.token}`,
				"Copilot-Integration-Id": "vscode-chat",
				"editor-version": "Neovim/0.10.1",
				"User-Agent": "curl/8.6.0",
			},
			body: req.body,
		});
		if (!res.ok || res.status !== 200) {
			log.error(`Failed to fetch completions: ${res.status} ${res.statusText}`);
			return new Response("Internal Server Error", { status: 500 });
		}

		//const decoder = new TextDecoder();
		const body = new ReadableStream({
			async start(controller) {
				const reader = res.body?.getReader();
				if (!reader) {
					controller.error(new Error("Failed to get response body reader"));
					return;
				}

				while (true) {
					const { done, value } = await reader.read();
					if (done) {
						log.debug("done");
						controller.close();
						break;
					}
					//log.debug(`enqueue: ${decoder.decode(value)}`);
					controller.enqueue(value);
				}
			},
			cancel() {},
		});

		return new Response(body, {
			headers: res.headers,
		});
	} catch (e) {
		log.error(`Error: ${e}`);
		return new Response("Internal Server Error", { status: 500 });
	}
}

function generateAiderConfig() {
	const modelMetadata = {
		"openai/claude-3.5-sonnet": {
			max_tokens: 8192,
			max_input_tokens: 200000,
			max_output_tokens: 8192,
			input_cost_per_token: 0.000003,
			output_cost_per_token: 0.000015,
			cache_creation_input_token_cost: 0.00000375,
			cache_read_input_token_cost: 0.0000003,
			litellm_provider: "openai",
			mode: "chat",
			supports_function_calling: true,
			supports_vision: true,
			tool_use_system_prompt_tokens: 159,
			supports_assistant_prefill: true,
			supports_prompt_caching: true,
		},
	};
	const modelSettings = `
- cache_control: true
  caches_by_default: false
  edit_format: diff
  editor_edit_format: editor-diff
  editor_model_name: openai/claude-3.5-sonnet
  examples_as_sys_msg: true
  lazy: false
  name: openai/claude-3.5-sonnet
  reminder: user
  send_undo_reply: false
  streaming: true
  use_repo_map: true
  use_system_prompt: true
  use_temperature: true
  weak_model_name: openai/gpt-4o-mini-2024-07-18
`;
	const aiderEnv = `
OPENAI_API_BASE=http://localhost:8001
OPENAI_API_KEY=dummy

AIDER_MODEL="openai/claude-3.5-sonnet"
AIDER_DARK_MODE=true
`;

	const home = Deno.env.get("HOME");
	Deno.writeTextFileSync(`${home}/.aider.model.settings.yml`, modelSettings);
	Deno.writeTextFileSync(
		`${home}/.aider.model.metadata.json`,
		JSON.stringify(modelMetadata, null, 2),
	);
	Deno.writeTextFileSync(`${home}/.aider.env`, aiderEnv);
}

function main() {
	const flags = parseArgs(Deno.args, {
		boolean: ["help"],
	});

	if (flags.help || Deno.args.length === 0) {
		console.log(`Usage:
  start         - Start the Copilot proxy server
  gen aider     - Generate aider configuration
  help          - Show this help message`);
		Deno.exit(0);
	}

	const args = flags._;
	const command = args[0];

	switch (command) {
		case "start":
			Deno.serve({
				port: 8001,
				hostname: "127.0.0.1",
				handler: handler,
			});
			break;
		case "gen":
			if (args[1] === "aider") {
				generateAiderConfig();
			} else {
				console.error("Unknown gen command. Available: aider");
				Deno.exit(1);
			}
			break;
		default:
			console.error(`Unknown command: ${command}`);
			Deno.exit(1);
	}
}

main();
