import { PortWatcher } from "./lib/port_watcher.ts";

if (Deno.args.length !== 1) {
	console.error("Usage: deno run remote_server.ts <forward-url>");
	Deno.exit(1);
}

const forwardUrl = Deno.args[0];

// Watch for new ports
const watcher = new PortWatcher(
	async (port: number) => {
		console.log(`New port detected: ${port}`);

		try {
			await fetch(forwardUrl, {
				method: "POST",
				headers: {
					"Content-Type": "application/json",
				},
				body: JSON.stringify({
					localPort: port,
					remoteHost: "localhost",
					remotePort: port,
				}),
			});
		} catch (error) {
			console.error("Failed to send forwarding request:", error);
		}
	},
	async (port: number) => {
		console.log(`Port closed: ${port}`);
		try {
			await fetch(`${forwardUrl}?remotePort=${port}`, {
				method: "DELETE",
			});
		} catch (error) {
			console.error("Failed to send stop forwarding request:", error);
		}
	},
);

console.log(`Port watcher started on remote, forward server: ${forwardUrl}`);
watcher.start();

// Keep the process running
await new Promise(() => {});
