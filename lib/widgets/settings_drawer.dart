import 'package:flutter/material.dart';

class SettingsDrawer extends StatelessWidget {
  const SettingsDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: const [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.lightBlueAccent),
              child: Text(
                "⚙️ 設定メニュー",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text("プロフィール"),
            ),
            ListTile(
              leading: Icon(Icons.notifications),
              title: Text("通知設定"),
            ),
            ListTile(
              leading: Icon(Icons.color_lens),
              title: Text("テーマ設定"),
            ),
            ListTile(
              leading: Icon(Icons.info),
              title: Text("このアプリについて"),
            ),
          ],
        ),
      ),
    );
  }
}
