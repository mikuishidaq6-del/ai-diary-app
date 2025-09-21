import 'package:flutter/material.dart';

class RecordListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('記録一覧', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF4A6466),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              // 通知画面への遷移
            },
          ),
          IconButton(
            icon: Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              // 設定画面への遷移
            },
          ),
        ],
      ),
      body: Container(
        color: Color(0xFFFFFFFF),
        child: ListView(
          children: [
            Card(
              margin: EdgeInsets.all(16),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '2025/9/5',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF000000)),
                    ),
                    SizedBox(height: 8),
                    Text('今日は調子が良かった。...', style: TextStyle(color: Color(0xFF4A6466))),
                    SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        // 健康共機画面への遷移
                      },
                      child: Text('↓健康共機を見る', style: TextStyle(color: Color(0xFF81A6A8))),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFFFFFFFF),
        selectedItemColor: Color(0xFF81A6A8),
        unselectedItemColor: Color(0xFF4A6466),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: '',
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: RecordListScreen(),
  ));
}