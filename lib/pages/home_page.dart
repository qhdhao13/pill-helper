// 版权所有 (C) 2025 Pill Helper
// 本代码遵循 AGPL-3.0 开源协议，个人非商用可自由使用、修改；商用需联系作者授权

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/medicine.dart';
import '../models/medicine_log.dart';
import '../database/database_helper.dart';
import '../widgets/medicine_card.dart';
import '../widgets/large_text_button.dart';
import '../services/dosage_limit_service.dart';
import '../utils/constants.dart';
import 'add_medicine_page.dart';
import 'medicine_list_page.dart';
import 'log_page.dart';
import 'settings_page.dart';

/// 首页
/// 功能：显示今日待服药品列表，提供快速操作入口
/// 使用方法：作为应用的首页，自动加载今日数据
class HomePage extends StatefulWidget {
  const HomePage({super.key});
  
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // 今日待服药品列表
  List<Medicine> todayMedicines = [];
  
  // 今日待服日志列表（未服用的）
  List<MedicineLog> todayPendingLogs = [];
  
  // 是否正在加载数据
  bool isLoading = true;
  
  // 当前选中的底部导航栏索引
  int _currentIndex = 0;
  
  @override
  void initState() {
    super.initState();
    // 页面初始化时加载数据
    _loadTodayData();
  }
  
  /// 加载今日数据
  /// 功能：从数据库获取今日待服的药品和日志
  Future<void> _loadTodayData() async {
    setState(() {
      isLoading = true;
    });
    
    try {
      // 获取所有启用的药品
      List<Medicine> allMedicines = await DatabaseHelper.instance.getAllMedicines(onlyActive: true);
      
      // 获取今日待服的日志
      List<MedicineLog> pendingLogs = await DatabaseHelper.instance.getTodayPendingLogs();
      
      // 获取今天的日期（只比较年月日）
      DateTime now = DateTime.now();
      DateTime today = DateTime(now.year, now.month, now.day);
      
      // 筛选今日待服的药品：
      // 1. 有今日待服日志的药品
      // 2. 或者药品的服用时间包含今天的时间点
      List<Medicine> todayMedicinesList = [];
      
      for (Medicine medicine in allMedicines) {
        bool shouldShow = false;
        
        // 方法1：检查是否有今日待服的日志
        bool hasPendingLog = pendingLogs.any((log) => log.medicineId == medicine.id);
        if (hasPendingLog) {
          shouldShow = true;
        } else {
          // 方法2：检查药品的服用时间是否包含今天的时间点
          List<String> timeList = medicine.getTimeList();
          for (String timeStr in timeList) {
            List<String> parts = timeStr.split(':');
            if (parts.length == 2) {
              int hour = int.tryParse(parts[0]) ?? 0;
              int minute = int.tryParse(parts[1]) ?? 0;
              
              // 计算今天的这个时间点
              DateTime scheduledTime = DateTime(today.year, today.month, today.day, hour, minute);
              
              // 如果时间还没到，或者时间已过但还没超过30分钟（算作待服）
              if (scheduledTime.isAfter(now) || 
                  (scheduledTime.isBefore(now) && now.difference(scheduledTime).inMinutes <= 30)) {
                shouldShow = true;
                
                // 如果还没有日志记录，创建一个
                try {
                  bool logExists = pendingLogs.any((log) => 
                    log.medicineId == medicine.id && 
                    log.scheduledTime.hour == hour && 
                    log.scheduledTime.minute == minute &&
                    log.scheduledTime.year == today.year &&
                    log.scheduledTime.month == today.month &&
                    log.scheduledTime.day == today.day
                  );
                  
                  if (!logExists) {
                    MedicineLog log = MedicineLog(
                      medicineId: medicine.id!,
                      medicineName: medicine.name,
                      scheduledTime: scheduledTime,
                      isTaken: false,
                      isOnTime: false,
                    );
                    await DatabaseHelper.instance.insertMedicineLog(log);
                    pendingLogs.add(log);
                    print('自动创建日志记录：${medicine.name} - $timeStr');
                  }
                } catch (e) {
                  print('创建日志记录失败: $e');
                }
                
                break;
              }
            }
          }
        }
        
        if (shouldShow) {
          todayMedicinesList.add(medicine);
        }
      }
      
      setState(() {
        todayMedicines = todayMedicinesList;
        todayPendingLogs = pendingLogs;
        isLoading = false;
      });
    } catch (e) {
      print('加载数据失败: $e');
      setState(() {
        isLoading = false;
      });
    }
  }
  
