import { PortWatcher } from "./lib/port_watcher.ts";
import { DockerDetector } from "./lib/docker_detector.ts";
import { Forwarder } from "./lib/socat.ts";
import { addSshForwarding, deleteSshForwarding } from "./lib/ssh_forwarding.ts";

// dockerServerCode is defined in the combined bundle from main.ts
declare const dockerServerCode: string;

if (Deno.args.length !== 1) {
	console.error("Usage: deno run remote_server.ts <manager-server-url>");
	Deno.exit(1);
}

const managerServerUrl = Deno.args[0];
const managerServerPort = new URL(managerServerUrl).port;

const DOCKER_LABEL = "auto.port.forwarding.enabled";
const DOCKER_SCRIPT_PATH = "/tmp/docker_server.ts";
const DOCKER_MANAGER_SERVER_PORT = parseInt(managerServerPort) + 1;

Deno.writeTextFileSync(DOCKER_SCRIPT_PATH, dockerServerCode);

// Function to inject and run docker_server in a container
async function injectAndRunServerOnContainer(containerId: string) {
	try {
		// Copy server code to container
		const copyCmd = new Deno.Command("docker", {
			args: ["cp", DOCKER_SCRIPT_PATH, `${containerId}:${DOCKER_SCRIPT_PATH}`],
		}).spawn();
		await copyCmd.status;

		// Install Deno in container
		const installCmd = new Deno.Command("docker", {
			args: [
				"exec",
				containerId,
				"sh",
				"-c",
				"curl -fsSL https://deno.land/install.sh | sh",
			],
		}).spawn();
		await installCmd.status;

		// Run server in container
		const runCmd = new Deno.Command("docker", {
			args: [
				"exec",
				containerId,
				"/root/.deno/bin/deno",
				"run",
				"-A",
				DOCKER_SCRIPT_PATH,
				`http://host.docker.internal:${DOCKER_MANAGER_SERVER_PORT}`,
			],
		}).spawn();

		await runCmd.status;
		console.log(`Started server in container ${await runCmd.status}`);

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
		injectAndRunServerOnContainer(container.id);
	},
	(container) => {
		console.log(`Container stopped: ${container.name}`);
	},
);
const dockerForwarder = new Forwarder({
	sourceType: "tcp",
	sourcePort: DOCKER_MANAGER_SERVER_PORT,
	sourceAddress: "0.0.0.0",
	targetType: "tcp",
	targetPort: parseInt(managerServerPort),
	targetAddress: "localhost",
});

// Watch for new ports on the remote server
const watcher = new PortWatcher(
	async (port: number) => {
		console.log(`New port detected: ${port}`);

		try {
			await addSshForwarding(managerServerUrl, {
				localPort: port,
				remoteHost: "localhost",
				remotePort: port,
			});
		} catch (error) {
			console.error("Failed to send forwarding request:", error);
		}
	},
	async (port: number) => {
		console.log(`Port closed: ${port}`);
		try {
			await deleteSshForwarding(managerServerUrl, port);
		} catch (error) {
			console.error("Failed to send stop forwarding request:", error);
		}
	},
);

console.log(
	`Port and docker container watcher started on remote, forward server: ${managerServerUrl}`,
);
dockerForwarder.start();
dockerDetector.start();
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
