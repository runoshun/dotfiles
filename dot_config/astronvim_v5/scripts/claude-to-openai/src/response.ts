// Response handlers and message mapping for proxy

interface OpenAIUsage {
  prompt_tokens?: number;
  completion_tokens?: number;
}
interface OpenAIData {
  id: string;
  created: number;
  usage?: OpenAIUsage;
}

export function handleNonStreamingResponse(
  data: OpenAIData,
  contentArray: Array<Record<string, unknown>>,
  originalModel: string,
  hasToolUse: boolean,
): Response {
  const anthropicResponse = {
    id: data.id,
    type: "message",
    role: "assistant",
    model: originalModel,
    created: data.created,
    content: contentArray,
    stop_reason: hasToolUse ? "tool_use" : "end_turn",
    stop_sequences: null,
    usage: {
      input_tokens: data.usage?.prompt_tokens || 0,
      output_tokens: data.usage?.completion_tokens || 0,
      cache_creation_input_tokens: 0,
      cache_read_input_tokens: 0,
      service_tier: "standard",
    },
  };
  return new Response(JSON.stringify(anthropicResponse), {
    headers: { "content-type": "application/json" },
  });
}

export function handleStreamingResponse(
  data: OpenAIData,
  contentArray: Array<Record<string, unknown>>,
  originalModel: string,
  hasToolUse: boolean,
): Response {
  const encoder = new TextEncoder();
  const streamSSE = new ReadableStream({
    start(controller) {
      const enqueue = (s: string) => {
        controller.enqueue(encoder.encode(s));
      };

      const startEvent = {
        type: "message_start",
        message: {
          id: data.id,
          type: "message",
          role: "assistant",
          content: [],
          model: originalModel,
          stop_reason: null,
          stop_sequence: null,
          usage: {
            input_tokens: data.usage?.prompt_tokens || 0,
            output_tokens: 0,
          },
        },
      };
      enqueue(`event: message_start\ndata: ${JSON.stringify(startEvent)}\n\n`);

      contentArray.forEach((content, i) => {
        const isToolUse = content.type === "tool_use";
        const startBlock = isToolUse
          ? { type: "tool_use", name: content.name, id: content.id, input: {} }
          : { type: "text", text: "" };
        const deltaBlock = isToolUse
          ? {
            type: "input_json_delta",
            partial_json: JSON.stringify(content.input || {}),
          }
          : { type: "text_delta", text: content.text || "" };
        enqueue(
          `event: content_block_start\ndata: ${
            JSON.stringify({
              type: "content_block_start",
              index: i,
              content_block: startBlock,
            })
          }\n\n`,
        );
        enqueue(
          `event: content_block_delta\ndata: ${
            JSON.stringify({
              type: "content_block_delta",
              index: i,
              delta: deltaBlock,
            })
          }\n\n`,
        );
        enqueue(
          `event: content_block_stop\ndata: ${
            JSON.stringify({ type: "content_block_stop", index: i })
          }\n\n`,
        );
      });

      enqueue(
        `event: message_delta\ndata: ${
          JSON.stringify({
            type: "message_delta",
            delta: {
              stop_reason: hasToolUse ? "tool_use" : "end_turn",
              stop_sequence: null,
            },
            usage: {
              input_tokens: data.usage?.prompt_tokens || 0,
              output_tokens: data.usage?.completion_tokens || 0,
            },
          })
        }\n\n`,
      );
      enqueue(
        `event: message_stop\ndata: ${JSON.stringify({ type: "message_stop" })}\n\n`,
      );
      controller.close();
    },
  });
  return new Response(streamSSE, {
    headers: {
      "Content-Type": "text/event-stream; charset=utf-8",
      "Cache-Control": "no-cache",
      Connection: "keep-alive",
    },
  });
}

export function mapToOpenAIMessages(msg: { role: string; content: unknown }): unknown[] {
  const result: unknown[] = [];
  const toolCalls: unknown[] = [];
  const toolMessages: unknown[] = [];
  const content = (() => {
    if (!Array.isArray(msg.content)) return msg.content;
    return msg.content
      .map((c) => {
        if (c.type === "tool_use") {
          toolCalls.push({
            type: "function",
            function: {
              name: c.name,
              arguments: JSON.stringify(c.input || {}),
            },
            id: c.id,
          });
          return undefined;
        } else if (c.type === "tool_result") {
          toolMessages.push({
            role: "tool",
            tool_call_id: c.tool_use_id,
            content: c.content,
          });
          return undefined;
        } else {
          return c;
        }
      })
      .filter((c) => c !== undefined);
  })();
  if (
    (Array.isArray(content) ? content.length : 1) !== 0 || toolCalls.length > 0
  ) {
    const entry: { role: string; content: unknown; tool_calls?: unknown[] } = {
      role: msg.role,
      content,
    };
    if (toolCalls.length) entry.tool_calls = toolCalls;
    result.push(entry);
  }
  toolMessages.forEach((tm) => result.push(tm));
  return result;
}
