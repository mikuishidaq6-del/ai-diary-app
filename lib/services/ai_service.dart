import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import '../models/health_record.dart';

class AIService {
  static const String apiKey = "YOUR_API_KEY"; // ← 環境変数から読み込むのが理想

  static Future<String> fetchAIResponse(String userMessage) async {
    final chatBox = Hive.box('chatHistory');
    final healthBox = Hive.box<HealthRecord>('records');

    // チャット履歴（直近10件）
    final history = chatBox.values
        .toList()
        .reversed
        .take(10)
        .toList()
        .reversed
        .map((h) => {"role": h['role'], "content": h['content']})
        .toList();

    // 直近1週間の健康記録を要約
    final recentRecords = healthBox.values.where(
          (r) => r.datetime.isAfter(DateTime.now().subtract(const Duration(days: 7))),
    );
    final healthSummary = recentRecords.map((r) =>
    "${r.datetime.month}/${r.datetime.day} "
        "体温:${r.temperature ?? '-'}℃ "
        "血圧:${r.bloodPressure ?? '-'} "
        "脈拍:${r.pulse ?? '-'}"
    ).join("\n");

    final messages = [
      {
        "role": "system",
        "content": "あなたは患者に寄り添う会話相手です。診断やアドバイスはせず、共感や雑談をしてください。"
      },
      {"role": "user", "content": "直近の健康記録です:\n$healthSummary"},
      ...history,
      {"role": "user", "content": userMessage},
    ];

    final response = await http.post(
      Uri.parse("https://api.openai.com/v1/chat/completions"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $apiKey",
      },
      body: jsonEncode({
        "model": "gpt-4o-mini",
        "messages": messages,
      }),
    );

    final data = jsonDecode(response.body);
    final reply = data["choices"][0]["message"]["content"];

    // 履歴に保存
    chatBox.add({"role": "user", "content": userMessage});
    chatBox.add({"role": "assistant", "content": reply});

    return reply;
  }
}
