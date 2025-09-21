import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('通知', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF4A6466),
      ),
      body: Container(
        color: Color(0xFFFFFFFF),
        child: ListView(
          children: [
            ListTile(
              leading: Icon(Icons.circle, color: Colors.red, size: 12),
              title: Text('アップデートが完了しました', style: TextStyle(color: Color(0xFF000000))),
              subtitle: Text('1日前', style: TextStyle(color: Color(0xFF4A6466))),
            ),
            ListTile(
              leading: Icon(Icons.circle, color: Colors.red, size: 12),
              title: Text('〇〇を始めたあなたへ', style: TextStyle(color: Color(0xFF000000))),
              subtitle: Text('3ヶ月前', style: TextStyle(color: Color(0xFF4A6466))),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: NotificationScreen(),
  ));
}