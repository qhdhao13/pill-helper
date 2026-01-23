// 版权所有 (C) 2025 Pill Helper
// 本代码遵循 AGPL-3.0 开源协议，个人非商用可自由使用、修改；商用需联系作者授权

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/medicine.dart';
import '../models/medicine_log.dart';
import '../database/database_helper.dart';
import '../utils/constants.dart';

/// 本地通知服务
/// 功能：管理所有提醒通知，包括定时提醒、漏服二次提醒等
/// 使用方法：通过 NotificationService.instance 获取单例，然后调用相应方法
class NotificationService {
  // 单例模式
  static final NotificationService instance = NotificationService._internal();
  NotificationService._internal();
  
  // 通知插件实例
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  
  // 是否已初始化
  bool _isInitialized = false;
  
  /// 初始化通知服务
  /// 功能：请求通知权限，初始化通知插件，设置时区
  /// 返回：true=成功，false=失败
  Future<bool> initialize() async {
    if (_isInitialized) return true;
    
    try {
      // 初始化时区数据（用于定时通知）
      tz.initializeTimeZones();
      // 设置本地时区
      tz.setLocalLocation(tz.getLocation('Asia/Shanghai')); // 中国时区
      
      // Android初始化设置
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher'); // 使用应用图标
      
      // iOS初始化设置
      const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true, // 请求弹窗权限
        requestBadgePermission: true, // 请求角标权限
        requestSoundPermission: true, // 请求声音权限
      );
      
      // 初始化设置
      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );
      
