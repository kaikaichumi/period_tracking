// lib/widgets/add_record_sheet.dart
import 'package:flutter/material.dart';
import '../models/period_record.dart';

class AddRecordSheet extends StatefulWidget {
  final DateTime selectedDate;
  final Function(PeriodRecord) onSave;
  final PeriodRecord? existingRecord;

  const AddRecordSheet({
    Key? key,
    required this.selectedDate,
    required this.onSave,
    this.existingRecord,
  }) : super(key: key);

  @override
  State<AddRecordSheet> createState() => _AddRecordSheetState();
}

class _AddRecordSheetState extends State<AddRecordSheet> {
  late DateTime _startDate;
  DateTime? _endDate;
  int _painLevel = 1;
  FlowIntensity _flowIntensity = FlowIntensity.medium;
  final Map<String, bool> _symptoms = {
    '情緒變化': false,
    '乳房脹痛': false,
    '腰痛': false,
    '頭痛': false,
    '疲勞': false,
    '痘痘': false,
    '噁心': false,
    '食慾改變': false,
    '失眠': false,
    '腹脹': false,
  };
  final TextEditingController _notesController = TextEditingController();
  bool _isEditing = false;
  bool _isSettingEndDate = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingRecord != null) {
      _startDate = widget.existingRecord!.startDate;
      _endDate = widget.existingRecord!.endDate;
      _painLevel = widget.existingRecord!.painLevel;
      _flowIntensity = widget.existingRecord!.flowIntensity;
      _symptoms.addAll(widget.existingRecord!.symptoms);
      _notesController.text = widget.existingRecord!.notes ?? '';
      _isEditing = true;
      _isSettingEndDate = widget.existingRecord!.endDate == null;
      if (_isSettingEndDate) {
        _endDate = widget.selectedDate;
      }
    } else {
      _startDate = widget.selectedDate;
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isSettingEndDate) {
      return Container(
        padding: const EdgeInsets.all(16.0),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              '設定結束日期',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('開始日期'),
              subtitle: Text('${_startDate.year}/${_startDate.month}/${_startDate.day}'),
              leading: const Icon(Icons.calendar_today),
              enabled: false,
            ),
            ListTile(
              title: const Text('結束日期'),
              subtitle: Text('${_endDate!.year}/${_endDate!.month}/${_endDate!.day}'),
              leading: const Icon(Icons.calendar_today),
              onTap: () => _selectDate(false),
            ),
            const SizedBox(height: 16),
            Text(
              '週期長度：${_endDate!.difference(_startDate).inDays + 1} 天',
              style: TextStyle(
                color: Colors.pink[700],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _savePeriod,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              child: const Text('儲存結束日期'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      );
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            height: 4,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Text(
                  _isEditing ? '編輯月經記錄' : '新增月經記錄',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),

                // 日期選擇區
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '週期日期',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          title: const Text('開始日期'),
                          subtitle: Text(
                            '${_startDate.year}/${_startDate.month}/${_startDate.day}',
                          ),
                          leading: const Icon(Icons.calendar_today),
                          onTap: () => _selectDate(true),
                        ),
                        if (_isEditing) ...[
                          ListTile(
                            title: const Text('結束日期（選填）'),
                            subtitle: Text(
                              _endDate != null
                                  ? '${_endDate!.year}/${_endDate!.month}/${_endDate!.day}'
                                  : '請選擇結束日期',
                            ),
                            leading: const Icon(Icons.calendar_today),
                            onTap: () => _selectDate(false),
                          ),
                          if (_endDate != null)
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
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 經痛程度
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '經痛程度',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Slider(
                          value: _painLevel.toDouble(),
                          min: 1,
                          max: 10,
                          divisions: 9,
                          label: _painLevel.toString(),
                          onChanged: (value) {
                            setState(() {
                              _painLevel = value.round();
                            });
                          },
                        ),
                        Center(
                          child: Text(
                            '${_painLevel.toString()} / 10',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 出血量
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '出血量',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SegmentedButton<FlowIntensity>(
                          segments: const [
                            ButtonSegment<FlowIntensity>(
                              value: FlowIntensity.light,
                              label: Text('輕'),
                            ),
                            ButtonSegment<FlowIntensity>(
                              value: FlowIntensity.medium,
                              label: Text('中'),
                            ),
                            ButtonSegment<FlowIntensity>(
                              value: FlowIntensity.heavy,
                              label: Text('重'),
                            ),
                          ],
                          selected: {_flowIntensity},
                          onSelectionChanged: (Set<FlowIntensity> newSelection) {
                            setState(() {
                              _flowIntensity = newSelection.first;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 症狀選擇
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '症狀',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _symptoms.keys.map((symptom) {
                            return FilterChip(
                              label: Text(symptom),
                              selected: _symptoms[symptom]!,
                              onSelected: (bool selected) {
                                setState(() {
                                  _symptoms[symptom] = selected;
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 備註
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '備註',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _notesController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            hintText: '輸入備註...',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 保存按鈕
                Center(
                  child: ElevatedButton(
                    onPressed: _savePeriod,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('儲存'),
                  ),
                ),
                const SizedBox(height: 24),
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
    final record = PeriodRecord(
      id: widget.existingRecord?.id,
      startDate: _startDate,
      endDate: _endDate,
      painLevel: _painLevel,
      symptoms: _symptoms,
      flowIntensity: _flowIntensity,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
    );

    widget.onSave(record);
  }
}