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

  // 🔹 質問リスト
  final List<String> _questions = [
    "今日はどんな一日でしたか？",
    "体調の変化はありましたか？",
    "今の気分を一言で表すと？",
    "安心できた瞬間はありましたか？",
    "少し嬉しかったことはありますか？",
    "疲れを感じたのはどんな時でしたか？",
    "心がほっとした出来事は？",
    "今、体に一番感じることは？",
    "今日はどんなことに感謝したいですか？",
  ];

  // 🔹 今日の日付から質問を選ぶ
  String get _todayQuestion {
    final day = DateTime.now().day;
    return _questions[day % _questions.length];
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("投稿しました！AIの返事を待ってください")),
      );
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
        .orderBy("createdAt", descending: true);

    return Scaffold(
      body: Column(
        children: [
          // 入力欄
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _controller,
              minLines: 3,
              maxLines: 6,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: _todayQuestion, // 🔹 日替わり質問を表示
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
                    final ts = data["createdAt"] as Timestamp?;
                    final createdAt = ts?.toDate();

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
                        trailing: createdAt == null
                            ? null
                            : Text(
                          "${createdAt.month}/${createdAt.day} "
                              "${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}",
                          style: const TextStyle(fontSize: 12),
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

// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class PostPage extends StatefulWidget {
//   const PostPage({super.key});
//
//   @override
//   State<PostPage> createState() => _PostPageState();
// }
//
// class _PostPageState extends State<PostPage> {
//   final _controller = TextEditingController();
//   bool _sending = false;
//
//   // 🔹 質問リスト（サンプル）
//   final List<String> _questions = [
//     "今日はどんな一日でしたか？",
//     "体調の変化はありましたか？",
//     "今の気分を一言で表すと？",
//     "安心できた瞬間はありましたか？",
//     "少し嬉しかったことはありますか？",
//     "疲れを感じたのはどんな時でしたか？",
//     "心がほっとした出来事は？",
//     "今、体に一番感じることは？",
//     "今日はどんなことに感謝したいですか？",
//   ];
//
//   String get _todayQuestion {
//     final day = DateTime.now().day;
//     return _questions[day % _questions.length];
//   }
//
//   Future<void> _send() async {
//     final text = _controller.text.trim();
//     if (text.isEmpty) return;
//
//     setState(() => _sending = true);
//
//     try {
//       await FirebaseFirestore.instance.collection("posts").add({
//         "userMessage": text,
//         "aiReply": null,
//         "status": "waiting",
//         "createdAt": FieldValue.serverTimestamp(),
//       });
//       _controller.clear();
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("送信エラー: $e")),
//       );
//     }
//
//     setState(() => _sending = false);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final posts = FirebaseFirestore.instance
//         .collection("posts")
//         .orderBy("createdAt", descending: false); // 🔹 昇順でチャットっぽく
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("AIチャット"),
//         backgroundColor: Colors.lightBlueAccent,
//       ),
//       body: Column(
//         children: [
//           // 🔹 日替わり質問を上部に表示
//           Container(
//             padding: const EdgeInsets.all(12),
//             width: double.infinity,
//             color: Colors.lightBlue[50],
//             child: Text(
//               "💡 今日の質問: $_todayQuestion",
//               style: const TextStyle(fontWeight: FontWeight.bold),
//             ),
//           ),
//           const Divider(height: 1),
//
//           // 🔹 チャット履歴
//           Expanded(
//             child: StreamBuilder<QuerySnapshot>(
//               stream: posts.snapshots(),
//               builder: (context, snapshot) {
//                 if (!snapshot.hasData) {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//
//                 final docs = snapshot.data!.docs;
//                 if (docs.isEmpty) {
//                   return const Center(child: Text("まだ会話はありません"));
//                 }
//
//                 return ListView.builder(
//                   padding: const EdgeInsets.all(12),
//                   itemCount: docs.length,
//                   itemBuilder: (context, i) {
//                     final data = docs[i].data() as Map<String, dynamic>;
//                     final userMessage = data["userMessage"] ?? "";
//                     final aiReply = data["aiReply"];
//                     final status = data["status"];
//
//                     return Column(
//                       crossAxisAlignment: CrossAxisAlignment.stretch,
//                       children: [
//                         // 🔹 ユーザーの吹き出し
//                         Align(
//                           alignment: Alignment.centerRight,
//                           child: Container(
//                             padding: const EdgeInsets.all(12),
//                             margin: const EdgeInsets.symmetric(vertical: 4),
//                             decoration: BoxDecoration(
//                               color: Colors.blue[100],
//                               borderRadius: BorderRadius.circular(16),
//                             ),
//                             child: Text(userMessage),
//                           ),
//                         ),
//
//                         // 🔹 AIの吹き出し
//                         Align(
//                           alignment: Alignment.centerLeft,
//                           child: Container(
//                             padding: const EdgeInsets.all(12),
//                             margin: const EdgeInsets.only(bottom: 12),
//                             decoration: BoxDecoration(
//                               color: Colors.grey[200],
//                               borderRadius: BorderRadius.circular(16),
//                             ),
//                             child: Text(
//                               aiReply == null
//                                   ? (status == "error"
//                                   ? "⚠️ エラーが発生しました"
//                                   : "⏳ 返信待ち…")
//                                   : aiReply,
//                             ),
//                           ),
//                         ),
//                       ],
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//
//           // 🔹 入力欄 + 送信ボタン
//           SafeArea(
//             child: Padding(
//               padding: const EdgeInsets.all(8),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: TextField(
//                       controller: _controller,
//                       decoration: const InputDecoration(
//                         hintText: "メッセージを入力...",
//                         border: OutlineInputBorder(),
//                       ),
//                       minLines: 1,
//                       maxLines: 3,
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   IconButton(
//                     icon: _sending
//                         ? const CircularProgressIndicator()
//                         : const Icon(Icons.send, color: Colors.blue),
//                     onPressed: _sending ? null : _send,
//                   )
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class PostPage extends StatefulWidget {
//   const PostPage({super.key});
//
//   @override
//   State<PostPage> createState() => _PostPageState();
// }
//
// class _PostPageState extends State<PostPage> {
//   final _controller = TextEditingController();
//   bool _sending = false;
//
//   // 🔹 優しい提案リスト
//   final List<String> _prompts = [
//     "今日はどんなことが心に残りましたか？",
//     "からだや気持ちに小さな変化はありましたか？",
//     "ふっと安心できた瞬間はありましたか？",
//     "ちょっと嬉しかったことを思い出せますか？",
//     "疲れを感じたのはどんなとき？",
//     "感謝したいことはありましたか？",
//     "今の気分をひとことで言うなら？",
//   ];
//
//   String get _todayPrompt {
//     final day = DateTime.now().day;
//     return _prompts[day % _prompts.length];
//   }
//
//   Future<void> _send() async {
//     final text = _controller.text.trim();
//     if (text.isEmpty) return;
//
//     setState(() => _sending = true);
//
//     try {
//       await FirebaseFirestore.instance.collection("posts").add({
//         "userMessage": text,
//         "aiReply": null,
//         "status": "waiting",
//         "createdAt": FieldValue.serverTimestamp(),
//       });
//       _controller.clear();
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("送信エラー: $e")),
//       );
//     }
//
//     setState(() => _sending = false);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final posts = FirebaseFirestore.instance
//         .collection("posts")
//         .orderBy("createdAt", descending: false);
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("AIチャット"),
//         backgroundColor: Colors.pink[200],
//         elevation: 0,
//       ),
//       body: Column(
//         children: [
//           // 🔹 提案メッセージを上部に表示
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.pink[50],
//               borderRadius: const BorderRadius.only(
//                 bottomLeft: Radius.circular(24),
//                 bottomRight: Radius.circular(24),
//               ),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   "💡 きょうのひとこと提案",
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.pinkAccent,
//                   ),
//                 ),
//                 const SizedBox(height: 6),
//                 Text(
//                   _todayPrompt,
//                   style: TextStyle(
//                     fontSize: 15,
//                     fontStyle: FontStyle.italic,
//                     color: Colors.grey[700],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const Divider(height: 1),
//
//           // 🔹 チャット履歴
//           Expanded(
//             child: StreamBuilder<QuerySnapshot>(
//               stream: posts.snapshots(),
//               builder: (context, snapshot) {
//                 if (!snapshot.hasData) {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//
//                 final docs = snapshot.data!.docs;
//                 if (docs.isEmpty) {
//                   return const Center(child: Text("まだ会話はありません"));
//                 }
//
//                 return ListView.builder(
//                   padding: const EdgeInsets.all(12),
//                   itemCount: docs.length,
//                   itemBuilder: (context, i) {
//                     final data = docs[i].data() as Map<String, dynamic>;
//                     final userMessage = data["userMessage"] ?? "";
//                     final aiReply = data["aiReply"];
//                     final status = data["status"];
//
//                     return Column(
//                       crossAxisAlignment: CrossAxisAlignment.stretch,
//                       children: [
//                         // ユーザーの吹き出し
//                         Align(
//                           alignment: Alignment.centerRight,
//                           child: Container(
//                             padding: const EdgeInsets.all(12),
//                             margin: const EdgeInsets.symmetric(vertical: 4),
//                             decoration: BoxDecoration(
//                               color: Colors.pink[100],
//                               borderRadius: BorderRadius.circular(16),
//                             ),
//                             child: Text(
//                               userMessage,
//                               style: const TextStyle(color: Colors.black87),
//                             ),
//                           ),
//                         ),
//
//                         // AIの吹き出し
//                         Align(
//                           alignment: Alignment.centerLeft,
//                           child: Container(
//                             padding: const EdgeInsets.all(12),
//                             margin: const EdgeInsets.only(bottom: 12),
//                             decoration: BoxDecoration(
//                               color: Colors.grey[100],
//                               borderRadius: BorderRadius.circular(16),
//                             ),
//                             child: Text(
//                               aiReply == null
//                                   ? (status == "error"
//                                   ? "⚠️ エラーが発生しました"
//                                   : "⏳ 返信待ち…")
//                                   : aiReply,
//                               style: const TextStyle(color: Colors.black87),
//                             ),
//                           ),
//                         ),
//                       ],
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//
//           // 入力欄
//           SafeArea(
//             child: Padding(
//               padding: const EdgeInsets.all(8),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: TextField(
//                       controller: _controller,
//                       decoration: InputDecoration(
//                         hintText: "ここに気持ちを書いてみませんか？",
//                         filled: true,
//                         fillColor: Colors.pink[50],
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(20),
//                           borderSide: BorderSide.none,
//                         ),
//                         contentPadding: const EdgeInsets.symmetric(
//                             vertical: 10, horizontal: 16),
//                       ),
//                       minLines: 1,
//                       maxLines: 3,
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   CircleAvatar(
//                     backgroundColor: Colors.pinkAccent,
//                     child: IconButton(
//                       icon: _sending
//                           ? const CircularProgressIndicator(
//                           color: Colors.white, strokeWidth: 2)
//                           : const Icon(Icons.send, color: Colors.white),
//                       onPressed: _sending ? null : _send,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
