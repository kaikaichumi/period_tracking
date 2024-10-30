// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_settings.dart';
import '../services/notification_service.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('設定'),
      ),
      body: Consumer<UserSettingsProvider>(
        builder: (context, settings, child) {
          return ListView(
            children: [
              ListTile(
                title: Text('平均週期長度'),
                subtitle: Text('${settings.cycleLength} 天'),
                trailing: IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => _showCycleLengthDialog(context, settings),
                ),
              ),
              SwitchListTile(
                title: Text('經期提醒'),
                subtitle: Text('在預測的經期開始前一天提醒'),
                value: settings.notificationsEnabled,
                onChanged: (bool value) {
                  settings.updateNotificationsEnabled(value);
                },
              ),
              if (settings.notificationsEnabled)
                ListTile(
                  title: Text('提醒時間'),
                  subtitle: Text(
                    '${settings.reminderTime.hour}:${settings.reminderTime.minute.toString().padLeft(2, '0')}',
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.access_time),
                    onPressed: () => _selectTime(context, settings),
                  ),
                ),
              // 其他設定項目
            ],
          );
        },
      ),
    );
  }

  Future<void> _showCycleLengthDialog(
    BuildContext context,
    UserSettingsProvider settings,
  ) async {
    final controller = TextEditingController(
      text: settings.cycleLength.toString(),
    );

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('設定週期長度'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: '天數',
            suffixText: '天',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('取消'),
          ),
          TextButton(
            onPressed: () {
              final newLength = int.tryParse(controller.text);
              if (newLength != null && newLength > 0) {
                settings.updateCycleLength(newLength);
              }
              Navigator.pop(context);
            },
            child: Text('確定'),
          ),
        ],
      ),
    );
  }

  Future<void> _selectTime(
    BuildContext context,
    UserSettingsProvider settings,
  ) async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: settings.reminderTime,
    );

    if (time != null) {
      settings.updateReminderTime(time);
    }
  }
}