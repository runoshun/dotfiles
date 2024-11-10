import * as log from "jsr:@std/log";

import { SSHForwardingServer } from "./lib/ssh_forwarding.ts";
import { Bundler } from "./lib/bundler.ts";

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

const LOCAL_FORWARDING_PORT = 19876;
const SSH_MASTER_CONTROL_PATH = `/tmp/ssh_mux_%h_%p_%r`;

if (Deno.args.length !== 1) {
	console.error("Usage: deno run main.ts <remote-host>");
	Deno.exit(1);
}

const remoteHost = Deno.args[0];

// Start local SSH forwarding server
const forwardingServer = new SSHForwardingServer({
	serverPort: LOCAL_FORWARDING_PORT,
	controlPath: SSH_MASTER_CONTROL_PATH,
	remoteHost: remoteHost,
});
forwardingServer.start();

// Establish SSH connection and Start remote port watcher server
const remoteServerProcess = new Deno.Command("ssh", {
	args: [
		remoteHost,
		"-o",
		"ControlMaster=auto",
		"-o",
		"ControlPersist=10s",
		"-o",
		`ControlPath=${SSH_MASTER_CONTROL_PATH}`,
		"-R",
		`${LOCAL_FORWARDING_PORT}:localhost:${LOCAL_FORWARDING_PORT}`,
		`cat > /tmp/portfowarding.ts && ~/.local/share/mise/shims/deno run -A /tmp/portfowarding.ts 'http://localhost:${LOCAL_FORWARDING_PORT}'`,
	],
	stdin: "piped",
}).spawn();

// Bundle server codes
const bundler = new Bundler();
const remoteServerCode = await bundler.bundle(
	import.meta.resolve("./agent_ssh.ts"),
);
const dockerServerCode = await bundler.bundle(
	import.meta.resolve("./agent_docker.ts"),
);

// Combine both server codes with a separator
const combinedCode = `
// Docker server code
const dockerServerCode = ${JSON.stringify(dockerServerCode)};

// Remote server code
${remoteServerCode}
`;

// Send the combined code to remote server
if (remoteServerProcess.stdin) {
	const writer = remoteServerProcess.stdin.getWriter();
	await writer.write(new TextEncoder().encode(combinedCode));
	await writer.close();
}

// Cleanup on exit
const cleanup = () => {
	forwardingServer.stop();
	remoteServerProcess.kill("SIGTERM");
	Deno.exit();
};

Deno.addSignalListener("SIGINT", cleanup);
Deno.addSignalListener("SIGTERM", cleanup);
