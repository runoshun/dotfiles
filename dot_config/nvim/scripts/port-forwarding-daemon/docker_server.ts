import { PortWatcher } from "./lib/port_watcher.ts";
import { Forwarder } from "./lib/socat.ts";

if (Deno.args.length !== 1) {
    console.error("Usage: deno run docker_server.ts <forward-url>");
    Deno.exit(1);
}

const forwardUrl = Deno.args[0];
const forwarders = new Map<number, Forwarder>();

// Watch for new ports
const watcher = new PortWatcher(
    async (port: number) => {
        console.log(`New container port detected: ${port}`);

        try {
            // Create a new forwarder for this port
            const forwarder = new Forwarder({
                sourceType: "tcp",
                sourceAddress: "0.0.0.0", // Listen on all interfaces
                sourcePort: port,
                targetType: "tcp",
                targetAddress: "localhost",
                targetPort: port
            });
            
            forwarder.start();
            forwarders.set(port, forwarder);

            // Notify the management server
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
            console.error("Failed to setup port forwarding:", error);
        }
    },
    async (port: number) => {
        console.log(`Container port closed: ${port}`);
        try {
            // Stop the forwarder
            const forwarder = forwarders.get(port);
            if (forwarder) {
                await forwarder.stop();
                forwarders.delete(port);
            }

            // Notify the management server
            await fetch(`${forwardUrl}?remotePort=${port}`, {
                method: "DELETE",
            });
        } catch (error) {
            console.error("Failed to stop port forwarding:", error);
        }
    }
);

console.log(`Docker port watcher started, forward server: ${forwardUrl}`);
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