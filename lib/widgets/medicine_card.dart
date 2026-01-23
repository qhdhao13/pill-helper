// 版权所有 (C) 2025 Pill Helper
// 本代码遵循 AGPL-3.0 开源协议，个人非商用可自由使用、修改；商用需联系作者授权

import 'package:flutter/material.dart';
import '../models/medicine.dart';
import '../utils/constants.dart';

/// 药品卡片组件
/// 功能：显示药品信息的卡片，用于列表展示
/// 使用方法：传入Medicine对象，自动渲染卡片
class MedicineCard extends StatelessWidget {
  // 药品对象
  final Medicine medicine;
  
  // 点击回调函数
  final VoidCallback? onTap;
  
  // 是否显示大字体（长辈模式）
  final bool isLargeFont;
  
  /// 构造函数
  /// 参数：
  /// - medicine: 药品对象（必填）
  /// - onTap: 点击回调（可选）
  /// - isLargeFont: 是否大字体（默认false）
  const MedicineCard({
    super.key,
    required this.medicine,
    this.onTap,
    this.isLargeFont = false,
  });
  
  @override
  Widget build(BuildContext context) {
    // 获取字体大小
    double fontSize = isLargeFont 
        ? AppConstants.largeFontSize + 4 
        : AppConstants.largeFontSize;
    
    Widget cardContent = Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 第一行：药品名称和状态
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 药品名称
                Expanded(
                  child: Text(
                    medicine.name,
                    style: TextStyle(
                      fontSize: fontSize + 2,
                      fontWeight: FontWeight.bold,
                      color: const Color(AppConstants.textColorValue),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // 启用状态指示器
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: medicine.isActive 
                        ? Colors.green 
                        : Colors.grey,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // 第二行：剂量和频次
            Row(
              children: [
                Icon(
                  Icons.medication,
                  size: fontSize,
                  color: const Color(AppConstants.primaryColorValue),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${medicine.dosage} · ${medicine.frequency}',
                    style: TextStyle(
                      fontSize: fontSize,
                      color: const Color(AppConstants.textColorValue),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // 第三行：服用时间
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: fontSize,
                  color: const Color(AppConstants.primaryColorValue),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    medicine.getTimeList().join('、'),
                    style: TextStyle(
                      fontSize: fontSize - 2,
                      color: const Color(AppConstants.secondaryTextColorValue),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            
            // 如果有说明或禁忌，显示
            if (medicine.instructions != null && medicine.instructions!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: fontSize - 4,
                    color: const Color(AppConstants.secondaryTextColorValue),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      medicine.instructions!,
                      style: TextStyle(
                        fontSize: fontSize - 4,
                        color: const Color(AppConstants.secondaryTextColorValue),
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      );
    
    // 如果有点击回调，用 InkWell 包裹
    if (onTap != null) {
      return Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: cardContent,
        ),
      );
    } else {
      return Card(
        child: cardContent,
      );
    }
  }
}
