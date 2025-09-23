import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/health_record.dart';

class ChartPage extends StatefulWidget {
  const ChartPage({super.key});

  @override
  State<ChartPage> createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedRange = "全期間";

  final List<Map<String, String>> _tabs = [
    {"type": "temperature", "title": "体温"},
    {"type": "bloodPressure", "title": "血圧"},
    {"type": "pulse", "title": "脈拍"},
    {"type": "spo2", "title": "SpO₂"},
    {"type": "weight", "title": "体重"},
    {"type": "wbc", "title": "白血球数"},
    {"type": "rbc", "title": "赤血球数"},
    {"type": "platelets", "title": "血小板数"},
  ];

  final List<String> _ranges = ["1か月", "3か月", "6か月", "1年", "全期間"];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  List<HealthRecord> _filterRecords(List<HealthRecord> records) {
    if (_selectedRange == "全期間") return records;

    DateTime now = DateTime.now();
    DateTime cutoff;

    switch (_selectedRange) {
      case "1か月":
        cutoff = DateTime(now.year, now.month - 1, now.day);
        break;
      case "3か月":
        cutoff = DateTime(now.year, now.month - 3, now.day);
        break;
      case "6か月":
        cutoff = DateTime(now.year, now.month - 6, now.day);
        break;
      case "1年":
        cutoff = DateTime(now.year - 1, now.month, now.day);
        break;
      default:
        return records;
    }
    return records.where((r) => r.datetime.isAfter(cutoff)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F8FF),
      appBar: AppBar(
        backgroundColor: Colors.lightBlue[300],
        centerTitle: true, // 🔹 タイトルを中央に
        title: Row(
          mainAxisSize: MainAxisSize.min, // 🔹 Row全体を最小サイズにして中央寄せ
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(6),
              child: Icon(Icons.show_chart, color: Colors.lightBlue[700], size: 24),
            ),
            const SizedBox(width: 8),
            const Text(
              "健康グラフ",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.lightBlue,
              indicator: BoxDecoration(
                color: Colors.lightBlue[400],
                borderRadius: BorderRadius.circular(20),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: _tabs
                  .map((t) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Text(t["title"]!, style: const TextStyle(fontSize: 14)),
              ))
                  .toList(),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // 🔹 期間フィルター
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Wrap(
              spacing: 8,
              children: _ranges.map((range) {
                return ChoiceChip(
                  label: Text(range),
                  selected: _selectedRange == range,
                  selectedColor: Colors.lightBlue[200],
                  onSelected: (_) {
                    setState(() {
                      _selectedRange = range;
                    });
                  },
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _tabs.map((t) {
                return _buildChart(t["type"]!, t["title"]!);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(String type, String title) {
    return ValueListenableBuilder(
      valueListenable: Hive.box<HealthRecord>('records').listenable(),
      builder: (context, Box<HealthRecord> box, _) {
        final allRecords = box.values.toList();
        final records = _filterRecords(allRecords);

        final spots = <FlSpot>[];
        double? lastValue; // 🔹 前の値を保存
        for (int i = 0; i < records.length; i++) {
          final value = _getValue(records[i], type);
          if (value != null && value > 0) {
            lastValue = value; // 入力あり → 更新
            spots.add(FlSpot(i.toDouble(), value));
          } else if (lastValue != null) {
            // 入力なし → 前の値を使って線をつなぐ
            spots.add(FlSpot(i.toDouble(), lastValue));
          }
        }

        if (spots.isEmpty) {
          return const Center(
            child: Text(
              "データがありません 🐣",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: LineChart(
                LineChartData(
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          int idx = value.toInt();
                          if (idx >= 0 && idx < records.length) {
                            final dt = records[idx].datetime;
                            return Text("${dt.month}/${dt.day}",
                                style: const TextStyle(fontSize: 10));
                          }
                          return const Text("");
                        },
                      ),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: false,
                      barWidth: 3,
                      color: Colors.lightBlue,
                      dotData: FlDotData(show: true),
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  double? _getValue(HealthRecord r, String type) {
    switch (type) {
      case "temperature":
        return r.temperature;
      case "bloodPressure":
        return r.bloodPressure;
      case "pulse":
        return r.pulse;
      case "spo2":
        return r.spo2;
      case "weight":
        return r.weight;
      case "wbc":
        return r.wbc;
      case "rbc":
        return r.rbc;
      case "platelets":
        return r.platelets;
      default:
        return null;
    }
  }
}
