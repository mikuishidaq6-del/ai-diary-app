import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/health_record.dart';

class ChartPage extends StatefulWidget {
  final String type;
  final String title;

  const ChartPage({super.key, required this.type, required this.title});

  @override
  State<ChartPage> createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
  String _selectedRange = "全期間";
  final List<String> _ranges = ["1か月", "3か月", "6か月", "1年", "全期間"];

  List<HealthRecord> _filterRecords(List<HealthRecord> records) {
    if (records.isEmpty) return [];
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

  double _getValue(HealthRecord r) {
    switch (widget.type) {
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
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${widget.title} の推移")),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<HealthRecord>('records').listenable(),
        builder: (context, Box<HealthRecord> box, _) {
          final records = _filterRecords(box.values.toList());
          final spots = <FlSpot>[];
          for (int i = 0; i < records.length; i++) {
            final value = _getValue(records[i]);
            spots.add(FlSpot(i.toDouble(), value));
          }

          return Column(
            children: [
              Wrap(
                spacing: 8,
                children: _ranges.map((range) {
                  return ChoiceChip(
                    label: Text(range),
                    selected: _selectedRange == range,
                    onSelected: (_) {
                      setState(() => _selectedRange = range);
                    },
                  );
                }).toList(),
              ),
              Expanded(
                child: spots.isEmpty
                    ? const Center(child: Text("データがありません"))
                    : LineChart(
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
                              return Text("${dt.month}/${dt.day}");
                            }
                            return const Text("");
                          },
                        ),
                      ),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        barWidth: 3,
                        color: Colors.blue,
                        dotData: FlDotData(show: true),
                      )
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
