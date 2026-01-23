// 版权所有 (C) 2025 Pill Helper
// 本代码遵循 AGPL-3.0 开源协议，个人非商用可自由使用、修改；商用需联系作者授权

import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// 大字体按钮组件
/// 功能：提供易于点击的大按钮，适配中老年用户
/// 使用方法：传入文本和点击回调函数
class LargeTextButton extends StatelessWidget {
  // 按钮文本
  final String text;
  
  // 点击回调函数
  final VoidCallback? onPressed;
  
  // 按钮颜色（可选）
  final Color? color;
  
  // 是否大字体模式
  final bool isLargeFont;
  
  // 按钮宽度（可选，默认自适应）
  final double? width;
  
  /// 构造函数
  /// 参数：
  /// - text: 按钮文本（必填）
  /// - onPressed: 点击回调（可选，null时按钮禁用）
  /// - color: 按钮颜色（可选）
  /// - isLargeFont: 是否大字体（默认true）
  /// - width: 按钮宽度（可选）
  const LargeTextButton({
    super.key,
    required this.text,
    this.onPressed,
    this.color,
    this.isLargeFont = true,
    this.width,
  });
  
  @override
  Widget build(BuildContext context) {
    // 计算字体大小
    double fontSize = isLargeFont 
        ? AppConstants.largeFontSize + 4 
        : AppConstants.largeFontSize;
    
    // 计算按钮高度
    double buttonHeight = isLargeFont ? 60 : 50;
    
    return SizedBox(
      width: width,
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? const Color(AppConstants.primaryColorValue),
          foregroundColor: Colors.white,
          textStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4, // 阴影效果，增加立体感
        ),
        child: Text(text),
      ),
    );
  }
}
