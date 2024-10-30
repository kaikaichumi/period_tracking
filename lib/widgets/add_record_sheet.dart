// lib/widgets/add_record_sheet.dart
import 'package:flutter/material.dart';
import '../models/period_record.dart';
import '../services/database_service.dart';
import 'package:intl/intl.dart';

class AddRecordSheet extends StatefulWidget {
  final DateTime selectedDate;
  final PeriodRecord? existingRecord;
  final Function? onSaved;

  const AddRecordSheet({
    Key? key,
    required this.selectedDate,
    this.existingRecord,
    this.onSaved,
  }) : super(key: key);

  @override
  _AddRecordSheetState createState() => _AddRecordSheetState();
}

class _AddRecordSheetState extends State<AddRecordSheet> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _startDate;
  DateTime? _endDate;
  FlowIntensity _flowIntensity = FlowIntensity.medium;
  double _painLevel = 1;
  bool _isLoading = false;
  late TextEditingController _notesController;
  
  // 症狀列表
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

  @override
  void initState() {
    super.initState();
    _startDate = widget.selectedDate;
    _notesController = TextEditingController();
    
    // 如果是編輯現有記錄，載入資料
    if (widget.existingRecord != null) {
      final record = widget.existingRecord!;
      _startDate = record.startDate;
      _endDate = record.endDate;
      _flowIntensity = record.flowIntensity;
      _painLevel = record.painLevel.toDouble();
      record.symptoms.forEach((key, value) {
        if (_symptoms.containsKey(key)) {
          _symptoms[key] = value;
        }
      });
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : (_endDate ?? _startDate),
      firstDate: isStartDate ? DateTime(2020) : _startDate,
      lastDate: DateTime.now().add(Duration(days: 1)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.pink,
              onPrimary: Colors.white,
              surface: Colors.pink.shade50,
              onSurface: Colors.pink.shade900,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          // 如果結束日期在開始日期之前，重置結束日期
          if (_endDate != null && _endDate!.isBefore(_startDate)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _saveRecord() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      try {
        final record = PeriodRecord(
          id: widget.existingRecord?.id,
          startDate: _startDate,
          endDate: _endDate,
          flowIntensity: _flowIntensity,
          painLevel: _painLevel.round(),
          symptoms: Map.from(_symptoms),
        );

        if (widget.existingRecord != null) {
          await DatabaseService.instance.updatePeriod(record);
        } else {
          await DatabaseService.instance.insertPeriod(record);
        }

        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('記錄已保存')),
        );
        
        widget.onSaved?.call();
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失敗：$e')),
        );
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              _buildDateSelectors(),
              _buildFlowIntensitySelector(),
              _buildPainLevelSelector(),
              _buildSymptomsSelector(),
              _buildNotesInput(),
              _buildButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.pink[50],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.edit_calendar, color: Colors.pink),
          SizedBox(width: 8),
          Text(
            widget.existingRecord != null ? '編輯記錄' : '新增記錄',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.pink[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelectors() {
    final dateFormat = DateFormat('yyyy/MM/dd');
    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('開始日期'),
                SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => _selectDate(context, true),
                  icon: Icon(Icons.calendar_today),
                  label: Text(dateFormat.format(_startDate)),
                ),
              ],
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('結束日期'),
                SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => _selectDate(context, false),
                  icon: Icon(Icons.calendar_today),
                  label: Text(_endDate != null 
                    ? dateFormat.format(_endDate!) 
                    : '選擇日期'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlowIntensitySelector() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('出血量'),
          SizedBox(height: 8),
          SegmentedButton<FlowIntensity>(
            segments: [
              ButtonSegment(
                value: FlowIntensity.light,
                label: Text('輕'),
                icon: Icon(Icons.brightness_low),
              ),
              ButtonSegment(
                value: FlowIntensity.medium,
                label: Text('中'),
                icon: Icon(Icons.brightness_medium),
              ),
              ButtonSegment(
                value: FlowIntensity.heavy,
                label: Text('重'),
                icon: Icon(Icons.brightness_high),
              ),
            ],
            selected: {_flowIntensity},
            onSelectionChanged: (Set<FlowIntensity> selection) {
              setState(() => _flowIntensity = selection.first);
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith<Color>(
                (Set<MaterialState> states) {
                  if (states.contains(MaterialState.selected)) {
                    return Colors.pink.shade100;
                  }
                  return Colors.transparent;
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPainLevelSelector() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('經痛程度：${_painLevel.round()}'),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.sentiment_very_satisfied, color: Colors.green),
              Expanded(
                child: Slider(
                  value: _painLevel,
                  min: 1,
                  max: 10,
                  divisions: 9,
                  label: _painLevel.round().toString(),
                  onChanged: (value) {
                    setState(() => _painLevel = value);
                  },
                ),
              ),
              Icon(Icons.sentiment_very_dissatisfied, color: Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomsSelector() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('症狀（可複選）'),
          SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _symptoms.keys.map((symptom) {
              return FilterChip(
                label: Text(symptom),
                selected: _symptoms[symptom]!,
                onSelected: (bool selected) {
                  setState(() => _symptoms[symptom] = selected);
                },
                selectedColor: Colors.pink[100],
                checkmarkColor: Colors.pink,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesInput() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: TextFormField(
        controller: _notesController,
        maxLines: 3,
        decoration: InputDecoration(
          labelText: '備註',
          hintText: '輸入任何額外的觀察或備註...',
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildButtons() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: _isLoading ? null : () => Navigator.pop(context),
            child: Text('取消'),
          ),
          SizedBox(width: 8),
          ElevatedButton(
            onPressed: _isLoading ? null : _saveRecord,
            child: _isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text('保存'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}