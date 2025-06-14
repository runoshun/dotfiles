#!/usr/bin/env -S deno run --allow-net --allow-env --allow-read

import { startServer } from "./server_core.ts";

const DEBUG = Deno.args.includes("--debug");
const PORT = parseInt(Deno.env.get("PORT") || "8000", 10);

startServer({ port: PORT, debug: DEBUG });
