// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart'; // Firebase用
// import 'firebase_options.dart'; // flutterfire configure で生成されるファイル
// import 'package:hive_flutter/hive_flutter.dart';
// import 'models/health_record.dart';
//
// // ページをインポート
// import 'pages/health_record_page.dart';
// import 'pages/post_page.dart';
// import 'pages/timeline_page.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   // 🔹 Firebase 初期化
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//
//   // 🔹 Hive 初期化
//   await Hive.initFlutter();
//   Hive.registerAdapter(HealthRecordAdapter());
//   await Hive.openBox<HealthRecord>('records');
//
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: '健康記録アプリ',
//       theme: ThemeData(primarySwatch: Colors.blue),
//
//       // 最初に開くページを変更したい場合はここを変える
//       // home: const HealthRecordPage(),
//       home: const PostPage(),
//
//       // 🔹 ページ遷移用ルート
//       routes: {
//         '/health': (context) => const HealthRecordPage(),
//         '/post': (context) => const PostPage(),
//         '/timeline': (context) => const TimelinePage(),
//       },
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/health_record.dart';

// ページ
import 'pages/health_record_page.dart';
import 'pages/post_page.dart';
import 'pages/timeline_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 初期化
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Hive 初期化
  await Hive.initFlutter();
  Hive.registerAdapter(HealthRecordAdapter());
  await Hive.openBox<HealthRecord>('records');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '健康記録アプリ',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MainNavigationPage(), // 🔹 ここでタブ管理ページにする
    );
  }
}

/// 🔹 下タブで3ページ切り替え
class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HealthRecordPage(),
    PostPage(),
    TimelinePage(),
  ];

  final List<String> _titles = const [
    "健康記録",
    "AI投稿",
    "タイムライン",
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_selectedIndex])),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.health_and_safety),
            label: "健康記録",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: "AI投稿",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: "タイムライン",
          ),
        ],
      ),
    );
  }
}
