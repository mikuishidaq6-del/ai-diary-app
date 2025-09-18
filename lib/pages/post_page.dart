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

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() => _sending = true);

    // Firestoreにデータを追加
    await FirebaseFirestore.instance.collection("posts").add({
      "userMessage": text,   // ユーザーが入力した内容
      "aiReply": null,       // AIの返事（まだ空）
      "status": "waiting",   // 状態（返信待ち）
      "createdAt": FieldValue.serverTimestamp(),
    });

    _controller.clear();
    setState(() => _sending = false);
  }

  @override
  Widget build(BuildContext context) {
    final posts = FirebaseFirestore.instance
        .collection("posts")
        .orderBy("createdAt", descending: true);

    return Scaffold(
      appBar: AppBar(title: const Text("AI 投稿ページ")),
      body: Column(
        children: [
          // 入力欄
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _controller,
              minLines: 3,
              maxLines: 6,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "AIに送りたい文章を入力してください",
              ),
            ),
          ),

          // 送信ボタン
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _sending ? null : _send,
                child: Text(_sending ? "送信中..." : "送信"),
              ),
            ),
          ),

          const Divider(),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("投稿一覧（新しい順）"),
          ),

          // Firestoreのデータを表示
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: posts.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return const Center(child: Text("まだ投稿はありません"));
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, i) {
                    final data = docs[i].data() as Map<String, dynamic>;
                    final userMessage = data["userMessage"] ?? "";
                    final aiReply = data["aiReply"];
                    final status = data["status"];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: ListTile(
                        title: Text(userMessage),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            aiReply == null
                                ? (status == "error"
                                ? "⚠️ エラーが発生しました"
                                : "⏳ 返信待ち…")
                                : "🤖 AI: $aiReply",
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
