// 版权所有 (C) 2025 Pill Helper
// 本代码遵循 AGPL-3.0 开源协议，个人非商用可自由使用、修改；商用需联系作者授权

import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../services/notification_service.dart';

/// 提醒设置页面
/// 功能：设置定时吃药提醒（手机闹钟设置）
/// 使用方法：从设置页面进入
class ReminderSettingsPage extends StatefulWidget {
  const ReminderSettingsPage({super.key});
  
  @override
  State<ReminderSettingsPage> createState() => _ReminderSettingsPageState();
}

class _ReminderSettingsPageState extends State<ReminderSettingsPage> {
  // 提醒开关
  bool _reminderEnabled = true;
  
  // 提醒音量
  double _volume = 0.8;
  
  // 提醒震动
  bool _vibrationEnabled = true;
  
  // 通知权限状态
  String _permissionStatus = '检查中...';
  
  @override
  void initState() {
    super.initState();
    _checkPermissionStatus();
  }
  
  /// 检查通知权限状态
  Future<void> _checkPermissionStatus() async {
    final status = await NotificationService.instance.checkNotificationPermission();
    setState(() {
      _permissionStatus = status;
    });
  }
  
  /// 请求通知权限
  Future<void> _requestPermission() async {
    final granted = await NotificationService.instance.requestNotificationPermission();
    await _checkPermissionStatus();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(granted ? '通知权限已授予' : '通知权限被拒绝，请在系统设置中开启'),
          backgroundColor: granted ? Colors.green : Colors.orange,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
  
  /// 发送测试通知
  Future<void> _sendTestNotification() async {
    final success = await NotificationService.instance.sendTestNotification();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success 
              ? '测试通知已发送，请查看手机通知栏' 
              : '发送失败，请检查通知权限'),
          backgroundColor: success ? Colors.green : Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('定时吃药提醒设置'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 说明文字
          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '提醒设置会应用到所有药品的提醒通知。具体药品的提醒时间在添加药品时设置。',
                      style: TextStyle(
                        fontSize: AppConstants.normalFontSize,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 通知权限状态
          Card(
            color: _permissionStatus.contains('已授予') 
                ? Colors.green.shade50 
                : Colors.orange.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _permissionStatus.contains('已授予') 
                            ? Icons.check_circle 
                            : Icons.warning,
                        color: _permissionStatus.contains('已授予') 
                            ? Colors.green 
                            : Colors.orange,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '通知权限状态',
                              style: TextStyle(
                                fontSize: AppConstants.largeFontSize,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _permissionStatus,
                              style: TextStyle(
                                fontSize: AppConstants.normalFontSize,
                                color: _permissionStatus.contains('已授予') 
                                    ? Colors.green.shade900 
                                    : Colors.orange.shade900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _requestPermission,
                          icon: const Icon(Icons.settings),
                          label: const Text('请求权限'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _sendTestNotification,
                          icon: const Icon(Icons.notifications_active),
                          label: const Text('测试通知'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 启用提醒
          Card(
            child: SwitchListTile(
              title: const Text(
                '启用提醒',
                style: TextStyle(fontSize: AppConstants.largeFontSize),
              ),
              subtitle: const Text(
                '关闭后将不会收到任何提醒通知',
                style: TextStyle(fontSize: AppConstants.smallFontSize),
              ),
              value: _reminderEnabled,
              onChanged: (value) {
                setState(() {
                  _reminderEnabled = value;
                });
              },
            ),
          ),
          
          if (_reminderEnabled) ...[
            const SizedBox(height: 16),
            
            // 提醒音量
            Card(
              child: Column(
                children: [
                  ListTile(
                    title: const Text(
                      '提醒音量',
                      style: TextStyle(fontSize: AppConstants.largeFontSize),
                    ),
                    subtitle: Slider(
                      value: _volume,
                      min: 0.0,
                      max: 1.0,
                      divisions: 10,
                      label: '${(_volume * 100).toInt()}%',
                      onChanged: (value) {
                        setState(() {
                          _volume = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 震动提醒
            Card(
              child: SwitchListTile(
                title: const Text(
                  '震动提醒',
                  style: TextStyle(fontSize: AppConstants.largeFontSize),
                ),
                subtitle: const Text(
                  '提醒时手机震动',
                  style: TextStyle(fontSize: AppConstants.smallFontSize),
                ),
                value: _vibrationEnabled,
                onChanged: (value) {
                  setState(() {
                    _vibrationEnabled = value;
                  });
                },
              ),
            ),
          ],
          
          const SizedBox(height: 32),
          
          // 说明
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '说明',
                    style: TextStyle(
                      fontSize: AppConstants.largeFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• 提醒功能基于系统通知，需要在手机设置中允许应用发送通知\n'
                    '• 具体药品的提醒时间在"添加药品"时设置\n'
                    '• 如果提醒没有响，请检查：\n'
                    '  1. 通知权限是否已授予（点击上方"请求权限"按钮）\n'
                    '  2. 手机是否开启了勿扰模式\n'
                    '  3. 应用是否被系统省电模式限制\n'
                    '  4. 手机系统设置中该应用的通知是否被关闭\n'
                    '• 建议点击"测试通知"按钮验证通知功能是否正常',
                    style: TextStyle(
                      fontSize: AppConstants.normalFontSize,
                      color: Colors.grey.shade700,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
