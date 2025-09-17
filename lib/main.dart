import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/health_record.dart';
import 'pages/health_record_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HealthRecordPage(),
    );
  }
}
