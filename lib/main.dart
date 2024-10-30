import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // 添加這行
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';
import 'screens/statistics_screen.dart';
import 'screens/settings_screen.dart';
import 'services/database_service.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await SharedPreferences.getInstance();
    runApp(const PeriodTrackerApp());
  } catch (e) {
    print('Initialization error: $e');
    runApp(const PeriodTrackerApp());
  }
}

class PeriodTrackerApp extends StatelessWidget {
  const PeriodTrackerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '月經週期追蹤',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        useMaterial3: true,
      ),
      // 添加本地化支援
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // 支援的語言列表
      supportedLocales: const [
        Locale('zh', 'TW'), // 繁體中文
        Locale('en', 'US'), // 英文
      ],
      // 設定預設語言為繁體中文
      locale: const Locale('zh', 'TW'),
      home: MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatefulWidget {
  MainScreen({Key? key}) : super(key: key);  // 移除 const

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  late final List<Widget> _screens;  // 使用 late final

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(),      // 移除 const
      StatisticsScreen(),  // 移除 const
      SettingsScreen(),    // 移除 const
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [  // 這裡的 const 可以保留
          NavigationDestination(
            icon: Icon(Icons.calendar_today),
            label: '日曆',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart),
            label: '統計',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: '設定',
          ),
        ],
      ),
    );
  }
}