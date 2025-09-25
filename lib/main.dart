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

/// 🔹 下タブで3ページ切り替え + 右側設定ドロワー
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
  ];

  final List<String> _titles = const [
    "健康記録",
    "AI投稿",
    "カレンダー",
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        actions: [
          // ✅ Builderを使って正しいcontextを取る
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
            ),
          ),
        ],
      ),

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
        ],
      ),

      /// ✅ 右から出る設定ドロワー
      endDrawer: Drawer(
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
      ),
    );
  }
}
