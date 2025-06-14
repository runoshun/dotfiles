export function isReasoningModel(model: string): boolean {
  return model.startsWith("o1") || model.startsWith("o3") ||
    model.startsWith("o4");
}

const OPENAI_MODEL_NAME = Deno.env.get("OPENAI_MODEL_NAME") ?? "o4-mini";
const OPENAI_FAST_MODEL_NAME = Deno.env.get("OPENAI_FAST_MODEL_NAME") ??
  "gpt-4.1-mini";
const OPENAI_REASONING_EFFORT = Deno.env.get("OPENAI_REASONING_EFFORT") ??
  "medium";

export function selectModel(anthropicModelName: string): string {
  if (anthropicModelName.includes("haiku")) {
    return OPENAI_FAST_MODEL_NAME;
  }
  return OPENAI_MODEL_NAME;
}

export const REASONING_EFFORT = OPENAI_REASONING_EFFORT;
