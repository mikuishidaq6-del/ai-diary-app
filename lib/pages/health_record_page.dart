import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/health_record.dart';
import 'chart_page.dart';

class HealthRecordPage extends StatefulWidget {
  const HealthRecordPage({super.key});
  @override
  _HealthRecordPageState createState() => _HealthRecordPageState();
}

class _HealthRecordPageState extends State<HealthRecordPage> {
  final _temperatureController = TextEditingController();
  final _bloodPressureController = TextEditingController();
  final _pulseController = TextEditingController();
  final _spo2Controller = TextEditingController();
  final _weightController = TextEditingController();
  final _wbcController = TextEditingController();
  final _rbcController = TextEditingController();
  final _plateletsController = TextEditingController();
  final _commentController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  /// 入力フォームをダイアログで表示
  void _showInputDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("新しい記録を追加"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                // 日付と時間の選択
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) {
                            setState(() => _selectedDate = picked);
                          }
                        },
                        child: Text(
                          _selectedDate == null
                              ? "日付を選択"
                              : "${_selectedDate!.year}/${_selectedDate!.month}/${_selectedDate!.day}",
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (picked != null) {
                            setState(() => _selectedTime = picked);
                          }
                        },
                        child: Text(
                          _selectedTime == null
                              ? "時間を選択"
                              : "${_selectedTime!.hour}:${_selectedTime!.minute.toString().padLeft(2, '0')}",
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField(_temperatureController, "体温 (℃)"),
                _buildTextField(_bloodPressureController, "血圧 (mmHg)"),
                _buildTextField(_pulseController, "脈拍 (/分)"),
                _buildTextField(_spo2Controller, "SpO₂ (%)"),
                _buildTextField(_weightController, "体重 (kg)"),
                _buildTextField(_wbcController, "白血球数 (/µL)"),
                _buildTextField(_rbcController, "赤血球数 (/µL)"),
                _buildTextField(_plateletsController, "血小板数 (/µL)"),
                _buildTextField(_commentController, "コメント"),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("キャンセル")),
            ElevatedButton(onPressed: _saveRecord, child: const Text("保存")),
          ],
        );
      },
    );
  }

  /// 保存処理
  void _saveRecord() {
    final temperature = double.tryParse(_temperatureController.text) ?? 0;
    final bloodPressure = double.tryParse(_bloodPressureController.text) ?? 0;
    final pulse = double.tryParse(_pulseController.text) ?? 0;
    final spo2 = double.tryParse(_spo2Controller.text) ?? 0;
    final weight = double.tryParse(_weightController.text) ?? 0;

    // 入力チェック
    if (temperature < 30 || temperature > 45) {
      _showWarning("体温の値が不正です (30〜45℃)");
      return;
    }
    if (bloodPressure < 50 || bloodPressure > 250) {
      _showWarning("血圧の値が不正です (50〜250 mmHg)");
      return;
    }
    if (pulse < 20 || pulse > 250) {
      _showWarning("脈拍の値が不正です (20〜250 /分)");
      return;
    }
    if (spo2 < 50 || spo2 > 100) {
      _showWarning("SpO₂の値が不正です (50〜100%)");
      return;
    }
    if (weight < 2 || weight > 500) {
      _showWarning("体重の値が不正です (2〜500 kg)");
      return;
    }

    final now = DateTime.now();
    final selectedDate = _selectedDate ?? now;
    final selectedTime = _selectedTime ?? TimeOfDay.fromDateTime(now);
    final recordTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    final box = Hive.box<HealthRecord>('records');
    final record = HealthRecord(
      datetime: recordTime,
      temperature: temperature,
      bloodPressure: bloodPressure,
      pulse: pulse,
      spo2: spo2,
      weight: weight,
      wbc: double.tryParse(_wbcController.text) ?? 0,
      rbc: double.tryParse(_rbcController.text) ?? 0,
      platelets: double.tryParse(_plateletsController.text) ?? 0,
      comment: _commentController.text.isEmpty ? "-" : _commentController.text,
    );
    box.add(record);

    _temperatureController.clear();
    _bloodPressureController.clear();
    _pulseController.clear();
    _spo2Controller.clear();
    _weightController.clear();
    _wbcController.clear();
    _rbcController.clear();
    _plateletsController.clear();
    _commentController.clear();

    setState(() {
      _selectedDate = null;
      _selectedTime = null;
    });

    Navigator.pop(context); // 入力ダイアログを閉じる
  }

  void _showWarning(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _editRecordDialog(BuildContext context, int index, HealthRecord record) {
    final tempController = TextEditingController(text: record.temperature.toString());
    final bpController = TextEditingController(text: record.bloodPressure.toString());
    final pulseController = TextEditingController(text: record.pulse.toString());
    final spo2Controller = TextEditingController(text: record.spo2.toString());
    final weightController = TextEditingController(text: record.weight.toString());
    final wbcController = TextEditingController(text: record.wbc.toString());
    final rbcController = TextEditingController(text: record.rbc.toString());
    final plateletsController = TextEditingController(text: record.platelets.toString());
    final commentController = TextEditingController(text: record.comment);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("記録を編集"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextField(tempController, "体温 (℃)"),
                _buildTextField(bpController, "血圧 (mmHg)"),
                _buildTextField(pulseController, "脈拍 (/分)"),
                _buildTextField(spo2Controller, "SpO₂ (%)"),
                _buildTextField(weightController, "体重 (kg)"),
                _buildTextField(wbcController, "白血球数 (/µL)"),
                _buildTextField(rbcController, "赤血球数 (/µL)"),
                _buildTextField(plateletsController, "血小板数 (/µL)"),
                _buildTextField(commentController, "コメント"),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("キャンセル")),
            ElevatedButton(
              onPressed: () {
                final box = Hive.box<HealthRecord>('records');
                final updated = HealthRecord(
                  datetime: record.datetime,
                  temperature: double.tryParse(tempController.text) ?? 0,
                  bloodPressure: double.tryParse(bpController.text) ?? 0,
                  pulse: double.tryParse(pulseController.text) ?? 0,
                  spo2: double.tryParse(spo2Controller.text) ?? 0,
                  weight: double.tryParse(weightController.text) ?? 0,
                  wbc: double.tryParse(wbcController.text) ?? 0,
                  rbc: double.tryParse(rbcController.text) ?? 0,
                  platelets: double.tryParse(plateletsController.text) ?? 0,
                  comment: commentController.text,
                );
                box.putAt(index, updated);
                Navigator.pop(context);
              },
              child: const Text("保存"),
            ),
          ],
        );
      },
    );
  }

  void _openChart(String type, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChartPage(type: type, title: title)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("健康記録")),
      body: Column(
        children: [
          // グラフボタン群だけ残す
          Padding(
            padding: const EdgeInsets.all(8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(onPressed: () => _openChart("temperature", "体温"), child: const Text("体温推移")),
                ElevatedButton(onPressed: () => _openChart("bloodPressure", "血圧"), child: const Text("血圧推移")),
                ElevatedButton(onPressed: () => _openChart("pulse", "脈拍"), child: const Text("脈拍推移")),
                ElevatedButton(onPressed: () => _openChart("spo2", "SpO₂"), child: const Text("SpO₂推移")),
                ElevatedButton(onPressed: () => _openChart("weight", "体重"), child: const Text("体重推移")),
                ElevatedButton(onPressed: () => _openChart("wbc", "白血球数"), child: const Text("白血球数推移")),
                ElevatedButton(onPressed: () => _openChart("rbc", "赤血球数"), child: const Text("赤血球数推移")),
                ElevatedButton(onPressed: () => _openChart("platelets", "血小板数"), child: const Text("血小板数推移")),
              ],
            ),
          ),
          const Divider(),
          const Text("📖 タイムライン", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: Hive.box<HealthRecord>('records').listenable(),
              builder: (context, Box<HealthRecord> box, _) {
                if (box.isEmpty) return const Center(child: Text("データなし"));
                return ListView.builder(
                  itemCount: box.length,
                  itemBuilder: (context, index) {
                    final r = box.getAt(index)!;
                    final dt = r.datetime;
                    final formatted =
                        "${dt.year}/${dt.month}/${dt.day} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
                    return Card(
                      child: ListTile(
                        title: Text(formatted),
                        subtitle: Text(
                          "体温: ${r.temperature == 0 ? '-' : r.temperature}℃\n"
                              "血圧: ${r.bloodPressure == 0 ? '-' : r.bloodPressure} mmHg\n"
                              "脈拍: ${r.pulse == 0 ? '-' : r.pulse} /分\n"
                              "SpO₂: ${r.spo2 == 0 ? '-' : r.spo2}%\n"
                              "体重: ${r.weight == 0 ? '-' : r.weight} kg\n"
                              "白血球数: ${r.wbc == 0 ? '-' : r.wbc}\n"
                              "赤血球数: ${r.rbc == 0 ? '-' : r.rbc}\n"
                              "血小板数: ${r.platelets == 0 ? '-' : r.platelets}\n"
                              "コメント: ${r.comment}",
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _editRecordDialog(context, index, r),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text("削除確認"),
                                    content: const Text("この記録を削除しますか？"),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("キャンセル")),
                                      ElevatedButton(
                                        onPressed: () {
                                          final box = Hive.box<HealthRecord>('records');
                                          box.deleteAt(index);
                                          Navigator.pop(ctx);
                                        },
                                        child: const Text("削除"),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showInputDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(border: const OutlineInputBorder(), labelText: label),
        keyboardType: TextInputType.number,
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:hive/hive.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'post_page.dart';
// import '../models/health_record.dart';
// import 'calendar_page.dart';
// import 'chart_page.dart';
//
// class HealthRecordPage extends StatefulWidget {
//   const HealthRecordPage({super.key});
//   @override
//   _HealthRecordPageState createState() => _HealthRecordPageState();
// }
//
// class _HealthRecordPageState extends State<HealthRecordPage> {
//   final _temperatureController = TextEditingController();
//   final _bloodPressureController = TextEditingController();
//   final _pulseController = TextEditingController();
//   final _spo2Controller = TextEditingController();
//   final _weightController = TextEditingController();
//   final _wbcController = TextEditingController();
//   final _rbcController = TextEditingController();
//   final _plateletsController = TextEditingController();
//   final _commentController = TextEditingController();
//
//   DateTime? _selectedDate;
//   TimeOfDay? _selectedTime;
//
//   /// 入力フォームの表示
//   void _showInputDialog() {
//     showDialog(
//       context: context,
//       builder: (ctx) {
//         return AlertDialog(
//           title: const Text("新しい記録を追加"),
//           content: SingleChildScrollView(
//             child: Column(
//               children: [
//                 // 日付・時間選択
//                 Row(
//                   children: [
//                     Expanded(
//                       child: OutlinedButton(
//                         onPressed: () async {
//                           final picked = await showDatePicker(
//                             context: context,
//                             initialDate: DateTime.now(),
//                             firstDate: DateTime(2020),
//                             lastDate: DateTime(2030),
//                           );
//                           if (picked != null) {
//                             setState(() => _selectedDate = picked);
//                           }
//                         },
//                         child: Text(
//                           _selectedDate == null
//                               ? "日付を選択"
//                               : "${_selectedDate!.year}/${_selectedDate!.month}/${_selectedDate!.day}",
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: OutlinedButton(
//                         onPressed: () async {
//                           final picked = await showTimePicker(
//                             context: context,
//                             initialTime: TimeOfDay.now(),
//                           );
//                           if (picked != null) {
//                             setState(() => _selectedTime = picked);
//                           }
//                         },
//                         child: Text(
//                           _selectedTime == null
//                               ? "時間を選択"
//                               : "${_selectedTime!.hour}:${_selectedTime!.minute.toString().padLeft(2, '0')}",
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 16),
//                 _buildTextField(_temperatureController, "体温 (℃)"),
//                 _buildTextField(_bloodPressureController, "血圧 (mmHg)"),
//                 _buildTextField(_pulseController, "脈拍 (/分)"),
//                 _buildTextField(_spo2Controller, "SpO₂ (%)"),
//                 _buildTextField(_weightController, "体重 (kg)"),
//                 _buildTextField(_wbcController, "白血球数 (/µL)"),
//                 _buildTextField(_rbcController, "赤血球数 (/µL)"),
//                 _buildTextField(_plateletsController, "血小板数 (/µL)"),
//                 _buildTextField(_commentController, "コメント"),
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("キャンセル")),
//             ElevatedButton(onPressed: _saveRecord, child: const Text("保存")),
//           ],
//         );
//       },
//     );
//   }
//
//   /// 保存処理
//   void _saveRecord() {
//     final temperature = double.tryParse(_temperatureController.text) ?? 0;
//     final bloodPressure = double.tryParse(_bloodPressureController.text) ?? 0;
//     final pulse = double.tryParse(_pulseController.text) ?? 0;
//     final spo2 = double.tryParse(_spo2Controller.text) ?? 0;
//     final weight = double.tryParse(_weightController.text) ?? 0;
//
//     // 入力チェック
//     if (temperature < 30 || temperature > 45) {
//       _showWarning("体温の値が不正です (30〜45℃)");
//       return;
//     }
//     if (bloodPressure < 50 || bloodPressure > 250) {
//       _showWarning("血圧の値が不正です (50〜250 mmHg)");
//       return;
//     }
//     if (pulse < 20 || pulse > 250) {
//       _showWarning("脈拍の値が不正です (20〜250 /分)");
//       return;
//     }
//     if (spo2 < 50 || spo2 > 100) {
//       _showWarning("SpO₂の値が不正です (50〜100%)");
//       return;
//     }
//     if (weight < 2 || weight > 500) {
//       _showWarning("体重の値が不正です (2〜500 kg)");
//       return;
//     }
//
//     final now = DateTime.now();
//     final selectedDate = _selectedDate ?? now;
//     final selectedTime = _selectedTime ?? TimeOfDay.fromDateTime(now);
//     final recordTime = DateTime(
//       selectedDate.year,
//       selectedDate.month,
//       selectedDate.day,
//       selectedTime.hour,
//       selectedTime.minute,
//     );
//
//     final box = Hive.box<HealthRecord>('records');
//     final record = HealthRecord(
//       datetime: recordTime,
//       temperature: temperature,
//       bloodPressure: bloodPressure,
//       pulse: pulse,
//       spo2: spo2,
//       weight: weight,
//       wbc: double.tryParse(_wbcController.text) ?? 0,
//       rbc: double.tryParse(_rbcController.text) ?? 0,
//       platelets: double.tryParse(_plateletsController.text) ?? 0,
//       comment: _commentController.text.isEmpty ? "-" : _commentController.text,
//     );
//     box.add(record);
//
//     _temperatureController.clear();
//     _bloodPressureController.clear();
//     _pulseController.clear();
//     _spo2Controller.clear();
//     _weightController.clear();
//     _wbcController.clear();
//     _rbcController.clear();
//     _plateletsController.clear();
//     _commentController.clear();
//
//     setState(() {
//       _selectedDate = null;
//       _selectedTime = null;
//     });
//
//     Navigator.pop(context); // ダイアログを閉じる
//   }
//
//   void _showWarning(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message), backgroundColor: Colors.red),
//     );
//   }
//
//   void _editRecordDialog(BuildContext context, int index, HealthRecord record) {
//     final tempController = TextEditingController(text: record.temperature.toString());
//     final bpController = TextEditingController(text: record.bloodPressure.toString());
//     final pulseController = TextEditingController(text: record.pulse.toString());
//     final spo2Controller = TextEditingController(text: record.spo2.toString());
//     final weightController = TextEditingController(text: record.weight.toString());
//     final wbcController = TextEditingController(text: record.wbc.toString());
//     final rbcController = TextEditingController(text: record.rbc.toString());
//     final plateletsController = TextEditingController(text: record.platelets.toString());
//     final commentController = TextEditingController(text: record.comment);
//
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text("記録を編集"),
//           content: SingleChildScrollView(
//             child: Column(
//               children: [
//                 _buildTextField(tempController, "体温 (℃)"),
//                 _buildTextField(bpController, "血圧 (mmHg)"),
//                 _buildTextField(pulseController, "脈拍 (/分)"),
//                 _buildTextField(spo2Controller, "SpO₂ (%)"),
//                 _buildTextField(weightController, "体重 (kg)"),
//                 _buildTextField(wbcController, "白血球数 (/µL)"),
//                 _buildTextField(rbcController, "赤血球数 (/µL)"),
//                 _buildTextField(plateletsController, "血小板数 (/µL)"),
//                 _buildTextField(commentController, "コメント"),
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(onPressed: () => Navigator.pop(context), child: const Text("キャンセル")),
//             ElevatedButton(
//               onPressed: () {
//                 final box = Hive.box<HealthRecord>('records');
//                 final updated = HealthRecord(
//                   datetime: record.datetime,
//                   temperature: double.tryParse(tempController.text) ?? 0,
//                   bloodPressure: double.tryParse(bpController.text) ?? 0,
//                   pulse: double.tryParse(pulseController.text) ?? 0,
//                   spo2: double.tryParse(spo2Controller.text) ?? 0,
//                   weight: double.tryParse(weightController.text) ?? 0,
//                   wbc: double.tryParse(wbcController.text) ?? 0,
//                   rbc: double.tryParse(rbcController.text) ?? 0,
//                   platelets: double.tryParse(plateletsController.text) ?? 0,
//                   comment: commentController.text,
//                 );
//                 box.putAt(index, updated);
//                 Navigator.pop(context);
//               },
//               child: const Text("保存"),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   void _openChart(String type, String title) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => ChartPage(type: type, title: title)),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("健康記録")),
//       body: Column(
//         children: [
//           // グラフや別ページへの遷移ボタン
//           Padding(
//             padding: const EdgeInsets.all(8),
//             child: Wrap(
//               spacing: 8,
//               runSpacing: 8,
//               children: [
//                 ElevatedButton(onPressed: () => _openChart("temperature", "体温"), child: const Text("体温推移")),
//                 ElevatedButton(onPressed: () => _openChart("bloodPressure", "血圧"), child: const Text("血圧推移")),
//                 ElevatedButton(onPressed: () => _openChart("pulse", "脈拍"), child: const Text("脈拍推移")),
//                 ElevatedButton(onPressed: () => _openChart("spo2", "SpO₂"), child: const Text("SpO₂推移")),
//                 ElevatedButton(onPressed: () => _openChart("weight", "体重"), child: const Text("体重推移")),
//                 ElevatedButton(onPressed: () => _openChart("wbc", "白血球数"), child: const Text("白血球数推移")),
//                 ElevatedButton(onPressed: () => _openChart("rbc", "赤血球数"), child: const Text("赤血球数推移")),
//                 ElevatedButton(onPressed: () => _openChart("platelets", "血小板数"), child: const Text("血小板数推移")),
//                 ElevatedButton(
//                   onPressed: () {
//                     Navigator.push(context, MaterialPageRoute(builder: (_) => const CalendarPage()));
//                   },
//                   child: const Text("カレンダーを見る"),
//                 ),
//                 ElevatedButton(
//                   onPressed: () {
//                     Navigator.push(context, MaterialPageRoute(builder: (_) => const PostPage()));
//                   },
//                   child: const Text("AI投稿ページへ"),
//                 ),
//               ],
//             ),
//           ),
//           const Divider(),
//           const Text("📖 タイムライン", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//           Expanded(
//             child: ValueListenableBuilder(
//               valueListenable: Hive.box<HealthRecord>('records').listenable(),
//               builder: (context, Box<HealthRecord> box, _) {
//                 if (box.isEmpty) return const Center(child: Text("データなし"));
//                 return ListView.builder(
//                   itemCount: box.length,
//                   itemBuilder: (context, index) {
//                     final r = box.getAt(index)!;
//                     final dt = r.datetime;
//                     final formatted =
//                         "${dt.year}/${dt.month}/${dt.day} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
//                     return Card(
//                       child: ListTile(
//                         title: Text(formatted),
//                         subtitle: Text(
//                           "体温: ${r.temperature == 0 ? "-" : r.temperature}℃\n"
//                               "血圧: ${r.bloodPressure == 0 ? "-" : r.bloodPressure} mmHg\n"
//                               "脈拍: ${r.pulse == 0 ? "-" : r.pulse} /分\n"
//                               "SpO₂: ${r.spo2 == 0 ? "-" : r.spo2}%\n"
//                               "体重: ${r.weight == 0 ? "-" : r.weight} kg\n"
//                               "白血球数: ${r.wbc == 0 ? "-" : r.wbc}\n"
//                               "赤血球数: ${r.rbc == 0 ? "-" : r.rbc}\n"
//                               "血小板数: ${r.platelets == 0 ? "-" : r.platelets}\n"
//                               "コメント: ${r.comment}",
//                         ),
//                         trailing: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             IconButton(
//                               icon: const Icon(Icons.edit),
//                               onPressed: () => _editRecordDialog(context, index, r),
//                             ),
//                             IconButton(
//                               icon: const Icon(Icons.delete, color: Colors.red),
//                               onPressed: () {
//                                 showDialog(
//                                   context: context,
//                                   builder: (ctx) => AlertDialog(
//                                     title: const Text("削除確認"),
//                                     content: const Text("この記録を削除しますか？"),
//                                     actions: [
//                                       TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("キャンセル")),
//                                       ElevatedButton(
//                                         onPressed: () {
//                                           final box = Hive.box<HealthRecord>('records');
//                                           box.deleteAt(index);
//                                           Navigator.pop(ctx);
//                                         },
//                                         child: const Text("削除"),
//                                       ),
//                                     ],
//                                   ),
//                                 );
//                               },
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _showInputDialog,
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
//
//   Widget _buildTextField(TextEditingController controller, String label) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6),
//       child: TextField(
//         controller: controller,
//         decoration: InputDecoration(border: const OutlineInputBorder(), labelText: label),
//         keyboardType: TextInputType.number,
//       ),
//     );
//   }
// }