      // 初始化通知插件
      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped, // 通知点击回调
      );
      
      // 请求通知权限（Android 13+需要）
      await _requestPermissions();
      
      _isInitialized = true;
      return true;
    } catch (e) {
      print('初始化通知服务失败: $e');
      return false;
    }
  }
  
  /// 请求通知权限
  /// 功能：向系统请求通知权限（Android 13+和iOS都需要）
  Future<void> _requestPermissions() async {
    try {
      // 检查权限状态
      final status = await Permission.notification.status;
      
      if (status.isDenied) {
        // 请求权限
        final result = await Permission.notification.request();
        print('通知权限请求结果: $result');
        if (result.isGranted) {
          print('通知权限已授予');
        } else {
          print('通知权限被拒绝，提醒功能可能无法正常工作');
        }
      } else if (status.isGranted) {
        print('通知权限已授予');
      } else if (status.isPermanentlyDenied) {
        print('通知权限被永久拒绝，需要在系统设置中手动开启');
      }
    } catch (e) {
      print('请求通知权限失败: $e');
    }
  }
  
  /// 检查通知权限状态
  /// 返回：权限状态描述
  Future<String> checkNotificationPermission() async {
    try {
      final status = await Permission.notification.status;
      if (status.isGranted) {
        return '已授予';
      } else if (status.isDenied) {
        return '未授予';
      } else if (status.isPermanentlyDenied) {
        return '已永久拒绝（需在系统设置中开启）';
      } else {
        return '未知状态';
      }
    } catch (e) {
      return '检查失败: $e';
    }
  }
  
  /// 请求通知权限（公开方法，供UI调用）
  /// 返回：true=已授予，false=未授予
  Future<bool> requestNotificationPermission() async {
    try {
      final status = await Permission.notification.status;
      if (status.isGranted) {
        return true;
      }
      
      final result = await Permission.notification.request();
      return result.isGranted;
    } catch (e) {
      print('请求通知权限失败: $e');
      return false;
    }
  }
  
  /// 发送测试通知
  /// 功能：立即发送一个测试通知，用于验证通知功能是否正常
  Future<bool> sendTestNotification() async {
    try {
      // 检查权限
      final hasPermission = await Permission.notification.isGranted;
      if (!hasPermission) {
        print('通知权限未授予，无法发送测试通知');
        return false;
      }
      
      // 发送测试通知
      await _notifications.show(
        999999, // 测试通知ID
        '测试通知',
        '如果您看到这条消息，说明通知功能正常工作',
        _getTestNotificationDetails(),
      );
      
      print('测试通知已发送');
      return true;
    } catch (e) {
      print('发送测试通知失败: $e');
      return false;
    }
  }
  
  /// 获取测试通知详情
  NotificationDetails _getTestNotificationDetails() {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'medicine_reminder_channel',
      '吃药提醒',
      channelDescription: '提醒您按时服药',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
    );
    
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    return const NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
  }
  
  /// 通知点击回调
  /// 参数：通知响应对象
  void _onNotificationTapped(NotificationResponse response) {
    // 当用户点击通知时，可以在这里处理跳转逻辑
    // 例如：跳转到药品详情页面
    print('通知被点击: ${response.payload}');
  }
  
  /// 为药品设置提醒
  /// 参数：
  /// - medicine: 药品对象
  /// 功能：根据药品的服用时间，设置多个定时提醒，并创建对应的日志记录
  Future<void> scheduleMedicineReminders(Medicine medicine) async {
    if (!medicine.isActive) {
      // 如果药品未启用，取消所有提醒
      await cancelMedicineReminders(medicine.id!);
      return;
    }
    
    // 获取药品的服用时间列表
    List<String> timeList = medicine.getTimeList();
    
    if (timeList.isEmpty) {
      print('药品 ${medicine.name} 没有设置服用时间，跳过提醒设置');
      return;
    }
    
    // 为每个时间点设置提醒和创建日志记录
    for (int i = 0; i < timeList.length; i++) {
      String timeStr = timeList[i];
      List<String> parts = timeStr.split(':');
      if (parts.length != 2) continue;
      
      int hour = int.tryParse(parts[0]) ?? 0;
      int minute = int.tryParse(parts[1]) ?? 0;
      
      // 计算今天的提醒时间
      DateTime scheduledDate = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        hour,
        minute,
      );
      
      // 如果时间已过，设置为明天
      if (scheduledDate.isBefore(DateTime.now())) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }
      
      // 设置通知ID（使用药品ID和时间索引组合，确保唯一）
      int notificationId = _getNotificationId(medicine.id!, i);
      
      // 设置提醒通知
      await _notifications.zonedSchedule(
        notificationId,
        '该吃药了：${medicine.name}', // 通知标题
        '${medicine.dosage}，${medicine.frequency}', // 通知内容
        tz.TZDateTime.from(scheduledDate, tz.local), // 提醒时间
        _getNotificationDetails(medicine), // 通知详情
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // 精确提醒（即使设备休眠）
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time, // 每天重复
      );
      
      // 设置漏服二次提醒（15分钟后）
      DateTime reminderDate = scheduledDate.add(const Duration(minutes: AppConstants.reminderDelayMinutes));
      int reminderId = _getReminderNotificationId(medicine.id!, i);
      
      await _notifications.zonedSchedule(
        reminderId,
        '漏服提醒：${medicine.name}', // 漏服提醒标题
        '您可能忘记服药了，请及时服用 ${medicine.dosage}', // 漏服提醒内容
        tz.TZDateTime.from(reminderDate, tz.local),
        _getNotificationDetails(medicine, isReminder: true),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      
      // 创建今日的日志记录（如果还没有的话）
      try {
        // 检查今天是否已经有这个时间点的日志
        List<MedicineLog> todayLogs = await DatabaseHelper.instance.getLogsByDate(DateTime.now());
        bool logExists = todayLogs.any((log) => 
          log.medicineId == medicine.id && 
          log.scheduledTime.hour == hour && 
          log.scheduledTime.minute == minute &&
          log.scheduledTime.year == scheduledDate.year &&
          log.scheduledTime.month == scheduledDate.month &&
          log.scheduledTime.day == scheduledDate.day
        );
        
        if (!logExists) {
          // 创建新的日志记录
          MedicineLog log = MedicineLog(
            medicineId: medicine.id!,
            medicineName: medicine.name,
            scheduledTime: scheduledDate,
            isTaken: false,
            isOnTime: false,
          );
          
          await DatabaseHelper.instance.insertMedicineLog(log);
          print('已创建日志记录：${medicine.name} - ${timeStr}');
        }
      } catch (e) {
        print('创建日志记录失败: $e');
        // 继续执行，不影响提醒设置
      }
    }
  }
  
  /// 取消药品的所有提醒
  /// 参数：药品ID
  /// 功能：删除该药品的所有定时提醒
  Future<void> cancelMedicineReminders(int medicineId) async {
    // 获取药品信息（需要知道有几个时间点）
    // 这里简化处理：取消所有可能的通知ID
    // 实际项目中可以存储通知ID列表
    for (int i = 0; i < AppConstants.maxReminderTimes; i++) {
      int notificationId = _getNotificationId(medicineId, i);
      int reminderId = _getReminderNotificationId(medicineId, i);
      await _notifications.cancel(notificationId);
      await _notifications.cancel(reminderId);
    }
  }
  
  /// 获取通知详情配置
  /// 参数：
  /// - medicine: 药品对象
  /// - isReminder: 是否为漏服提醒（默认false）
  /// 返回：通知详情配置对象
  NotificationDetails _getNotificationDetails(Medicine medicine, {bool isReminder = false}) {
    // Android通知配置
    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'medicine_reminder_channel', // 通知渠道ID
      '吃药提醒', // 通知渠道名称
      channelDescription: '提醒您按时服药', // 渠道描述
      importance: Importance.high, // 高优先级
      priority: Priority.high, // 高优先级
      playSound: true, // 播放声音
      enableVibration: true, // 震动
      icon: '@mipmap/ic_launcher', // 通知图标
      color: isReminder 
          ? const Color(AppConstants.accentColorValue) // 漏服提醒用红色
          : const Color(AppConstants.primaryColorValue), // 正常提醒用蓝色
    );
    
    // iOS通知配置
    DarwinNotificationDetails iosDetails = const DarwinNotificationDetails(
      presentAlert: true, // 显示弹窗
      presentBadge: true, // 显示角标
      presentSound: true, // 播放声音
    );
    
    return NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
  }
  
  /// 生成通知ID（主提醒）
  /// 参数：药品ID和时间索引
  /// 返回：唯一的通知ID
  /// 说明：使用公式 medicineId * 1000 + timeIndex 确保ID唯一
  int _getNotificationId(int medicineId, int timeIndex) {
    return medicineId * 1000 + timeIndex;
  }
  
  /// 生成漏服提醒通知ID
  /// 参数：药品ID和时间索引
  /// 返回：唯一的通知ID
  /// 说明：使用公式 medicineId * 1000 + timeIndex + 100 确保ID唯一且与主提醒区分
  int _getReminderNotificationId(int medicineId, int timeIndex) {
    return medicineId * 1000 + timeIndex + 100;
  }
  
  /// 取消所有通知
  /// 功能：清除所有已设置的提醒（用于测试或重置）
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
  
  /// 显示即时通知（用于测试）
  /// 参数：标题和内容
  Future<void> showInstantNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'test_channel',
      '测试通知',
      channelDescription: '用于测试的通知渠道',
      importance: Importance.high,
      priority: Priority.high,
    );
    
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );
    
    await _notifications.show(
      999, // 测试通知ID
      title,
      body,
      notificationDetails,
    );
  }
}
