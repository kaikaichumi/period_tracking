// lib/models/period_record.dart
import 'package:flutter/material.dart';

class PeriodRecord {
  int? id;
  DateTime startDate;
  DateTime? endDate;
  FlowIntensity flowIntensity;
  int painLevel;
  Map<String, bool> symptoms;

  PeriodRecord({
    this.id,
    required this.startDate,
    this.endDate,
    this.flowIntensity = FlowIntensity.medium,
    this.painLevel = 1,
    Map<String, bool>? symptoms,
  }) : symptoms = symptoms ?? {};

  Map<String, dynamic> toJson() => {
    'id': id,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate?.toIso8601String(),
    'flowIntensity': flowIntensity.toString(),
    'painLevel': painLevel,
    'symptoms': symptoms,
  };

  factory PeriodRecord.fromJson(Map<String, dynamic> json) => PeriodRecord(
    id: json['id'],
    startDate: DateTime.parse(json['startDate']),
    endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
    flowIntensity: FlowIntensity.values.firstWhere(
      (e) => e.toString() == json['flowIntensity']),
    painLevel: json['painLevel'],
    symptoms: Map<String, bool>.from(json['symptoms']),
  );
}

enum FlowIntensity {
  light,
  medium,
  heavy,
}

// lib/models/user_settings.dart
class UserSettings {
  int cycleLength;
  int periodLength;
  bool notificationsEnabled;
  TimeOfDay reminderTime;

  UserSettings({
    this.cycleLength = 28,
    this.periodLength = 5,
    this.notificationsEnabled = true,
    required this.reminderTime,
  });

  Map<String, dynamic> toJson() => {
    'cycleLength': cycleLength,
    'periodLength': periodLength,
    'notificationsEnabled': notificationsEnabled,
    'reminderTime': '${reminderTime.hour}:${reminderTime.minute}',
  };

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    final timeParts = json['reminderTime'].split(':');
    return UserSettings(
      cycleLength: json['cycleLength'],
      periodLength: json['periodLength'],
      notificationsEnabled: json['notificationsEnabled'],
      reminderTime: TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      ),
    );
  }
}