// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'models/health_record.dart';
//
// // ページ
// import 'pages/health_record_page.dart';
// import 'pages/post_page.dart';
// import 'pages/calendar_page.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   // Firebase 初期化
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//
//   // Hive 初期化
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
//       theme: ThemeData(
//         // 🌸 全体テーマを水色系に
//         primarySwatch: Colors.lightBlue,
//         scaffoldBackgroundColor: Colors.blue[50],
//
//         appBarTheme: AppBarTheme(
//           backgroundColor: Colors.lightBlue[300],
//           foregroundColor: Colors.white,
//           elevation: 0,
//           centerTitle: true,
//           titleTextStyle: const TextStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//
//         bottomNavigationBarTheme: BottomNavigationBarThemeData(
//           backgroundColor: Colors.white,
//           selectedItemColor: Colors.lightBlue[600],
//           unselectedItemColor: Colors.grey,
//           selectedIconTheme: const IconThemeData(size: 28),
//           unselectedIconTheme: const IconThemeData(size: 24),
//           type: BottomNavigationBarType.fixed,
//         ),
//
//         elevatedButtonTheme: ElevatedButtonThemeData(
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Colors.lightBlue[300],
//             foregroundColor: Colors.white,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(16),
//             ),
//             padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
//             textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//           ),
//         ),
//
//         cardTheme: CardThemeData(
//           color: Colors.white,
//           elevation: 3,
//           margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//         ),
//       ),
//       home: const MainNavigationPage(), // 🔹 ここでタブ管理ページにする
//     );
//   }
// }
//
// /// 🔹 下タブで3ページ切り替え
// class MainNavigationPage extends StatefulWidget {
//   const MainNavigationPage({super.key});
//
//   @override
//   State<MainNavigationPage> createState() => _MainNavigationPageState();
// }
//
// class _MainNavigationPageState extends State<MainNavigationPage> {
//   int _selectedIndex = 0; // ← 初期ページを「健康記録」に
//
//   final List<Widget> _pages = const [
//     HealthRecordPage(),
//     PostPage(),
//     CalendarPage(),
//   ];
//
//   final List<String> _titles = const [
//     "健康記録",
//     "AI投稿",
//     "カレンダー",
//   ];
//
//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text(_titles[_selectedIndex])),
//       body: _pages[_selectedIndex],
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _selectedIndex,
//         onTap: _onItemTapped,
//         items: const [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.health_and_safety),
//             label: "健康記録",
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.chat),
//             label: "AI投稿",
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.calendar_today),
//             label: "カレンダー",
//           ),
//         ],
//       ),
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
import 'pages/calendar_page.dart';

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
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
        scaffoldBackgroundColor: Colors.blue[50],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.lightBlue[300],
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Colors.lightBlue[600],
          unselectedItemColor: Colors.grey,
          selectedIconTheme: const IconThemeData(size: 28),
          unselectedIconTheme: const IconThemeData(size: 24),
          type: BottomNavigationBarType.fixed,
        ),
      ),
      home: const MainNavigationPage(),
    );
  }
}

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
    CalendarPage(),
    SettingsPage(), // 🔹 追加
  ];

  final List<String> _titles = const [
    "健康記録",
    "AI投稿",
    "カレンダー",
    "設定", // 🔹 追加
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
            icon: Icon(Icons.calendar_today),
            label: "カレンダー",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "設定", // 🔹 追加
          ),
        ],
      ),
    );
  }
}

/// 🔹 設定ページ
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text("⚙️ 設定",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text("ダークモード"),
          value: false,
          onChanged: (value) {
            // TODO: ダークモード切り替え処理
          },
        ),
        ListTile(
          leading: const Icon(Icons.info),
          title: const Text("アプリについて"),
          subtitle: const Text("健康記録アプリ v1.0"),
          onTap: () {},
        ),
      ],
    );
  }
}
