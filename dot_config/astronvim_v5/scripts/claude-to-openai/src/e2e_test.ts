#!/usr/bin/env -S deno run --allow-net --allow-env --allow-read

import "https://deno.land/std@0.200.0/dotenv/load.ts";
import { Anthropic } from "npm:@anthropic-ai/sdk";
import {
  assert,
  assertMatch,
  assertStringIncludes,
  assertThrows as _assertThrows,
} from "jsr:@std/assert";

const apiKey = Deno.env.get("ANTHROPIC_API_KEY");
if (!apiKey) {
  console.error(
    "Error: Please set the ANTHROPIC_API_KEY environment variable.",
  );
  Deno.exit(1);
}

const baseURL = Deno.env.get("ANTHROPIC_BASE_URL") ?? undefined;

const client = new Anthropic({ apiKey, baseURL });

const model = Deno.env.get("ANTHROPIC_MODEL_NAME") ??
  "claude-3-5-haiku-20241022";

async function runBasic() {
  console.log("=== Basic Test ===");
  const response = await client.messages.create({
    model,
    messages: [
      { role: "user", content: "こんにちは！今日の調子はどうですか？" },
    ],
    max_tokens: 512,
  });
  const contentRaw = response.content;
  const content = Array.isArray(contentRaw)
    ? contentRaw.map((c) => (c as { text: string }).text).join("")
    : contentRaw;
  if (typeof content !== "string" || content.length === 0) {
    throw new Error("Basic test failed: expected non-empty string content.");
  }
  console.log("Basic response:", content);
}

async function runTool() {
  console.log("=== Tool Test ===");
  const response = await client.messages.create({
    model,
    messages: [
      {
        role: "user",
        content: "サンフランシスコの今日の天気を教えてください。",
      },
    ],
    tools: [
      {
        name: "get_weather",
        description: "指定された場所の現在の天気を取得します。",
        input_schema: {
          type: "object",
          properties: {
            location: {
              type: "string",
              description: "天気情報を取得したい場所を英語で指定します。",
            },
            unit: {
              type: "string",
              enum: ["celsius", "fahrenheit"],
              description: "温度の単位 ('celsius' or 'fahrenheit')",
            },
          },
          required: ["location"],
        },
      },
    ],
    max_tokens: 512,
  });
  const toolUseEntry = Array.isArray(response.content)
    ? response.content.find((c) => c.type === "tool_use")
    : undefined;
  if (!toolUseEntry || toolUseEntry.name !== "get_weather") {
    throw new Error(
      "Tool test failed: expected tool_use entry with name 'get_weather'.",
    );
  }
  console.log("Tool function_call:", toolUseEntry);
}

async function runAdvanced() {
  console.log("=== Advanced Test ===");
  const response = await client.messages.create({
    model,
    messages: [
      {
        role: "user",
        content: "AIと人間の未来について短編小説を書いてください。",
      },
    ],
    system: "あなたは創造的で示唆に富むSF作家です。風変わりな文体で物語を紡いでください。",
    temperature: 0.7,
    top_k: 40,
    top_p: 0.9,
    stop_sequences: ["終劇", "---END---"],
    max_tokens: 512,
  });
  console.log(
    "DEBUG [Advanced] raw response:",
    JSON.stringify(response, null, 2),
  );
  const contentRaw = response.content;
  const content = Array.isArray(contentRaw)
    ? contentRaw.map((c) => (c as { text: string }).text).join("")
    : contentRaw;
  if (typeof content !== "string" || content.length === 0) {
    throw new Error("Advanced test failed: expected non-empty string content.");
  }
  console.log("Advanced response:", content);
}

async function runContextTest() {
  console.log("=== Context Test ===");
  const resp1 = await client.messages.create({
    model,
    messages: [{ role: "user", content: "1+1は何？" }],
    max_tokens: 100,
  });
  const raw1 = resp1.content;
  const text1 = Array.isArray(raw1) ? raw1.map((c) => (c as { text: string }).text).join("") : raw1;
  assertMatch(text1, /\b2\b/);
}

async function runSystemTest() {
  console.log("=== System Role Test ===");
  const response = await client.messages.create({
    model,
    system: "You are a helpful assistant. YOU MUST RESPOND 'HELLO!!'",
    messages: [{ role: "user", content: "Say hello." }],
    max_tokens: 100,
  });
  const contentRaw = response.content;
  const content = Array.isArray(contentRaw)
    ? contentRaw.map((c) => (c as { text: string }).text).join("")
    : contentRaw;
  assertStringIncludes(content, "HELLO!!");
  console.log("System test passed.");
}

async function runStopSequenceTest() {
  console.log("=== Stop Sequences Test ===");
  const response = await client.messages.create({
    model,
    messages: [{ role: "user", content: "Print ABC and then STOP here." }],
    stop_sequences: ["STOP"],
    max_tokens: 50,
  });
  const contentRaw = response.content;
  const content = Array.isArray(contentRaw)
    ? contentRaw.map((c) => (c as { text: string }).text).join("")
    : contentRaw;
  assertStringIncludes(content, "ABC");
  assert(!content.includes("STOP"));
  console.log("Stop sequences test passed.");
}

async function runToolOptionsTest() {
  console.log("=== Tool Options Test ===");
  const response = await client.messages.create({
    model,
    messages: [{
      role: "user",
      content: "What's the weather in Tokyo in fahrenheit?",
    }],
    tools: [{
      name: "get_weather",
      description: "Gets weather.",
      input_schema: {
        type: "object",
        properties: {
          location: { type: "string" },
          unit: { type: "string", enum: ["celsius", "fahrenheit"] },
        },
        required: ["location"],
      },
    }],
    max_tokens: 50,
  });
  const entry = Array.isArray(response.content)
    ? response.content.find((c) => c.type === "tool_use")
    : undefined;
  assert(entry && entry.name === "get_weather");
  console.log("Tool options test passed.");
}

async function runStreamingTest() {
  console.log("=== Streaming Test ===");
  let collected = "";
  const stream = client.messages.stream({
    model,
    messages: [{ role: "user", content: "Hello streaming" }],
    max_tokens: 50,
  });
  for await (const chunk of stream) {
    const text = Array.isArray(chunk) ? chunk.map((c) => c.text).join("") : chunk;
    collected += text;
  }
  assert(collected.length > 0);
  console.log("Streaming test passed.");
}

if (import.meta.main) {
  try {
    await runBasic();
    await runTool();
    await runAdvanced();
    await runContextTest();
    await runSystemTest();
    await runStopSequenceTest();
    await runToolOptionsTest();
    await runStreamingTest();
    console.log("All tests passed.");
  } catch (error) {
    console.error("Test failed:", error);
    Deno.exit(1);
  }
}
