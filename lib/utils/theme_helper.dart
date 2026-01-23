// 版权所有 (C) 2025 Pill Helper
// 本代码遵循 AGPL-3.0 开源协议，个人非商用可自由使用、修改；商用需联系作者授权

import 'package:flutter/material.dart';
import 'constants.dart';

/// 主题配置工具类
/// 功能：提供大字体、高对比度的主题配置，适配中老年用户
/// 使用方法：在 MaterialApp 中使用 ThemeHelper.getTheme() 获取主题
class ThemeHelper {
  /// 获取应用主题配置
  /// 返回：配置好的 ThemeData 对象，包含大字体和高对比度设置
  /// 注意：字体大小会根据屏幕尺寸自动适配（通过响应式字体工具类）
  static ThemeData getTheme() {
    return ThemeData(
      // 使用高对比度配色方案
      primaryColor: const Color(AppConstants.primaryColorValue),
      colorScheme: const ColorScheme.light(
        primary: Color(AppConstants.primaryColorValue),
        secondary: Color(AppConstants.accentColorValue),
        surface: Color(AppConstants.backgroundColorValue),
        onPrimary: Colors.white, // 主色上的文字颜色（白色）
        onSecondary: Colors.white, // 背景上的文字颜色（黑色）
        onSurface: Color(AppConstants.textColorValue), // 表面上的文字颜色（黑色）
      ),
      
      // 字体大小配置 - 已放大，支持响应式适配
      textTheme: TextTheme(
        // 超大标题（页面标题）
        displayLarge: TextStyle(
          fontSize: AppConstants.extraLargeFontSize,
          fontWeight: FontWeight.bold,
          color: const Color(AppConstants.textColorValue),
          height: 1.5, // 行高，增加可读性
        ),
        // 大标题
        displayMedium: TextStyle(
          fontSize: AppConstants.largeFontSize,
          fontWeight: FontWeight.bold,
          color: const Color(AppConstants.textColorValue),
          height: 1.5,
        ),
        // 普通标题
        titleLarge: TextStyle(
          fontSize: AppConstants.largeFontSize,
          fontWeight: FontWeight.w600,
          color: const Color(AppConstants.textColorValue),
          height: 1.5,
        ),
        // 正文
        bodyLarge: TextStyle(
          fontSize: AppConstants.largeFontSize,
          color: const Color(AppConstants.textColorValue),
          height: 1.6, // 行高稍大，便于阅读
        ),
        // 次要正文
        bodyMedium: TextStyle(
          fontSize: AppConstants.normalFontSize,
          color: const Color(AppConstants.secondaryTextColorValue),
          height: 1.5,
        ),
        // 小字
        bodySmall: TextStyle(
          fontSize: AppConstants.smallFontSize,
          color: const Color(AppConstants.secondaryTextColorValue),
          height: 1.4,
        ),
      ),
      
      // 按钮主题配置 - 大按钮，易于点击
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16), // 按钮内边距，增大点击区域
          textStyle: TextStyle(
            fontSize: AppConstants.largeFontSize,
            fontWeight: FontWeight.bold,
          ),
          minimumSize: const Size(120, 50), // 最小按钮尺寸，确保易于点击
        ),
      ),
      
      // 输入框主题配置
      inputDecorationTheme: InputDecorationTheme(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16), // 输入框内边距
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Color(AppConstants.primaryColorValue),
            width: 2, // 边框加粗，更明显
          ),
        ),
        labelStyle: TextStyle(
          fontSize: AppConstants.largeFontSize,
          color: const Color(AppConstants.textColorValue),
        ),
        hintStyle: TextStyle(
          fontSize: AppConstants.largeFontSize,
          color: const Color(AppConstants.secondaryTextColorValue),
        ),
      ),
      
      // 卡片主题配置
      cardTheme: CardThemeData(
        elevation: 4, // 卡片阴影，增加层次感
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      
      // 应用栏主题配置
      appBarTheme: AppBarTheme(
        elevation: 2,
        centerTitle: true, // 标题居中
        backgroundColor: const Color(AppConstants.primaryColorValue), // 蓝色背景，与底部导航栏一致
        foregroundColor: Colors.white, // 前景色（包括文字和图标）为白色，确保清晰可见
        titleTextStyle: TextStyle(
          fontSize: AppConstants.extraLargeFontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white, // 明确设置标题文字为白色
        ),
        iconTheme: const IconThemeData(
          color: Colors.white, // 图标颜色为白色，确保清晰可见
          size: 28, // 图标放大，易于点击
        ),
        actionsIconTheme: const IconThemeData(
          color: Colors.white, // 右侧操作按钮图标颜色为白色
          size: 28,
        ),
      ),
    );
  }
}
