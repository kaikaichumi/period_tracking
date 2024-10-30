// lib/main.dart
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import 'services/database_service.dart';
import 'services/notification_service.dart';
import 'models/user_settings.dart';
import 'screens/statistics_screen.dart';
import 'screens/settings_screen.dart';
import 'widgets/add_record_sheet.dart';

void main() async {
  // 确保Flutter绑定初始化
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化服务
  await DatabaseService.instance.database;
  await NotificationService.instance.init();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => UserSettingsProvider(),
        ),
      ],
      child: PeriodTrackerApp(),
    ),
  );
}

class PeriodTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '月經週期追蹤',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        useMaterial3: true,
      ),
      home: MainScreen(),
      debugShowCheckedModeBanner: false, // 移除 debug 标签
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  
  static final List<Widget> _screens = [
    HomeScreen(),
    StatisticsScreen(),
    SettingsScreen(),
  ];

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
        destinations: const [
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

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('月經週期追蹤'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              _showAddRecordDialog(selectedDay);
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
          ),
          Expanded(
            child: Center(
              child: Text(
                '點擊日期來記錄經期',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddRecordDialog(_focusedDay),
        child: Icon(Icons.add),
        tooltip: '新增記錄',
      ),
    );
  }

  void _showAddRecordDialog(DateTime selectedDate) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddRecordSheet(
        selectedDate: selectedDate,
        onSaved: () {
          setState(() {});
        },
      ),
    );
  }
}