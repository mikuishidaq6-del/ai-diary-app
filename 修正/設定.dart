import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('設定', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF4A6466),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              // 通知アイコンのアクション
            },
          ),
        ],
      ),
      body: Container(
        color: Color(0xFFFFFFFF),
        child: ListView(
          children: [
            ListTile(
              title: Text('バージョン', style: TextStyle(color: Color(0xFF000000))),
              trailing: Icon(Icons.chevron_right, color: Color(0xFF4A6466)),
              onTap: () {
                // バージョン詳細画面への遷移
              },
            ),
            ListTile(
              title: Text('アカウント', style: TextStyle(color: Color(0xFF000000))),
              subtitle: Text('Free\nStandard | 3-4 days', style: TextStyle(color: Color(0xFF4A6466))),
              trailing: Icon(Icons.chevron_right, color: Color(0xFF4A6466)),
              onTap: () {
                // アカウント詳細画面への遷移
              },
            ),
            ListTile(
              title: Text('PAYMENT', style: TextStyle(color: Color(0xFF000000))),
              subtitle: Text('Visa *1234', style: TextStyle(color: Color(0xFF4A6466))),
              trailing: Icon(Icons.chevron_right, color: Color(0xFF4A6466)),
              onTap: () {
                // 支払い設定画面への遷移
              },
            ),
            ListTile(
              title: Text('PROMOS', style: TextStyle(color: Color(0xFF000000))),
              subtitle: Text('Apply promo code', style: TextStyle(color: Color(0xFF4A6466))),
              trailing: Icon(Icons.chevron_right, color: Color(0xFF4A6466)),
              onTap: () {
                // プロモコード入力画面への遷移
              },
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: SettingsScreen(),
  ));
}