import { PortWatcher } from "./lib/port_watcher.ts";
import { DockerDetector } from "./lib/docker_detector.ts";
import { Bundler } from "./lib/bundler.ts";

if (Deno.args.length !== 1) {
	console.error("Usage: deno run remote_server.ts <forward-url>");
	Deno.exit(1);
}

const forwardUrl = Deno.args[0];
const DOCKER_LABEL = "port.forwarding.enabled";

// dockerServerCode is defined in the combined bundle from main.ts

// Function to inject and run docker_server in a container
async function injectAndRunServer(containerId: string) {
	try {
		// Copy server code to container
		const copyCmd = new Deno.Command("docker", {
			args: ["exec", containerId, "sh", "-c", "cat > /tmp/docker_server.ts"],
			stdin: "piped",
		}).spawn();

		if (copyCmd.stdin) {
			const writer = copyCmd.stdin.getWriter();
			await writer.write(new TextEncoder().encode(dockerServerCode));
			await writer.close();
		}
		await copyCmd.status;

		// Run server in container
		const runCmd = new Deno.Command("docker", {
			args: [
				"exec",
				"-d",  // Run in background
				containerId,
				"deno",
				"run",
				"-A",
				"/tmp/docker_server.ts",
				`http://host.docker.internal:${new URL(forwardUrl).port}`,
			],
		}).spawn();
		await runCmd.status;

		console.log(`Started port forwarding server in container ${containerId}`);
	} catch (error) {
		console.error(`Failed to setup container ${containerId}:`, error);
	}
}

// Setup Docker container monitoring
const dockerDetector = new DockerDetector(
	DOCKER_LABEL,
	(container) => {
		console.log(`New container detected: ${container.name}`);
		injectAndRunServer(container.id);
	},
	(container) => {
		console.log(`Container stopped: ${container.name}`);
	},
);
dockerDetector.start();

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

// Cleanup on exit
const cleanup = () => {
	watcher.stop();
	dockerDetector.stop();
	Deno.exit(0);
};

Deno.addSignalListener("SIGINT", cleanup);
Deno.addSignalListener("SIGTERM", cleanup);

// Keep the process running
await new Promise(() => {});
