import 'package:flutter/material.dart';

class SettingsDrawer extends StatelessWidget {
  const SettingsDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.lightBlueAccent),
              child: Row(
                mainAxisSize: MainAxisSize.min, // ← これで幅がコンパクトに
                children: const [
                  Icon(Icons.settings, color: Colors.white, size: 28),
                  SizedBox(width: 8),
                  Text(
                    "設定メニュー",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const ListTile(
              leading: Icon(Icons.person),
              title: Text("プロフィール"),
            ),
            const ListTile(
              leading: Icon(Icons.notifications),
              title: Text("通知設定"),
            ),
            const ListTile(
              leading: Icon(Icons.color_lens),
              title: Text("テーマ設定"),
            ),
            const ListTile(
              leading: Icon(Icons.info),
              title: Text("このアプリについて"),
            ),
          ],
        ),
      ),
    );
  }
}


