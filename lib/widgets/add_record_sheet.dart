// lib/widgets/add_record_sheet.dart
import 'package:flutter/material.dart';
import '../models/period_record.dart';

class AddRecordSheet extends StatefulWidget {
  final DateTime selectedDate;
  final Function(PeriodRecord) onSave;
  final PeriodRecord? existingRecord;  // 添加 existingRecord 參數

  const AddRecordSheet({
    Key? key,
    required this.selectedDate,
    required this.onSave,
    this.existingRecord,  // 添加到構造函數
  }) : super(key: key);

  @override
  State<AddRecordSheet> createState() => _AddRecordSheetState();
}

class _AddRecordSheetState extends State<AddRecordSheet> {
  late DateTime _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    // 如果是編輯現有記錄，載入現有數據
    if (widget.existingRecord != null) {
      _startDate = widget.existingRecord!.startDate;
      _endDate = widget.existingRecord!.endDate;
    } else {
      _startDate = widget.selectedDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // 頂部拖動條
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            height: 4,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.existingRecord != null ? '編輯月經記錄' : '新增月經記錄',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                // 開始日期
                ListTile(
                  title: const Text('開始日期'),
                  subtitle: Text(
                    '${_startDate.year}/${_startDate.month}/${_startDate.day}',
                  ),
                  leading: const Icon(Icons.calendar_today),
                  onTap: () => _selectDate(true),
                ),
                const SizedBox(height: 16),
                // 結束日期
                ListTile(
                  title: const Text('結束日期'),
                  subtitle: Text(
                    _endDate != null
                        ? '${_endDate!.year}/${_endDate!.month}/${_endDate!.day}'
                        : '請選擇結束日期',
                  ),
                  leading: const Icon(Icons.calendar_today),
                  onTap: () => _selectDate(false),
                ),
                if (_endDate != null) ...[
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      '週期長度：${_endDate!.difference(_startDate).inDays + 1} 天',
                      style: TextStyle(
                        color: Colors.pink[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                // 保存按鈕
                Center(
                  child: ElevatedButton(
                    onPressed: _endDate == null ? null : _savePeriod,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('保存'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(bool isStartDate) async {
    final DateTime currentDate = isStartDate ? _startDate : (_endDate ?? _startDate);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: isStartDate ? DateTime(2020) : _startDate,
      lastDate: DateTime.now().add(const Duration(days: 1)),
      locale: const Locale('zh', 'TW'),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          // 如果結束日期在新的開始日期之前，重置結束日期
          if (_endDate != null && _endDate!.isBefore(_startDate)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _savePeriod() {
    if (_endDate == null) return;

    final record = PeriodRecord(
      id: widget.existingRecord?.id,
      startDate: _startDate,
      endDate: _endDate,
      painLevel: 1, // 默認值
      flowIntensity: FlowIntensity.medium, // 默認值
    );

    widget.onSave(record);
    Navigator.pop(context);
  }
}