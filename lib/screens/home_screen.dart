import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../services/database_service.dart';
import '../models/period_record.dart';
import '../widgets/add_record_sheet.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<PeriodRecord>> _events = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadEvents();
  }

  // 載入事件數據
  Future<void> _loadEvents() async {
    setState(() => _isLoading = true);
    try {
      // 模擬從數據庫載入數據
      // 實際使用時請替換為真實的數據庫操作
      final records = [
        PeriodRecord(
          startDate: DateTime.now().subtract(const Duration(days: 6)),
          endDate: DateTime.now().subtract(const Duration(days: 2)),
          painLevel: 3,
          flowIntensity: FlowIntensity.medium,
        ),
      ];

      final Map<DateTime, List<PeriodRecord>> newEvents = {};
      for (final record in records) {
        if (record.endDate != null) {
          DateTime current = record.startDate;
          while (current.isBefore(record.endDate!) || 
                 current.isAtSameMomentAs(record.endDate!)) {
            final date = DateTime(current.year, current.month, current.day);
            newEvents[date] = [...(newEvents[date] ?? []), record];
            current = current.add(const Duration(days: 1));
          }
        }
      }

      setState(() {
        _events = newEvents;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading events: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('月經週期追蹤'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            calendarFormat: _calendarFormat,
            eventLoader: (day) {
              return _events[DateTime(day.year, day.month, day.day)] ?? [];
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              _showAddRecordSheet(selectedDay);
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            calendarStyle: CalendarStyle(
              markerDecoration: BoxDecoration(
                color: Colors.pink[300],
                shape: BoxShape.circle,
              ),
              selectedDecoration: const BoxDecoration(
                color: Colors.pink,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Colors.pink[100],
                shape: BoxShape.circle,
              ),
              markersMaxCount: 1,
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: true,
              titleCentered: true,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _buildEventList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddRecordSheet(_selectedDay ?? _focusedDay),
        child: const Icon(Icons.add),
        backgroundColor: Colors.pink,
      ),
    );
  }

  Widget _buildEventList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final selectedDate = _selectedDay ?? _focusedDay;
    final events = _events[DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    )] ?? [];

    if (events.isEmpty) {
      return const Center(
        child: Text('點擊日期來記錄'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final record = events[index];
        return Card(
          child: ListTile(
            title: Text(
              '週期記錄',
              style: TextStyle(
                color: Colors.pink[700],
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('開始：${DateFormat('yyyy/MM/dd').format(record.startDate)}'),
                if (record.endDate != null)
                  Text('結束：${DateFormat('yyyy/MM/dd').format(record.endDate!)}'),
                Text('經痛程度：${record.painLevel}/10'),
                Text('出血量：${_flowIntensityToString(record.flowIntensity)}'),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showAddRecordSheet(selectedDate, existingRecord: record),
            ),
          ),
        );
      },
    );
  }

  String _flowIntensityToString(FlowIntensity intensity) {
    switch (intensity) {
      case FlowIntensity.light:
        return '輕';
      case FlowIntensity.medium:
        return '中';
      case FlowIntensity.heavy:
        return '重';
    }
  }

  void _showAddRecordSheet(DateTime selectedDate, {PeriodRecord? existingRecord}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: AddRecordSheet(
            selectedDate: selectedDate,
            existingRecord: existingRecord,
            onSave: (record) async {
              // 這裡應該調用數據庫服務來保存記錄
              print('Saving record: ${record.toJson()}');
              await _loadEvents(); // 重新載入數據
              if (mounted) {
                Navigator.pop(context);
              }
            },
          ),
        );
      },
    );
  }
}