  /// 标记为已服用
  /// 参数：日志ID
  /// 功能：将指定的日志标记为已服用，并更新数据库
  Future<void> _markAsTaken(int logId) async {
    try {
      // 获取日志
      List<MedicineLog> allLogs = await DatabaseHelper.instance.getAllMedicineLogs();
      MedicineLog? log = allLogs.firstWhere((l) => l.id == logId);
      
      // 更新为已服用
      DateTime now = DateTime.now();
      bool isOnTime = now.difference(log.scheduledTime).inMinutes <= 30; // 30分钟内算按时
      
      MedicineLog updatedLog = log.copyWith(
        isTaken: true,
        takenTime: now,
        isOnTime: isOnTime,
      );
      
      await DatabaseHelper.instance.updateMedicineLog(updatedLog);
      
      // 刷新数据
      _loadTodayData();
      
      // 显示提示
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('已记录：${log.medicineName}'),
            duration: Duration(seconds: 2),
          ),
        );
      }
        } catch (e) {
      print('标记失败: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('操作失败，请重试'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('吃药提醒'),
        actions: [
          // 设置按钮
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
            tooltip: '设置',
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              // 下拉刷新
              onRefresh: _loadTodayData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 今日日期显示
                    Text(
                      '今天是 ${DateFormat('yyyy年MM月dd日 EEEE', 'zh_CN').format(DateTime.now())}',
                      style: const TextStyle(
                        fontSize: AppConstants.largeFontSize,
                        color: Color(AppConstants.secondaryTextColorValue),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // 今日待服药品标题
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '今日待服药品',
                          style: TextStyle(
                            fontSize: AppConstants.extraLargeFontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '共 ${todayMedicines.length} 种',
                          style: const TextStyle(
                            fontSize: AppConstants.normalFontSize,
                            color: Color(AppConstants.secondaryTextColorValue),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // 药品列表
                    if (todayMedicines.isEmpty)
                      // 没有待服药品时的提示
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Column(
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                size: 64,
                                color: Colors.green,
                              ),
                              SizedBox(height: 16),
                              Text(
                                '今天没有待服药品',
                                style: TextStyle(
                                  fontSize: AppConstants.largeFontSize,
                                  color: Color(AppConstants.secondaryTextColorValue),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      // 显示药品列表
                      ...todayMedicines.map((medicine) {
                        // 找到该药品对应的待服日志
                        List<MedicineLog> medicineLogs = todayPendingLogs
                            .where((log) => log.medicineId == medicine.id)
                            .toList();
                        
                        return FutureBuilder<bool>(
                          future: DosageLimitService.instance.checkDosageLimit(medicine),
                          builder: (context, snapshot) {
                            bool isLimitReached = snapshot.data ?? false;
                            
                            return Column(
                              children: [
                                MedicineCard(
                                  medicine: medicine,
                                  isLargeFont: true, // 始终使用大字体
                                  onTap: null,
                                ),
                                
                                // 剂量限制提醒
                                if (isLimitReached && medicine.maxDailyDosage != null)
                                  Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade100,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.red, width: 2),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.warning, color: Colors.red, size: 24),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            '⚠️ 已达到每日最大剂量限制：${medicine.maxDailyDosage}',
                                            style: TextStyle(
                                              fontSize: AppConstants.largeFontSize,
                                              color: Colors.red.shade900,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                
                                // 显示待服时间和"已按时吃药"按钮
                                if (medicineLogs.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.schedule,
                                              size: 16,
                                              color: Color(AppConstants.accentColorValue),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                '待服时间：${medicineLogs.map((log) => DateFormat('HH:mm').format(log.scheduledTime)).join('、')}',
                                                style: const TextStyle(
                                                  fontSize: AppConstants.smallFontSize,
                                                  color: Color(AppConstants.accentColorValue),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        // "已按时吃药"按钮
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton.icon(
                                            onPressed: isLimitReached ? null : () {
                                              if (medicineLogs.isNotEmpty) {
                                                _markAsTaken(medicineLogs.first.id!);
                                              }
                                            },
                                            icon: const Icon(Icons.check_circle),
                                            label: const Text(
                                              '已按时吃药',
                                              style: TextStyle(
                                                fontSize: AppConstants.largeFontSize,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green,
                                              foregroundColor: Colors.white,
                                              padding: const EdgeInsets.symmetric(vertical: 16),
                                              disabledBackgroundColor: Colors.grey,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                const SizedBox(height: 8),
                              ],
                            );
                          },
                        );
                      }),
                    
                    const SizedBox(height: 32),
                    
                    // 快速操作：添加药品按钮
                    // 注意：药品列表、服药日志已移至底部导航栏，这里只保留添加药品按钮
                    SizedBox(
                      width: double.infinity,
                      child: LargeTextButton(
                        text: '添加药品',
                        isLargeFont: true, // 始终使用大字体
                        color: const Color(AppConstants.primaryColorValue),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddMedicinePage(),
                            ),
                          ).then((_) => _loadTodayData());
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
      // 底部导航栏 - 方便快速切换页面
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white, // 白色背景，确保清晰可见
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1), // 添加阴影，增加层次感
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
            
            // 根据索引导航到不同页面
            switch (index) {
              case 0:
                // 首页，已经在首页，刷新数据即可
                _loadTodayData();
                break;
              case 1:
                // 药品列表
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MedicineListPage()),
                ).then((_) => _loadTodayData());
                break;
              case 2:
                // 服药日志
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LogPage()),
                );
                break;
            }
          },
          type: BottomNavigationBarType.fixed, // 固定类型，显示所有标签
          backgroundColor: Colors.white, // 明确设置白色背景
          selectedItemColor: const Color(AppConstants.primaryColorValue), // 选中颜色（蓝色）
          unselectedItemColor: Colors.grey[600]!, // 未选中颜色（深灰色，提高对比度）
          selectedFontSize: AppConstants.largeFontSize, // 选中字体大小（增大）
          unselectedFontSize: AppConstants.normalFontSize, // 未选中字体大小（增大）
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold, // 选中文字加粗
          ),
          iconSize: 32, // 图标大小（增大，更易识别）
          elevation: 8, // 阴影高度，增加层次感
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '首页',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medication),
            label: '药品列表',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: '服药日志',
          ),
        ],
        ),
      ),
    );
  }
}
