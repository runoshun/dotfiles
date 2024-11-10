interface ForwardingRequest {
	localPort: number;
	remotePort: number;
}

class SSHForwardingManager {
	private processes: Map<string, Deno.ChildProcess> = new Map();

	constructor(
		private remoteHost: string,
		private controlPath: string,
	) {}

	startForwarding(request: ForwardingRequest): void {
		const key = `${request.localPort}:${request.remotePort}`;

		// すでに同じ転送が存在する場合は何もしない
		if (this.processes.has(key)) {
			return;
		}
		const args = [
			"-o",
			`ControlPath=${this.controlPath}`,
			"-NL",
			`${request.localPort}:localhost:${request.remotePort}`,
			this.remoteHost,
		];
		const sshProcess = new Deno.Command("ssh", { args: args }).spawn();

		this.processes.set(key, sshProcess);
		sshProcess.status.then((_status) => {
			this.processes.delete(key);
		});
	}

	stopForwarding(remotePort: number): void {
		const pat = `:${remotePort}`;
		for (const [key, process] of this.processes) {
			if (key.endsWith(pat)) {
				process.kill("SIGTERM");
				this.processes.delete(key);
			}
		}
	}

	stopAll(): void {
		for (const [key, process] of this.processes) {
			process.kill("SIGTERM");
			console.log(`Stopped forwarding for ${key}`);
		}
		this.processes.clear();
	}
}

export class SSHForwardingServer {
	private manager: SSHForwardingManager;
	private serverPort: number;

	constructor({
		remoteHost,
		controlPath,
		serverPort,
	}: {
		remoteHost: string;
		controlPath: string;
		serverPort: number;
	}) {
		this.manager = new SSHForwardingManager(remoteHost, controlPath);
		this.serverPort = serverPort;
	}

	start() {
		Deno.serve({ port: this.serverPort }, async (request) => {
			if (request.method === "POST") {
				try {
					const body: ForwardingRequest = await request.json();
					this.manager.startForwarding(body);
					return new Response("Forwarding started", { status: 200 });
				} catch (error) {
					console.error("Error processing request:", error);
					return new Response("Invalid request", { status: 400 });
				}
			} else if (request.method === "DELETE") {
				const url = new URL(request.url);
				const remotePort = url.searchParams.get("remotePort");

				if (remotePort) {
					this.manager.stopForwarding(parseInt(remotePort));
					return new Response("Forwarding stopped", { status: 200 });
				}
				return new Response("Invalid request", { status: 400 });
			}

			return new Response("Method not allowed", { status: 405 });
		});
	}

	stop() {
		this.manager.stopAll();
	}
}
