import 'dart:convert';

enum FlowIntensity {
  light,
  medium,
  heavy,
}

class PeriodRecord {
  final int? id;
  final DateTime startDate;
  final DateTime? endDate;
  final int painLevel;
  final Map<String, bool> symptoms;
  final FlowIntensity flowIntensity;
  final String? notes;

  PeriodRecord({
    this.id,
    required this.startDate,
    this.endDate,
    this.painLevel = 1,
    Map<String, bool>? symptoms,
    this.flowIntensity = FlowIntensity.medium,
    this.notes,
  }) : symptoms = symptoms ?? {
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'painLevel': painLevel,
      'symptoms': symptoms,
      'flowIntensity': flowIntensity.toString(),
      'notes': notes,
    };
  }

  factory PeriodRecord.fromJson(Map<String, dynamic> json) {
    return PeriodRecord(
      id: json['id'],
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      painLevel: json['painLevel'] ?? 1,
      symptoms: Map<String, bool>.from(json['symptoms'] ?? {}),
      flowIntensity: _parseFlowIntensity(json['flowIntensity']),
      notes: json['notes'],
    );
  }

  static FlowIntensity _parseFlowIntensity(String? value) {
    switch (value) {
      case 'FlowIntensity.light':
        return FlowIntensity.light;
      case 'FlowIntensity.heavy':
        return FlowIntensity.heavy;
      case 'FlowIntensity.medium':
      default:
        return FlowIntensity.medium;
    }
  }

  PeriodRecord copyWith({
    int? id,
    DateTime? startDate,
    DateTime? endDate,
    int? painLevel,
    Map<String, bool>? symptoms,
    FlowIntensity? flowIntensity,
    String? notes,
  }) {
    return PeriodRecord(
      id: id ?? this.id,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      painLevel: painLevel ?? this.painLevel,
      symptoms: symptoms ?? Map<String, bool>.from(this.symptoms),
      flowIntensity: flowIntensity ?? this.flowIntensity,
      notes: notes ?? this.notes,
    );
  }
}