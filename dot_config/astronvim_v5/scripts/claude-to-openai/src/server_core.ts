#!/usr/bin/env -S deno run --allow-net --allow-env --allow-read
// deno-lint-ignore-file no-explicit-any
// deno-lint-ignore-file no-explicit-any require-await

import { isReasoningModel, REASONING_EFFORT, selectModel } from "./utils.ts";
import {
  handleNonStreamingResponse,
  handleStreamingResponse,
  mapToOpenAIMessages,
} from "./response.ts";

export function startServer(
  { port, debug }: { port: number; debug: boolean },
) {
  const OPENAI_API_KEY = Deno.env.get("OPENAI_API_KEY");
  if (!OPENAI_API_KEY) {
    console.error("Error: Please set the OPENAI_API_KEY environment variable.");
    Deno.exit(1);
  }

  Deno.serve({ port }, async (req) => {
    if (debug) {
      console.log(`DEBUG Received ${req.method} request at ${req.url}`);
    }
    if (req.method !== "POST") {
      return new Response("Method Not Allowed", { status: 405 });
    }
    let body: any;
    try {
      body = await req.json();
    } catch (e) {
      if (debug) console.error("DEBUG Invalid JSON body:", e);
      return new Response("Invalid JSON", { status: 400 });
    }
    if (debug) console.log("DEBUG Request body:", body);

    const {
      stream = false,
      messages,
      system,
      temperature,
      top_p,
      stop_sequences,
      tools,
      model: originalModel,
    } = body;

    const openaiMessages: any[] = [];
    if (system) openaiMessages.push({ role: "system", content: system });
    for (const msg of messages || []) {
      openaiMessages.push(...mapToOpenAIMessages(msg));
    }

    const model = selectModel(originalModel);
    const openaiRequestBody: any = { model, messages: openaiMessages };
    if (temperature !== undefined) {
      openaiRequestBody.temperature = isReasoningModel(model) ? 1 : temperature;
    }
    if (top_p !== undefined && !isReasoningModel(model)) {
      openaiRequestBody.top_p = top_p;
    }
    if (stop_sequences !== undefined && !isReasoningModel(model)) {
      openaiRequestBody.stop = stop_sequences;
    }
    if (isReasoningModel(model)) {
      openaiRequestBody.reasoning_effort = REASONING_EFFORT;
    }

    if (tools) {
      openaiRequestBody.tools = tools.map((t: any) => ({
        type: "function",
        function: {
          name: t.name,
          description: t.description,
          parameters: t.input_schema,
        },
      }));
      openaiRequestBody.tool_choice = "auto";
    }

    const debugBody = { ...openaiRequestBody };
    delete debugBody.tools;
    if (debug) console.log("DEBUG proxy -> OpenAI request body:", debugBody);

    try {
      const resp = await fetch("https://api.openai.com/v1/chat/completions", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${OPENAI_API_KEY}`,
        },
        body: JSON.stringify(openaiRequestBody),
      });
      const respText = await resp.text();
      if (!resp.ok) {
        return new Response(respText, {
          status: resp.status,
          headers: {
            "content-type": resp.headers.get("content-type") || "text/plain",
          },
        });
      }
      const data = JSON.parse(respText);
      const choice = data.choices?.[0];
      const contentArray: any[] = [];
      let hasToolUse = false;
      if (choice.message.tool_calls?.length > 0) {
        hasToolUse = true;
        for (const tc of choice.message.tool_calls) {
          contentArray.push({
            type: "tool_use",
            name: tc.function.name,
            id: tc.id,
            input: tc.function.arguments ? JSON.parse(tc.function.arguments) : {},
          });
        }
      } else {
        contentArray.push({ type: "text", text: choice.message.content });
      }

      return stream
        ? handleStreamingResponse(data, contentArray, originalModel, hasToolUse)
        : handleNonStreamingResponse(
          data,
          contentArray,
          originalModel,
          hasToolUse,
        );
    } catch (e) {
      console.error("Error calling OpenAI API:", e);
      return new Response("Internal Server Error", { status: 500 });
    }
  });
}
