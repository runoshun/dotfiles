import * as log from "jsr:@std/log";
import { PortWatcher } from "./lib/port_watcher.ts";
import { Forwarder } from "./lib/socat.ts";
import { addSshForwarding, deleteSshForwarding } from "./lib/ssh_forwarding.ts";

log.setup({
	handlers: {
		console: new log.ConsoleHandler("DEBUG"),
	},
	loggers: {
		default: {
			level: "INFO",
			handlers: ["console"],
		},
	},
});

if (Deno.args.length !== 1) {
	console.error("Usage: deno run docker_server.ts <forward-url>");
	Deno.exit(1);
}

const forwardUrl = Deno.args[0];
const forwarders = new Map<number, Forwarder>();

const containerIp = (() => {
	const p = new Deno.Command("hostname", { args: ["-i"] }).outputSync();
	return new TextDecoder().decode(p.stdout).trim();
})();

// Watch for new ports
const watcher = new PortWatcher(
	async (port: number) => {
		log.info(`New container port detected: ${port}`);

		const randomPort = Math.floor(Math.random() * 10000) + 20000;
		try {
			// Create a new forwarder for this port
			const forwarder = new Forwarder({
				sourceType: "tcp",
				sourceAddress: containerIp,
				sourcePort: randomPort,
				targetType: "tcp",
				targetAddress: "localhost",
				targetPort: port,
			});

			forwarder.start();
			forwarders.set(port, forwarder);

			// Notify to the management server
			await addSshForwarding(forwardUrl, {
				localPort: port,
				remoteHost: containerIp,
				remotePort: randomPort,
			});
		} catch (error) {
			log.error("Failed to setup port forwarding:", error);
		}
	},
	async (port: number) => {
		log.info(`Container port closed: ${port}`);
		try {
			// Stop the forwarder
			const forwarder = forwarders.get(port);
			if (forwarder) {
				await forwarder.stop();
				forwarders.delete(port);
			}

			// Notify the management server
			await deleteSshForwarding(forwardUrl, port, containerIp);
		} catch (error) {
			log.error("Failed to stop port forwarding:", error);
		}
	},
	20000,
);

log.info(`Docker port watcher started, forward server: ${forwardUrl}`);
watcher.start();

// Cleanup on exit
const cleanup = async () => {
	watcher.stop();
	for (const forwarder of forwarders.values()) {
		await forwarder.stop();
	}
	Deno.exit(0);
};

Deno.addSignalListener("SIGINT", cleanup);
Deno.addSignalListener("SIGTERM", cleanup);

// Keep the process running
await new Promise(() => {});
