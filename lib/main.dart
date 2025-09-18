import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // ← Firebase用
import 'firebase_options.dart'; // ← flutterfire configure で自動生成されるファイル
import 'package:hive_flutter/hive_flutter.dart';
import 'models/health_record.dart';
import 'pages/health_record_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔹 Firebaseを初期化
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 🔹 Hiveを初期化（既存の処理）
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
