// import 'package:flutter/material.dart';
// import 'package:table_calendar/table_calendar.dart';
// import 'package:hive/hive.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import '../models/health_record.dart';
//
// class CalendarPage extends StatefulWidget {
//   const CalendarPage({super.key});
//
//   @override
//   State<CalendarPage> createState() => _CalendarPageState();
// }
//
// class _CalendarPageState extends State<CalendarPage> {
//   DateTime _focusedDay = DateTime.now();
//   DateTime? _selectedDay;
//
//   @override
//   Widget build(BuildContext context) {
//     final box = Hive.box<HealthRecord>('records');
//
//     return Scaffold(
//       appBar: AppBar(title: const Text("カレンダー")),
//       body: Column(
//         children: [
//           TableCalendar(
//             firstDay: DateTime.utc(2020, 1, 1),
//             lastDay: DateTime.utc(2030, 12, 31),
//             focusedDay: _focusedDay,
//             selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
//             onDaySelected: (selectedDay, focusedDay) {
//               setState(() {
//                 _selectedDay = selectedDay;
//                 _focusedDay = focusedDay;
//               });
//             },
//             calendarFormat: CalendarFormat.month,
//           ),
//           const Divider(),
//           Expanded(
//             child: ValueListenableBuilder(
//               valueListenable: box.listenable(),
//               builder: (context, Box<HealthRecord> box, _) {
//                 final records = box.values.where((record) {
//                   if (_selectedDay == null) return false;
//                   return record.datetime.year == _selectedDay!.year &&
//                       record.datetime.month == _selectedDay!.month &&
//                       record.datetime.day == _selectedDay!.day;
//                 }).toList();
//
//                 if (records.isEmpty) {
//                   return const Center(child: Text("この日には記録がありません"));
//                 }
//
//                 return ListView.builder(
//                   itemCount: records.length,
//                   itemBuilder: (context, index) {
//                     final r = records[index];
//                     return Card(
//                       child: ListTile(
//                         title: Text(
//                           "${r.datetime.hour}:${r.datetime.minute.toString().padLeft(2, '0')}",
//                         ),
//                         subtitle: Text(
//                           "体温: ${r.temperature}℃ / 血圧: ${r.bloodPressure} / 脈拍: ${r.pulse}",
//                         ),
//                         onTap: () {
//                           showDialog(
//                             context: context,
//                             builder: (ctx) {
//                               return AlertDialog(
//                                 title: Text(
//                                   "${r.datetime.year}/${r.datetime.month}/${r.datetime.day} "
//                                       "${r.datetime.hour}:${r.datetime.minute.toString().padLeft(2, '0')}",
//                                 ),
//                                 content: Column(
//                                   mainAxisSize: MainAxisSize.min,
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text("体温: ${r.temperature} ℃"),
//                                     Text("血圧: ${r.bloodPressure} mmHg"),
//                                     Text("脈拍: ${r.pulse} /分"),
//                                     Text("SpO₂: ${r.spo2} %"),
//                                     Text("体重: ${r.weight} kg"),
//                                     Text("白血球数: ${r.wbc}"),
//                                     Text("赤血球数: ${r.rbc}"),
//                                     Text("血小板数: ${r.platelets}"),
//                                     const SizedBox(height: 8),
//                                     Text("コメント: ${r.comment}"),
//                                   ],
//                                 ),
//                                 actions: [
//                                   TextButton(
//                                     onPressed: () => Navigator.pop(ctx),
//                                     child: const Text("閉じる"),
//                                   ),
//                                 ],
//                               );
//                             },
//                           );
//                         },
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/health_record.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<HealthRecord>('records');

    return Scaffold(
      appBar: AppBar(title: const Text("カレンダー")),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box<HealthRecord> box, _) {
          // 🔹 日ごとの記録をマップにまとめる
          final Map<DateTime, List<HealthRecord>> events = {};
          for (var record in box.values) {
            final day = DateTime(record.datetime.year, record.datetime.month, record.datetime.day);
            events.putIfAbsent(day, () => []);
            events[day]!.add(record);
          }

          return Column(
            children: [
              TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                calendarFormat: CalendarFormat.month,

                // 🔹 その日のイベントを返す
                eventLoader: (day) {
                  return events[DateTime(day.year, day.month, day.day)] ?? [];
                },

                // 🔹 色付けカスタム
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, day, events) {
                    if (events.isNotEmpty) {
                      return Positioned(
                        bottom: 1,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.lightBlue, // 記録がある日は水色の点
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    }
                    return null;
                  },
                  // 選択日を水色でハイライト
                  selectedBuilder: (context, day, focusedDay) {
                    return Container(
                      margin: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '${day.day}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const Divider(),
              Expanded(
                child: Builder(
                  builder: (context) {
                    final records = box.values.where((record) {
                      if (_selectedDay == null) return false;
                      return record.datetime.year == _selectedDay!.year &&
                          record.datetime.month == _selectedDay!.month &&
                          record.datetime.day == _selectedDay!.day;
                    }).toList();

                    if (records.isEmpty) {
                      return const Center(child: Text("この日には記録がありません"));
                    }

                    return ListView.builder(
                      itemCount: records.length,
                      itemBuilder: (context, index) {
                        final r = records[index];
                        return Card(
                          child: ListTile(
                            title: Text(
                              "${r.datetime.hour}:${r.datetime.minute.toString().padLeft(2, '0')}",
                            ),
                            subtitle: Text(
                              "体温: ${r.temperature}℃ / 血圧: ${r.bloodPressure} / 脈拍: ${r.pulse}",
                            ),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (ctx) {
                                  return AlertDialog(
                                    title: Text(
                                      "${r.datetime.year}/${r.datetime.month}/${r.datetime.day} "
                                          "${r.datetime.hour}:${r.datetime.minute.toString().padLeft(2, '0')}",
                                    ),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("体温: ${r.temperature} ℃"),
                                        Text("血圧: ${r.bloodPressure} mmHg"),
                                        Text("脈拍: ${r.pulse} /分"),
                                        Text("SpO₂: ${r.spo2} %"),
                                        Text("体重: ${r.weight} kg"),
                                        Text("白血球数: ${r.wbc}"),
                                        Text("赤血球数: ${r.rbc}"),
                                        Text("血小板数: ${r.platelets}"),
                                        const SizedBox(height: 8),
                                        Text("コメント: ${r.comment}"),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx),
                                        child: const Text("閉じる"),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
