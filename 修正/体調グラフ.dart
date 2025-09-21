import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class HealthGraphScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('体調グラフ', style: TextStyle(color: Colors.white)),
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
        padding: EdgeInsets.all(16),
        child: LineChart(
          LineChartData(
            gridData: FlGridData(show: false),
            titlesData: FlTitlesData(show: true),
            borderData: FlBorderData(show: true),
            lineBarsData: [
              LineChartBarData(
                spots: [
                  FlSpot(23, 30),
                  FlSpot(24, 35),
                  FlSpot(25, 40),
                  FlSpot(26, 45),
                  FlSpot(27, 50),
                ],
                isCurved: true,
                colors: [Color(0xFF81A6A8)],
                barWidth: 4,
                isStrokeCapRound: true,
              ),
            ],
          ),
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
    home: HealthGraphScreen(),
  ));
}