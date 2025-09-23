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

  String? _errorMessage;

  /// 共通バリデーション
  bool _validateInputs({
    double? temperature,
    double? bloodPressure,
    double? pulse,
    double? spo2,
    double? weight,
  }) {
    if (temperature != null && (temperature < 30 || temperature > 45)) {
      _errorMessage = "⚠️ 体温の値が不正です (30〜45℃)";
      return false;
    }
    if (bloodPressure != null && (bloodPressure < 50 || bloodPressure > 250)) {
      _errorMessage = "⚠️ 血圧の値が不正です (50〜250 mmHg)";
      return false;
    }
    if (pulse != null && (pulse < 20 || pulse > 250)) {
      _errorMessage = "⚠️ 脈拍の値が不正です (20〜250 /分)";
      return false;
    }
    if (spo2 != null && (spo2 < 50 || spo2 > 100)) {
      _errorMessage = "⚠️ SpO₂の値が不正です (50〜100 %)";
      return false;
    }
    if (weight != null && (weight < 2 || weight > 500)) {
      _errorMessage = "⚠️ 体重の値が不正です (2〜500 kg)";
      return false;
    }
    _errorMessage = null;
    return true;
  }

  /// 入力フォームを表示
  void _showInputDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        String? localErrorMessage;
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: const [
                  Icon(Icons.add_circle_outline, color: Colors.orangeAccent), // ロゴ風プラスアイコン
                  SizedBox(width: 8),
                  Text(
                    "新しい記録を追加",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTextField(_temperatureController, "体温 (℃)", Icons.thermostat),
                    _buildTextField(_bloodPressureController, "血圧 (mmHg)", Icons.favorite),
                    _buildTextField(_pulseController, "脈拍 (/分)", Icons.monitor_heart),
                    _buildTextField(_spo2Controller, "SpO₂ (%)", Icons.bloodtype),
                    _buildTextField(_weightController, "体重 (kg)", Icons.monitor_weight),
                    _buildTextField(_wbcController, "白血球数 (/µL)", Icons.biotech),
                    _buildTextField(_rbcController, "赤血球数 (/µL)", Icons.bloodtype_outlined),
                    _buildTextField(_plateletsController, "血小板数 (/µL)", Icons.opacity),
                    _buildTextField(_commentController, "コメント", Icons.edit_note, isNumber: false),
                    const SizedBox(height: 8),
                    if (localErrorMessage != null)
                      Text(localErrorMessage!,
                          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  style: TextButton.styleFrom(foregroundColor: Colors.grey),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("キャンセル"),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text("保存"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlueAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    final isAllEmpty = _temperatureController.text.isEmpty &&
                        _bloodPressureController.text.isEmpty &&
                        _pulseController.text.isEmpty &&
                        _spo2Controller.text.isEmpty &&
                        _weightController.text.isEmpty &&
                        _wbcController.text.isEmpty &&
                        _rbcController.text.isEmpty &&
                        _plateletsController.text.isEmpty &&
                        _commentController.text.isEmpty;

                    if (isAllEmpty) {
                      setStateDialog(() {
                        localErrorMessage = "⚠️ 1つ以上の項目を入力してください";
                      });
                      return;
                    }

                    final temp = double.tryParse(_temperatureController.text);
                    final bp = double.tryParse(_bloodPressureController.text);
                    final pulse = double.tryParse(_pulseController.text);
                    final spo2 = double.tryParse(_spo2Controller.text);
                    final weight = double.tryParse(_weightController.text);

                    if (!_validateInputs(
                      temperature: temp,
                      bloodPressure: bp,
                      pulse: pulse,
                      spo2: spo2,
                      weight: weight,
                    )) {
                      setStateDialog(() {
                        localErrorMessage = _errorMessage;
                      });
                      return;
                    }

                    _saveRecord();
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// 保存処理
  void _saveRecord() {
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
      temperature: _temperatureController.text.isEmpty ? null : double.tryParse(_temperatureController.text),
      bloodPressure: _bloodPressureController.text.isEmpty ? null : double.tryParse(_bloodPressureController.text),
      pulse: _pulseController.text.isEmpty ? null : double.tryParse(_pulseController.text),
      spo2: _spo2Controller.text.isEmpty ? null : double.tryParse(_spo2Controller.text),
      weight: _weightController.text.isEmpty ? null : double.tryParse(_weightController.text),
      wbc: _wbcController.text.isEmpty ? null : double.tryParse(_wbcController.text),
      rbc: _rbcController.text.isEmpty ? null : double.tryParse(_rbcController.text),
      platelets: _plateletsController.text.isEmpty ? null : double.tryParse(_plateletsController.text),
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
      _errorMessage = null;
    });
  }

  /// 編集ダイアログ
  void _editRecordDialog(BuildContext context, int index, HealthRecord record) {
    final tempController = TextEditingController(text: record.temperature?.toString() ?? "");
    final bpController = TextEditingController(text: record.bloodPressure?.toString() ?? "");
    final pulseController = TextEditingController(text: record.pulse?.toString() ?? "");
    final spo2Controller = TextEditingController(text: record.spo2?.toString() ?? "");
    final weightController = TextEditingController(text: record.weight?.toString() ?? "");
    final wbcController = TextEditingController(text: record.wbc?.toString() ?? "");
    final rbcController = TextEditingController(text: record.rbc?.toString() ?? "");
    final plateletsController = TextEditingController(text: record.platelets?.toString() ?? "");
    final commentController = TextEditingController(text: record.comment);

    showDialog(
      context: context,
      builder: (context) {
        String? localErrorMessage;
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text("✏️ 記録を編集"),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildTextField(tempController, "体温 (℃)", Icons.thermostat),
                    _buildTextField(bpController, "血圧 (mmHg)", Icons.favorite),
                    _buildTextField(pulseController, "脈拍 (/分)", Icons.monitor_heart),
                    _buildTextField(spo2Controller, "SpO₂ (%)", Icons.bloodtype),
                    _buildTextField(weightController, "体重 (kg)", Icons.monitor_weight),
                    _buildTextField(wbcController, "白血球数 (/µL)", Icons.biotech),
                    _buildTextField(rbcController, "赤血球数 (/µL)", Icons.bloodtype_outlined),
                    _buildTextField(plateletsController, "血小板数 (/µL)", Icons.opacity),
                    _buildTextField(commentController, "コメント", Icons.edit_note, isNumber: false),
                    const SizedBox(height: 8),
                    if (localErrorMessage != null)
                      Text(localErrorMessage!,
                          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text("キャンセル")),
                ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text("保存"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.lightBlueAccent),
                  onPressed: () {
                    final temp = double.tryParse(tempController.text);
                    final bp = double.tryParse(bpController.text);
                    final pulse = double.tryParse(pulseController.text);
                    final spo2 = double.tryParse(spo2Controller.text);
                    final weight = double.tryParse(weightController.text);

                    if (!_validateInputs(
                      temperature: temp,
                      bloodPressure: bp,
                      pulse: pulse,
                      spo2: spo2,
                      weight: weight,
                    )) {
                      setStateDialog(() {
                        localErrorMessage = _errorMessage;
                      });
                      return;
                    }

                    final box = Hive.box<HealthRecord>('records');
                    final updated = HealthRecord(
                      datetime: record.datetime,
                      temperature: temp,
                      bloodPressure: bp,
                      pulse: pulse,
                      spo2: spo2,
                      weight: weight,
                      wbc: double.tryParse(wbcController.text),
                      rbc: double.tryParse(rbcController.text),
                      platelets: double.tryParse(plateletsController.text),
                      comment: commentController.text.isEmpty ? "-" : commentController.text,
                    );
                    box.putAt(index, updated);
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      body: Column(
        children: [
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.menu_book, color: Colors.blueAccent, size: 28), // 本のロゴ風アイコン
              SizedBox(width: 8),
              Text(
                "タイムライン",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueAccent),
              ),
            ],
          ),

          Expanded(
            child: ValueListenableBuilder(
              valueListenable: Hive.box<HealthRecord>('records').listenable(),
              builder: (context, Box<HealthRecord> box, _) {
                if (box.isEmpty) {
                  return const Center(child: Text("まだデータがありません", style: TextStyle(color: Colors.grey)));
                }
                return ListView.builder(
                  itemCount: box.length,
                  itemBuilder: (context, index) {
                    final r = box.getAt(index)!;
                    final dt = r.datetime;
                    final formatted =
                        "${dt.year}/${dt.month}/${dt.day} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.calendar_today, color: Colors.blueAccent),
                                const SizedBox(width: 6),
                                Text(formatted,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue)),
                              ],
                            ),
                            const Divider(),
                            _buildRecordRow(Icons.thermostat, "体温",
                                r.temperature != null ? "${r.temperature} ℃" : "-"),
                            _buildRecordRow(Icons.favorite, "血圧",
                                r.bloodPressure != null ? "${r.bloodPressure} mmHg" : "-"),
                            _buildRecordRow(Icons.monitor_heart, "脈拍",
                                r.pulse != null ? "${r.pulse} /分" : "-"),
                            _buildRecordRow(Icons.air, "SpO₂",
                                r.spo2 != null ? "${r.spo2} %" : "-"),
                            _buildRecordRow(Icons.monitor_weight, "体重",
                                r.weight != null ? "${r.weight} kg" : "-"),
                            _buildRecordRow(Icons.science, "白血球数",
                                r.wbc != null ? "${r.wbc}" : "-"),
                            _buildRecordRow(Icons.bloodtype, "赤血球数",
                                r.rbc != null ? "${r.rbc}" : "-"),
                            _buildRecordRow(Icons.biotech, "血小板数",
                                r.platelets != null ? "${r.platelets}" : "-"),
                            _buildRecordRow(Icons.comment, "コメント",
                                r.comment.isNotEmpty ? r.comment : "-"),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.green),
                                    onPressed: () => _editRecordDialog(context, index, r)),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    final box = Hive.box<HealthRecord>('records');
                                    box.deleteAt(index);
                                  },
                                ),
                              ],
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
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "addBtn",
            backgroundColor: Colors.pinkAccent,
            onPressed: _showInputDialog,
            child: const Icon(Icons.add),
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            heroTag: "graphBtn",
            backgroundColor: Colors.teal,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChartPage()),
              );
            },
            child: const Icon(Icons.show_chart),
          ),
        ],
      ),
    );
  }

  /// 共通表示用
  Widget _buildRecordRow(IconData icon, String label, String? value) {
    final displayValue = (value == null || value == "null" || value.isEmpty) ? "-" : value;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent, size: 20),
          const SizedBox(width: 8),
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(displayValue, style: const TextStyle(color: Colors.black87))),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon,
      {bool isNumber = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.blueAccent),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          labelText: label,
          filled: true,
          fillColor: Colors.blue[50],
        ),
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      ),
    );
  }
}
