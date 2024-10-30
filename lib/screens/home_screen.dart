// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../widgets/add_record_sheet.dart';
import '../services/database_service.dart';
import '../services/prediction_service.dart';
import '../models/period_record.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<PeriodRecord> _periodRecords = [];
  List<DateTime> _predictedPeriods = [];

  @override
  void initState() {
    super.initState();
    _loadPeriodRecords();
  }

  Future<void> _loadPeriodRecords() async {
    final records = await DatabaseService.instance.getAllPeriods();
    setState(() {
      _periodRecords = records;
      _predictedPeriods = PredictionService.predictNext3Periods(records, 28);
    });
  }

  List<PeriodRecord> _getRecordsForDay(DateTime day) {
    return _periodRecords.where((record) {
      final startDate = DateTime(record.startDate.year, record.startDate.month, record.startDate.day);
      final endDate = record.endDate != null
          ? DateTime(record.endDate!.year, record.endDate!.month, record.endDate!.day)
          : startDate;
      return day.isAtSameMomentAs(startDate) ||
          (day.isAfter(startDate) && day.isBefore(endDate)) ||
          day.isAtSameMomentAs(endDate);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('月經週期追蹤'),
        actions: [
          IconButton(
            icon: Icon(Icons.bar_chart),
            onPressed: () => Navigator.pushNamed(context, '/statistics'),
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              _showAddRecordDialog(selectedDay);
            },
            eventLoader: _getRecordsForDay,
            calendarStyle: CalendarStyle(
              markerDecoration: BoxDecoration(
                color: Colors.red[300],
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Colors.blue[200],
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _predictedPeriods.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Icon(Icons.calendar_today),
                  title: Text(
                    '預測第${index + 1}次月經',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${_predictedPeriods[index].year}年${_predictedPeriods[index].month}月${_predictedPeriods[index].day}日',
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddRecordDialog(_selectedDay ?? _focusedDay),
        child: Icon(Icons.add),
        backgroundColor: Colors.pink,
      ),
    );
  }

  void _showAddRecordDialog(DateTime selectedDate) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddRecordSheet(
        selectedDate: selectedDate,
        onSaved: _loadPeriodRecords,
      ),
    );
  }
}