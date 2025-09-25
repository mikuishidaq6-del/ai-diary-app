import 'package:flutter/material.dart';
import '../pages/health_record_page.dart';
import '../pages/post_page.dart';
import '../pages/calendar_page.dart';
import '../widgets/settings_drawer.dart';

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
    "ほっチャ",
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
            label: "ほっチャ",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: "カレンダー",
          ),
        ],
      ),
      endDrawer: const SettingsDrawer(), // 👈 分離したやつ
    );
  }
}
