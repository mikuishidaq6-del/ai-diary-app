import { onDocumentCreated } from "firebase-functions/v2/firestore";
import { defineSecret } from "firebase-functions/params";

const OPENAI_API_KEY = defineSecret("OPENAI_API_KEY");

export const onPostCreated = onDocumentCreated(
  {
    document: "posts/{postId}",
    region: "asia-northeast1", // 東京リージョン
    secrets: [OPENAI_API_KEY],
    timeoutSeconds: 60,
    memory: "256MiB",
  },
  async (event) => {
    const snap = event.data;
    if (!snap) return;
    const data = snap.data() as any;

    const userMessage: string = data.userMessage ?? "";
    if (!userMessage) {
      await snap.ref.update({ status: "error", error: "empty_message" });
      return;
    }

    try {
      const res = await fetch("https://api.openai.com/v1/chat/completions", {
        method: "POST",
        headers: {
          "Authorization": `Bearer ${OPENAI_API_KEY.value()}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          model: "gpt-4o-mini",
          messages: [
            {
              role: "system",
              content:
                "あなたは血液がん患者に寄り添う血液がん看護を専門とする看護師です。血液がんの治療をする患者さんからの入力に対して、共感・傾聴→安心→励ましの流れで短く返答してください。返答は150文字以内、日本語で優しく温かい口調に。どんなにネガティブなことでも、必ずポジティブに返答してください。ただし、励ましはポジティブになりすぎないでください。”！”は1回のみ使用できます。質問は含めないでください。治療に対する助言もしないでください。気持ちがわかるという返答は無し、想像できるは有りです。"
            },
            { role: "user", content: userMessage },
          ],
          temperature: 0.7,
          max_tokens: 200,
        }),
      });

      if (!res.ok) {
        const text = await res.text();
        console.error("OpenAI error:", res.status, text);
        await snap.ref.update({
          status: "error",
          error: `openai_${res.status}`,
        });
        return;
      }

      const json = await res.json();
      const aiReply: string =
        json?.choices?.[0]?.message?.content ?? "(返事なし)";

      await snap.ref.update({
        aiReply,
        status: "answered",
        answeredAt: new Date(),
      });
    } catch (e: any) {
      console.error("Function error:", e);
      await snap.ref.update({
        status: "error",
        error: e?.message ?? "unknown",
      });
    }
  }
);
