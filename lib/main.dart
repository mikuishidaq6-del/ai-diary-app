import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Firebase用
import 'firebase_options.dart'; // flutterfire configure で生成されるファイル
import 'package:hive_flutter/hive_flutter.dart';
import 'models/health_record.dart';

// ページをインポート
import 'pages/health_record_page.dart';
import 'pages/post_page.dart';
import 'pages/timeline_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔹 Firebase 初期化
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 🔹 Hive 初期化
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

      // 最初に開くページを変更したい場合はここを変える
      // home: const HealthRecordPage(),
      home: const PostPage(),

      // 🔹 ページ遷移用ルート
      routes: {
        '/health': (context) => const HealthRecordPage(),
        '/post': (context) => const PostPage(),
        '/timeline': (context) => const TimelinePage(),
      },
    );
  }
}
