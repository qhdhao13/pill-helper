// 版权所有 (C) 2025 Pill Helper
// 本代码遵循 AGPL-3.0 开源协议，个人非商用可自由使用、修改；商用需联系作者授权

import 'package:flutter/material.dart';

/// 响应式字体大小工具类
/// 功能：根据屏幕尺寸自动调整字体大小，适配不同手机屏幕
/// 使用方法：调用 ResponsiveFont.getFontSize() 获取适配后的字体大小
class ResponsiveFont {
  // 基准屏幕宽度（以 iPhone 12/13 为基准，宽度 390）
  static const double baseScreenWidth = 390.0;
  
  // 最小缩放比例（小屏幕手机）
  static const double minScale = 0.85;
  
  // 最大缩放比例（大屏幕手机）
  static const double maxScale = 1.2;
  
  /// 获取响应式字体大小
  /// 参数：
  /// - baseSize: 基础字体大小
  /// - context: BuildContext（用于获取屏幕尺寸）
  /// 返回：根据屏幕尺寸调整后的字体大小
  static double getFontSize(double baseSize, BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double screenWidth = mediaQuery.size.width;
    
    // 计算缩放比例
    double scale = screenWidth / baseScreenWidth;
    
    // 限制缩放范围
    if (scale < minScale) scale = minScale;
    if (scale > maxScale) scale = maxScale;
    
    // 返回调整后的字体大小
    return baseSize * scale;
  }
  
  /// 获取响应式字体大小（使用 MediaQueryData）
  /// 参数：
  /// - baseSize: 基础字体大小
  /// - mediaQuery: MediaQueryData（用于获取屏幕尺寸）
  /// 返回：根据屏幕尺寸调整后的字体大小
  static double getFontSizeFromMediaQuery(double baseSize, MediaQueryData mediaQuery) {
    final double screenWidth = mediaQuery.size.width;
    
    // 计算缩放比例
    double scale = screenWidth / baseScreenWidth;
    
    // 限制缩放范围
    if (scale < minScale) scale = minScale;
    if (scale > maxScale) scale = maxScale;
    
    // 返回调整后的字体大小
    return baseSize * scale;
  }
}
