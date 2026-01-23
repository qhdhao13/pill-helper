// 版权所有 (C) 2025 Pill Helper
// 本代码遵循 AGPL-3.0 开源协议，个人非商用可自由使用、修改；商用需联系作者授权

import 'package:flutter/material.dart';
import '../models/medicine.dart';
import '../database/database_helper.dart';
import '../services/notification_service.dart';
import '../utils/constants.dart';
import 'add_medicine_page.dart';

/// 药品详情页面
/// 功能：显示药品的详细信息，包括所有字段
/// 使用方法：从药品列表页面导航到此页面
class MedicineDetailPage extends StatefulWidget {
  // 药品对象
  final Medicine medicine;
  
  const MedicineDetailPage({super.key, required this.medicine});
  
  @override
  State<MedicineDetailPage> createState() => _MedicineDetailPageState();
}

class _MedicineDetailPageState extends State<MedicineDetailPage> {
  /// 删除药品
  /// 功能：删除药品并取消相关提醒，然后返回上一页
  Future<void> _deleteMedicine() async {
    // 确认对话框
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除"${widget.medicine.name}"吗？此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      try {
        // 取消提醒
        if (widget.medicine.id != null) {
          await NotificationService.instance.cancelMedicineReminders(widget.medicine.id!);
        }
        
        // 删除药品
        if (widget.medicine.id != null) {
          await DatabaseHelper.instance.deleteMedicine(widget.medicine.id!);
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('已删除'),
              backgroundColor: Colors.green,
            ),
          );
          
          // 返回上一页
          Navigator.pop(context, true);
        }
      } catch (e) {
        print('删除失败: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('删除失败，请重试'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('药品详情'),
        actions: [
          // 编辑按钮
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddMedicinePage(medicine: widget.medicine),
                ),
              );
            },
            tooltip: '编辑',
          ),
          // 删除按钮
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteMedicine,
            tooltip: '删除',
            color: Colors.red,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 药品名称（大标题）
            Text(
              widget.medicine.name,
              style: const TextStyle(
                fontSize: AppConstants.extraLargeFontSize + 4,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // 状态标签
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: widget.medicine.isActive ? Colors.green : Colors.grey,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                widget.medicine.isActive ? '已启用' : '已禁用',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: AppConstants.normalFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 详细信息卡片
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 剂量
                    _buildInfoRow(
                      icon: Icons.straighten,
                      label: '剂量',
                      value: widget.medicine.dosage,
                    ),
                    
                    const Divider(),
                    
                    // 频次
                    _buildInfoRow(
                      icon: Icons.repeat,
                      label: '服用频次',
                      value: widget.medicine.frequency,
                    ),
                    
                    const Divider(),
                    
                    // 服用时间
                    _buildInfoRow(
                      icon: Icons.access_time,
                      label: '服用时间',
                      value: widget.medicine.getTimeList().join('、'),
                    ),
                    
                    // 说明（如果有）
                    if (widget.medicine.instructions != null && widget.medicine.instructions!.isNotEmpty) ...[
                      const Divider(),
                      _buildInfoRow(
                        icon: Icons.info_outline,
                        label: '服用说明',
                        value: widget.medicine.instructions!,
                      ),
                    ],
                    
                    // 禁忌（如果有）
                    if (widget.medicine.contraindications != null && widget.medicine.contraindications!.isNotEmpty) ...[
                      const Divider(),
                      _buildInfoRow(
                        icon: Icons.warning,
                        label: '禁忌说明',
                        value: widget.medicine.contraindications!,
                        isWarning: true,
                      ),
                    ],
                    
                    // 主治功能（如果有）
                    if (widget.medicine.indications != null && widget.medicine.indications!.isNotEmpty) ...[
                      const Divider(),
                      _buildInfoRow(
                        icon: Icons.medical_services,
                        label: '主治功能',
                        value: widget.medicine.indications!,
                      ),
                    ],
                    
                    // 每日最大剂量限制（如果有）
                    if (widget.medicine.maxDailyDosage != null && widget.medicine.maxDailyDosage!.isNotEmpty) ...[
                      const Divider(),
                      _buildInfoRow(
                        icon: Icons.warning_amber,
                        label: '每日最大剂量限制',
                        value: widget.medicine.maxDailyDosage!,
                        isWarning: true,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            const SizedBox(height: 24),
            
            // 操作按钮区域
            Row(
              children: [
                // 编辑按钮
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddMedicinePage(medicine: widget.medicine),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('编辑'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // 删除按钮
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _deleteMedicine,
                    icon: const Icon(Icons.delete),
                    label: const Text('删除'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // 创建时间
            Text(
              '创建时间：${_formatDateTime(widget.medicine.createdAt)}',
              style: const TextStyle(
                fontSize: AppConstants.smallFontSize,
                color: Color(AppConstants.secondaryTextColorValue),
              ),
            ),
            
            const SizedBox(height: 4),
            
            // 更新时间
            Text(
              '更新时间：${_formatDateTime(widget.medicine.updatedAt)}',
              style: const TextStyle(
                fontSize: AppConstants.smallFontSize,
                color: Color(AppConstants.secondaryTextColorValue),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// 构建信息行
  /// 参数：
  /// - icon: 图标
  /// - label: 标签
  /// - value: 值
  /// - isWarning: 是否为警告（红色显示）
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    bool isWarning = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: AppConstants.largeFontSize,
          color: isWarning 
              ? const Color(AppConstants.accentColorValue) 
              : const Color(AppConstants.primaryColorValue),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: AppConstants.smallFontSize,
                  color: Color(AppConstants.secondaryTextColorValue),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: AppConstants.largeFontSize,
                  color: isWarning 
                      ? const Color(AppConstants.accentColorValue) 
                      : const Color(AppConstants.textColorValue),
                  fontWeight: isWarning ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  /// 格式化日期时间
  /// 参数：DateTime对象
  /// 返回：格式化后的字符串
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
