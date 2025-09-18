import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TimelinePage extends StatelessWidget {
  const TimelinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("AI タイムライン")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text("まだ投稿がありません"));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final userMessage = data['userMessage'] ?? "";
              final aiReply = data['aiReply'] ?? "(返信待ち)";
              final status = data['status'] ?? "";
              final ts = data["createdAt"] as Timestamp?;
              final createdAt = ts?.toDate();

              return Card(
                margin:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text("📝 あなた: $userMessage"),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Text("🤖 AI: $aiReply\n状態: $status"),
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
    );
  }
}
