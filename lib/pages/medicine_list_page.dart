// 版权所有 (C) 2025 Pill Helper
// 本代码遵循 AGPL-3.0 开源协议，个人非商用可自由使用、修改；商用需联系作者授权

import 'package:flutter/material.dart';
import '../models/medicine.dart';
import '../database/database_helper.dart';
import '../services/notification_service.dart';
import '../widgets/medicine_card.dart';
import '../utils/constants.dart';
import 'add_medicine_page.dart';
import 'medicine_detail_page.dart';

/// 药品列表页面
/// 功能：显示所有药品列表，支持编辑、删除、启用/禁用
/// 使用方法：从首页导航到此页面
class MedicineListPage extends StatefulWidget {
  const MedicineListPage({super.key});
  
  @override
  State<MedicineListPage> createState() => _MedicineListPageState();
}

class _MedicineListPageState extends State<MedicineListPage> {
  // 药品列表
  List<Medicine> medicines = [];
  
  // 是否正在加载
  bool isLoading = true;
  
  // 是否只显示启用的药品
  bool showOnlyActive = false;
  
  @override
  void initState() {
    super.initState();
    _loadMedicines();
  }
  
  /// 加载药品列表
  /// 功能：从数据库获取所有药品
  Future<void> _loadMedicines() async {
    setState(() {
      isLoading = true;
    });
    
    try {
      List<Medicine> allMedicines = await DatabaseHelper.instance.getAllMedicines();
      setState(() {
        medicines = allMedicines;
        isLoading = false;
      });
    } catch (e) {
      print('加载药品列表失败: $e');
      setState(() {
        isLoading = false;
      });
    }
  }
  
  /// 删除药品
  /// 参数：药品对象
  /// 功能：删除药品并取消相关提醒
  Future<void> _deleteMedicine(Medicine medicine) async {
    // 确认对话框
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除"${medicine.name}"吗？此操作不可恢复。'),
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
        if (medicine.id != null) {
          await NotificationService.instance.cancelMedicineReminders(medicine.id!);
        }
        
        // 删除药品
        if (medicine.id != null) {
          await DatabaseHelper.instance.deleteMedicine(medicine.id!);
        }
        
        // 刷新列表
        _loadMedicines();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('已删除'),
              backgroundColor: Colors.green,
            ),
          );
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
  
  /// 切换启用状态
  /// 参数：药品对象
  /// 功能：启用或禁用药品提醒
  Future<void> _toggleActive(Medicine medicine) async {
    try {
      Medicine updated = medicine.copyWith(isActive: !medicine.isActive);
      await DatabaseHelper.instance.updateMedicine(updated);
      
      // 更新提醒
      if (updated.isActive) {
        await NotificationService.instance.scheduleMedicineReminders(updated);
      } else {
        if (medicine.id != null) {
          await NotificationService.instance.cancelMedicineReminders(medicine.id!);
        }
      }
      
      // 刷新列表
      _loadMedicines();
    } catch (e) {
      print('更新失败: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    // 过滤药品列表
    List<Medicine> displayedMedicines = showOnlyActive
        ? medicines.where((m) => m.isActive).toList()
        : medicines;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('药品列表'),
        actions: [
          // 筛选按钮
          IconButton(
            icon: Icon(showOnlyActive ? Icons.filter_alt : Icons.filter_alt_outlined),
            onPressed: () {
              setState(() {
                showOnlyActive = !showOnlyActive;
              });
            },
            tooltip: showOnlyActive ? '显示全部' : '只显示启用',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadMedicines,
              child: displayedMedicines.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.medication_outlined,
                            size: 64,
                            color: Color(AppConstants.secondaryTextColorValue),
                          ),
                          SizedBox(height: 16),
                          Text(
                            '暂无药品',
                            style: TextStyle(
                              fontSize: AppConstants.largeFontSize,
                              color: Color(AppConstants.secondaryTextColorValue),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '点击右下角按钮添加药品',
                            style: TextStyle(
                              fontSize: AppConstants.normalFontSize,
                              color: Color(AppConstants.secondaryTextColorValue),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: displayedMedicines.length,
                      padding: const EdgeInsets.all(16),
                      itemBuilder: (context, index) {
                        Medicine medicine = displayedMedicines[index];
                        return Column(
                          children: [
                            MedicineCard(
                              medicine: medicine,
                              onTap: () {
                                // 点击查看详情
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MedicineDetailPage(medicine: medicine),
                                  ),
                                ).then((_) => _loadMedicines());
                              },
                            ),
                            // 操作按钮
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // 编辑按钮
                                TextButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AddMedicinePage(medicine: medicine),
                                      ),
                                    ).then((_) => _loadMedicines());
                                  },
                                  icon: const Icon(Icons.edit, size: 20),
                                  label: const Text('编辑'),
                                ),
                                // 启用/禁用按钮
                                TextButton.icon(
                                  onPressed: () => _toggleActive(medicine),
                                  icon: Icon(
                                    medicine.isActive ? Icons.pause : Icons.play_arrow,
                                    size: 20,
                                  ),
                                  label: Text(medicine.isActive ? '禁用' : '启用'),
                                ),
                                // 删除按钮
                                TextButton.icon(
                                  onPressed: () => _deleteMedicine(medicine),
                                  icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                                  label: const Text('删除', style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                          ],
                        );
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddMedicinePage()),
          ).then((_) => _loadMedicines());
        },
        icon: const Icon(Icons.add),
        label: const Text('添加药品'),
      ),
    );
  }
}
