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
  late int _painLevel;
  late FlowIntensity _flowIntensity;
  late Map<String, bool> _symptoms;
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 初始化數據
    if (widget.existingRecord != null) {
      _startDate = widget.existingRecord!.startDate;
      _endDate = widget.existingRecord!.endDate;
      _painLevel = widget.existingRecord!.painLevel;
      _flowIntensity = widget.existingRecord!.flowIntensity;
      _symptoms = Map<String, bool>.from(widget.existingRecord!.symptoms);
      _notesController.text = widget.existingRecord!.notes ?? '';
    } else {
      _startDate = widget.selectedDate;
      _painLevel = 1;
      _flowIntensity = FlowIntensity.medium;
      _symptoms = {
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
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
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
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Text(
                  widget.existingRecord != null ? '編輯月經記錄' : '新增月經記錄',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                // 日期選擇
                _buildDateSection(),
                const SizedBox(height: 24),
                // 經痛程度
                _buildPainLevelSection(),
                const SizedBox(height: 24),
                // 出血量
                _buildFlowIntensitySection(),
                const SizedBox(height: 24),
                // 症狀選擇
                _buildSymptomsSection(),
                const SizedBox(height: 24),
                // 備註
                _buildNotesSection(),
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
                    child: const Text(
                      '保存',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: const Text('開始日期'),
              subtitle: Text(
                '${_startDate.year}/${_startDate.month}/${_startDate.day}',
              ),
              leading: const Icon(Icons.calendar_today),
              onTap: () => _selectDate(true),
            ),
            const Divider(),
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
              const Divider(),
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
    );
  }

  Widget _buildPainLevelSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '經痛程度',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Slider(
              value: _painLevel.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              label: _painLevel.toString(),
              activeColor: Colors.pink,
              onChanged: (value) {
                setState(() {
                  _painLevel = value.round();
                });
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('輕微'),
                Text('中等'),
                Text('劇烈'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlowIntensitySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '出血量',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<FlowIntensity>(
                    title: const Text('輕'),
                    value: FlowIntensity.light,
                    groupValue: _flowIntensity,
                    onChanged: (FlowIntensity? value) {
                      setState(() {
                        _flowIntensity = value!;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<FlowIntensity>(
                    title: const Text('中'),
                    value: FlowIntensity.medium,
                    groupValue: _flowIntensity,
                    onChanged: (FlowIntensity? value) {
                      setState(() {
                        _flowIntensity = value!;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<FlowIntensity>(
                    title: const Text('重'),
                    value: FlowIntensity.heavy,
                    groupValue: _flowIntensity,
                    onChanged: (FlowIntensity? value) {
                      setState(() {
                        _flowIntensity = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSymptomsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '症狀',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: _symptoms.keys.map((symptom) {
                return FilterChip(
                  label: Text(symptom),
                  selected: _symptoms[symptom]!,
                  onSelected: (bool selected) {
                    setState(() {
                      _symptoms[symptom] = selected;
                    });
                  },
                  selectedColor: Colors.pink[100],
                  checkmarkColor: Colors.pink,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '備註',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: '在這裡添加備註...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
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
    if (_endDate == null) return;

    final record = PeriodRecord(
      id: widget.existingRecord?.id,
      startDate: _startDate,
      endDate: _endDate,
      painLevel: _painLevel,
      symptoms: _symptoms,
      flowIntensity: _flowIntensity,
      notes: _notesController.text.trim(),
    );

    widget.onSave(record);
    Navigator.pop(context);
  }
}