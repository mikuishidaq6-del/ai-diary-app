import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PostPage extends StatefulWidget {
  const PostPage({super.key});

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  final _controller = TextEditingController();
  bool _sending = false;

  // 🔹 優しい提案リスト
  final List<String> _prompts = [
    "今日はどんなことが心に残りましたか？",
    "からだや気持ちに小さな変化はありましたか？",
    "ふっと安心できた瞬間はありましたか？",
    "ちょっと嬉しかったことを思い出せますか？",
    "疲れを感じたのはどんなとき？",
    "感謝したいことはありましたか？",
    "今の気分をひとことで言うなら？",
  ];

  String get _todayPrompt {
    final day = DateTime.now().day;
    return _prompts[day % _prompts.length];
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() => _sending = true);

    try {
      await FirebaseFirestore.instance.collection("posts").add({
        "userMessage": text,
        "aiReply": null,
        "status": "waiting",
        "createdAt": FieldValue.serverTimestamp(),
      });
      _controller.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("送信エラー: $e")),
      );
    }

    setState(() => _sending = false);
  }

  @override
  Widget build(BuildContext context) {
    final posts = FirebaseFirestore.instance
        .collection("posts")
        .orderBy("createdAt", descending: false);

    return Scaffold(
      body: Column(
        children: [
          // 🔹 提案メッセージを上部に表示
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.lightBlue[50], // 明るい水色
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.auto_awesome, color: Colors.lightBlueAccent, size: 20), // ✨ ロゴ風
                    SizedBox(width: 6),
                    Text(
                      "きょうのひとこと提案",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.lightBlueAccent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  _todayPrompt,
                  style: TextStyle(
                    fontSize: 15,
                    fontStyle: FontStyle.italic,
                    color: Colors.blueGrey[700],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // 🔹 チャット履歴
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: posts.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return const Center(child: Text("まだ会話はありません"));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: docs.length,
                  itemBuilder: (context, i) {
                    final data = docs[i].data() as Map<String, dynamic>;
                    final userMessage = data["userMessage"] ?? "";
                    final aiReply = data["aiReply"];
                    final status = data["status"];

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ユーザーの吹き出し
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.lightBlue[100], // ユーザーは水色
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              userMessage,
                              style: const TextStyle(color: Colors.black87),
                            ),
                          ),
                        ),

                        // AIの吹き出し
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white, // ← 白背景に変更
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey[300]!), // 薄い枠線を追加
                            ),
                            child: Text(
                              aiReply == null
                                  ? (status == "error"
                                  ? "⚠️ エラーが発生しました"
                                  : "⏳ 返信待ち…")
                                  : aiReply,
                              style: const TextStyle(color: Colors.black87),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),

          const Divider(height: 1),

          // 入力欄
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: "ここに気持ちを書いてみませんか？",
                        hintStyle: TextStyle(color: Colors.blueGrey[400]),
                        filled: true,
                        fillColor: Colors.lightBlue[100], // ← 今日のひとことと同じ色に
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 16),
                      ),
                      minLines: 1,
                      maxLines: 3,
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: Colors.lightBlueAccent,
                    child: IconButton(
                      icon: _sending
                          ? const CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2)
                          : const Icon(Icons.send, color: Colors.white),
                      onPressed: _sending ? null : _send,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
