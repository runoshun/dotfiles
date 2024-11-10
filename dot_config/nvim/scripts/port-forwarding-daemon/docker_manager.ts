import { DockerDetector } from "./lib/docker_detector.ts";
import { Bundler } from "./lib/bundler.ts";

const LABEL_SELECTOR = "com.github.copilot.port-forwarding";
const FORWARDING_PORT = 19876;

if (Deno.args.length !== 1) {
    console.error("Usage: deno run docker_manager.ts <label-value>");
    Deno.exit(1);
}

const labelValue = Deno.args[0];

// Bundle docker server code
const bundler = new Bundler();
const bundledCode = await bundler.bundle(
    import.meta.resolve("./docker_server.ts")
);

// Start container detector
const detector = new DockerDetector(
    LABEL_SELECTOR,
    async (container) => {
        if (container.labels[LABEL_SELECTOR] !== labelValue) return;

        console.log(`Injecting port forwarder into container: ${container.name}`);
        
        // Copy bundled code to container
        const copyCmd = new Deno.Command("docker", {
            args: [
                "exec",
                container.id,
                "sh",
                "-c",
                `mkdir -p /tmp/port-forwarding && cat > /tmp/port-forwarding/server.ts`
            ],
            stdin: "piped"
        }).spawn();

        if (copyCmd.stdin) {
            const writer = copyCmd.stdin.getWriter();
            await writer.write(new TextEncoder().encode(bundledCode));
            await writer.close();
        }
        await copyCmd.status;

        // Start the forwarder
        new Deno.Command("docker", {
            args: [
                "exec",
                "-d",  // detached mode
                container.id,
                "deno",
                "run",
                "-A",
                "/tmp/port-forwarding/server.ts",
                `http://host.docker.internal:${FORWARDING_PORT}`
            ]
        }).spawn();
    },
    (container) => {
        console.log(`Container stopped: ${container.name}`);
    }
);

console.log(`Starting Docker container detector for label ${LABEL_SELECTOR}=${labelValue}`);
detector.start();

// Cleanup on exit
const cleanup = () => {
    detector.stop();
    Deno.exit(0);
};

Deno.addSignalListener("SIGINT", cleanup);
Deno.addSignalListener("SIGTERM", cleanup);

// Keep the process running
await new Promise(() => {});
