import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/period_record.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static SharedPreferences? _prefs;
  static const String _recordsKey = 'period_records';
  static int _nextId = 0;  // 用於生成唯一ID

  DatabaseService._init();

  Future<SharedPreferences> get prefs async {
    if (_prefs != null) return _prefs!;
    _prefs = await SharedPreferences.getInstance();
    // 讀取已保存的最大ID
    _nextId = _prefs!.getInt('next_id') ?? 0;
    return _prefs!;
  }

  Future<List<PeriodRecord>> getAllPeriods() async {
    final pref = await prefs;
    final String? recordsJson = pref.getString(_recordsKey);
    if (recordsJson == null) return [];

    try {
      List<dynamic> recordsList = jsonDecode(recordsJson);
      return recordsList.map((json) => PeriodRecord.fromJson(json)).toList();
    } catch (e) {
      print('Error decoding records: $e');
      return [];
    }
  }

  Future<void> insertPeriod(PeriodRecord record) async {
    final records = await getAllPeriods();
    final newRecord = record.copyWith(id: _nextId++);
    records.add(newRecord);
    await _saveRecords(records);
    // 保存新的ID
    final pref = await prefs;
    await pref.setInt('next_id', _nextId);
  }

  Future<void> updatePeriod(PeriodRecord record) async {
    final records = await getAllPeriods();
    final index = records.indexWhere((r) => r.id == record.id);
    if (index != -1) {
      records[index] = record;
      await _saveRecords(records);
    }
  }

  Future<void> deletePeriod(int id) async {
    final records = await getAllPeriods();
    records.removeWhere((record) => record.id == id);
    await _saveRecords(records);
  }

  Future<void> _saveRecords(List<PeriodRecord> records) async {
    final pref = await prefs;
    final recordsJson = jsonEncode(
      records.map((record) => record.toJson()).toList(),
    );
    await pref.setString(_recordsKey, recordsJson);
  }
}