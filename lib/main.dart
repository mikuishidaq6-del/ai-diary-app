import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/health_record.dart';
import 'navigation/main_navigation_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 初期化
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Hive 初期化
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
