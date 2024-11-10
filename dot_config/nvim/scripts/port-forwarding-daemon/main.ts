import { SSHForwardingServer } from "./lib/ssh_forwarding.ts";
import { Bundler } from "./lib/bundler.ts";

const LOCAL_FORWARDING_PORT = 19876;

if (Deno.args.length !== 1) {
	console.error("Usage: deno run main.ts <remote-host>");
	Deno.exit(1);
}

const remoteHost = Deno.args[0];

// Start local SSH forwarding server
const forwardingServer = new SSHForwardingServer();
forwardingServer.start(LOCAL_FORWARDING_PORT);

// Bundle remote server code
const bundler = new Bundler();
const bundledCode = await bundler.bundle(
	import.meta.resolve("./remote_server.ts"),
);

// Start remote forwarding server
const remoteServerProcess = new Deno.Command("ssh", {
	args: [
		remoteHost,
		"-R",
		`${LOCAL_FORWARDING_PORT}:localhost:${LOCAL_FORWARDING_PORT}`,
		`cat <<EOF && deno repl -- 'http://localhost:${LOCAL_FORWARDING_PORT}'`,
	],
	stdin: "piped",
}).spawn();

// Send the bundled code
if (remoteServerProcess.stdin) {
	const writer = remoteServerProcess.stdin.getWriter();
	await writer.write(new TextEncoder().encode(bundledCode));
	await writer.write(new TextEncoder().encode("\nEOF\n"));
	await writer.close();
}

// Cleanup on exit
const cleanup = () => {
	forwardingServer.stop();
	remoteServerProcess.kill("SIGTERM");
};

Deno.addSignalListener("SIGINT", cleanup);
Deno.addSignalListener("SIGTERM", cleanup);
