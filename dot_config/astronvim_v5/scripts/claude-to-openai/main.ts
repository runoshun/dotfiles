#!/usr/bin/env -S deno run --allow-run --allow-env

async function main() {
  const proxyTs = import.meta.resolve("./src/proxy.ts");
  const proxyProcess = new Deno.Command("deno", {
    args: [
      "run",
      "--allow-net",
      "--allow-env",
      "--allow-read",
      proxyTs,
      "--debug",
    ],
    stdout: "piped",
    stderr: "inherit",
    env: {
      PORT: "18976",
      OPENAI_API_KEY: Deno.env.get("OPENAI_API_KEY") || "",
      OPENAI_BASE_URL: Deno.env.get("OPENAI_BASE_URL") ||
        "https://api.openai.com/v1",
    },
  }).spawn();
  const writer = await Deno.create("./proxy.log");
  proxyProcess.stdout.pipeTo(writer.writable);

  await new Promise((r) => setTimeout(r, 500));

  const env = {
    ...Deno.env.toObject(),
    ANTHROPIC_AUTH_TOKEN: "dummy",
    ANTHROPIC_BASE_URL: "http://localhost:18976",
  };
  const claudeProcess = new Deno.Command("npx", {
    args: ["-p", "@anthropic-ai/claude-code", "claude", ...Deno.args],
    env,
    stdout: "inherit",
    stderr: "inherit",
  }).spawn();

  const status = await claudeProcess.status;
  proxyProcess.kill("SIGTERM");
  Deno.exit(status.code);
}

main();
