// 版权所有 (C) 2025 Pill Helper
// 本代码遵循 AGPL-3.0 开源协议，个人非商用可自由使用、修改；商用需联系作者授权

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'services/notification_service.dart';
import 'services/ai_service.dart';
import 'utils/theme_helper.dart';
import 'pages/home_page.dart';

/// 应用入口
/// 功能：初始化应用，设置主题，启动首页
/// 使用方法：Flutter会自动调用main函数启动应用
void main() async {
  // 确保Flutter绑定已初始化
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化日期格式化（支持中文）
  await initializeDateFormatting('zh_CN', null);
  
  // 配置AI服务（火山方舟）
  // 优先从环境变量读取API密钥，如果没有则使用默认值
  String? apiKey = Platform.environment['ARK_API_KEY'];
  if (apiKey == null || apiKey.isEmpty) {
    apiKey = '648f3155-6d0b-4efb-a3ce-dd4ee86cbb7c'; // 默认API密钥
    print('未找到环境变量 ARK_API_KEY，使用默认API密钥');
  } else {
    print('从环境变量读取API密钥');
  }
  
  // 使用接入点ID：ep-20260121173048-dmlkh
  // 注意：接入点ID可以在火山方舟控制台的"在线推理" -> "推理接入点"中获取
  AIService.instance.setApiKey(
    apiKey,
    type: 'volcano',
    endpointId: 'ep-20260121173048-dmlkh', // 使用你的接入点ID
  );
  
  // 设置屏幕方向（可选：锁定竖屏）
  // 注意：Web 平台可能不支持，使用 try-catch 处理
  try {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  } catch (e) {
    // Web 平台可能不支持，忽略错误
    print('设置屏幕方向失败（Web平台可能不支持）: $e');
  }
  
  // 初始化通知服务（Web 平台可能不支持，使用 try-catch 处理）
  try {
    await NotificationService.instance.initialize();
  } catch (e) {
    print('初始化通知服务失败（Web平台可能不支持）: $e');
  }
  
  // 运行应用
  runApp(const PillHelperApp());
}

/// 主应用组件
/// 功能：配置应用主题、路由等全局设置
class PillHelperApp extends StatelessWidget {
  const PillHelperApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // 应用标题
      title: 'Pill Helper - 吃药提醒',
      
      // 主题配置（大字体、高对比度）
      theme: ThemeHelper.getTheme(),
      
      // 调试模式标志（开发时显示，发布时移除）
      debugShowCheckedModeBanner: false,
      
      // 首页
      home: const HomePage(),
    );
  }
}
