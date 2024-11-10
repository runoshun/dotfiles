interface ForwardingRequest {
	localPort: number;
	remoteHost: string;
	remotePort: number;
}

class SSHForwardingManager {
	private processes: Map<string, Deno.ChildProcess> = new Map();

	startForwarding(request: ForwardingRequest): void {
		const key = `${request.remoteHost}:${request.remotePort}`;

		// すでに同じ転送が存在する場合は何もしない
		if (this.processes.has(key)) {
			return;
		}

		const sshProcess = new Deno.Command("ssh", {
			args: [
				"-NR",
				`${request.localPort}:localhost:${request.remotePort}`,
				request.remoteHost,
			],
		}).spawn();

		this.processes.set(key, sshProcess);

		// プロセスが終了した場合の処理
		sshProcess.status.then((status) => {
			console.log(`SSH process for ${key} exited with status: ${status.code}`);
			this.processes.delete(key);
		});
	}

	stopForwarding(remoteHost: string, remotePort: number): void {
		const key = `${remoteHost}:${remotePort}`;
		const process = this.processes.get(key);
		if (process) {
			process.kill("SIGTERM");
			this.processes.delete(key);
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
	private manager = new SSHForwardingManager();

	start(port: number) {
		console.log(`Starting SSH forwarding server on port ${port}`);

		Deno.serve({ port }, async (request) => {
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
				const remoteHost = url.searchParams.get("host");
				const remotePort = url.searchParams.get("port");

				if (remoteHost && remotePort) {
					this.manager.stopForwarding(remoteHost, parseInt(remotePort));
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
