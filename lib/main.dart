import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/health_record.dart';
import 'navigation/main_navigation_page.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 初期化
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Hive 初期化
  await Hive.initFlutter();
  Hive.registerAdapter(HealthRecordAdapter());
  await Hive.openBox<HealthRecord>('records');

  // 通知初期化
  tz.initializeTimeZones();
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings =
  InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  runApp(const MyApp());

  // 🔔 起動テスト通知（5秒後）
  _showTestNotification();
}

/// テスト用通知（5秒後に出す）
Future<void> _showTestNotification() async {
  Future.delayed(const Duration(seconds: 5), () async {
    await flutterLocalNotificationsPlugin.show(
      0,
      "💡 今日のひとこと",
      "今日はどんなことが心に残りましたか？",
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_prompt_channel',
          'Daily Prompt',
          channelDescription: '今日のひとことを通知します',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ほっチャ',
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
        scaffoldBackgroundColor: Colors.blue[50],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.lightBlue[300],
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
      ),
      home: const MainNavigationPage(),
    );
  }
}
