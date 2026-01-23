// 版权所有 (C) 2025 Pill Helper
// 本代码遵循 AGPL-3.0 开源协议，个人非商用可自由使用、修改；商用需联系作者授权

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/medicine_log.dart';
import '../database/database_helper.dart';
import '../utils/constants.dart';

/// 服药日志页面
/// 功能：显示所有服药记录，支持按日期筛选
/// 使用方法：从首页导航到此页面
class LogPage extends StatefulWidget {
  const LogPage({super.key});
  
  @override
  State<LogPage> createState() => _LogPageState();
}

class _LogPageState extends State<LogPage> {
  // 日志列表
  List<MedicineLog> logs = [];
  
  // 是否正在加载
  bool isLoading = true;
  
  // 选中的日期（用于筛选）
  DateTime? selectedDate;
  
  @override
  void initState() {
    super.initState();
    _loadLogs();
  }
  
  /// 加载日志列表
  /// 功能：从数据库获取日志，如果选中了日期则只获取该日期的日志
  Future<void> _loadLogs() async {
    setState(() {
      isLoading = true;
    });
    
    try {
      List<MedicineLog> allLogs;
      
      if (selectedDate != null) {
        // 获取指定日期的日志
        allLogs = await DatabaseHelper.instance.getLogsByDate(selectedDate!);
      } else {
        // 获取所有日志（限制最近100条）
        allLogs = await DatabaseHelper.instance.getAllMedicineLogs(limit: 100);
      }
      
      setState(() {
        logs = allLogs;
        isLoading = false;
      });
    } catch (e) {
      print('加载日志失败: $e');
      setState(() {
        isLoading = false;
      });
    }
  }
  
  /// 选择日期
  /// 功能：弹出日期选择器，筛选指定日期的日志
  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('zh', 'CN'),
    );
    
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
      _loadLogs();
    }
  }
  
  /// 清除日期筛选
  void _clearDateFilter() {
    setState(() {
      selectedDate = null;
    });
    _loadLogs();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('服药日志'),
        actions: [
          // 日期筛选按钮
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _selectDate,
            tooltip: '选择日期',
          ),
          // 清除筛选按钮
          if (selectedDate != null)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _clearDateFilter,
              tooltip: '清除筛选',
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadLogs,
              child: logs.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history,
                            size: 64,
                            color: Color(AppConstants.secondaryTextColorValue),
                          ),
                          SizedBox(height: 16),
                          Text(
                            '暂无日志记录',
                            style: TextStyle(
                              fontSize: AppConstants.largeFontSize,
                              color: Color(AppConstants.secondaryTextColorValue),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: logs.length,
                      padding: const EdgeInsets.all(16),
                      itemBuilder: (context, index) {
                        MedicineLog log = logs[index];
                        return _buildLogCard(log);
                      },
                    ),
            ),
    );
  }
  
  /// 构建日志卡片
  /// 参数：MedicineLog对象
  /// 返回：日志卡片Widget
  Widget _buildLogCard(MedicineLog log) {
    // 判断是否按时
    bool isOnTime = log.isOnTime;
    // 判断是否已服用
    bool isTaken = log.isTaken;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 第一行：药品名称和状态
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    log.medicineName,
                    style: const TextStyle(
                      fontSize: AppConstants.largeFontSize + 2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // 状态标签
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isTaken 
                        ? (isOnTime ? Colors.green : Colors.orange)
                        : Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isTaken 
                        ? (isOnTime ? '已按时服用' : '延迟服用')
                        : '未服用',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: AppConstants.smallFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // 计划时间
            Row(
              children: [
                const Icon(
                  Icons.schedule,
                  size: AppConstants.normalFontSize,
                  color: Color(AppConstants.primaryColorValue),
                ),
                const SizedBox(width: 8),
                Text(
                  '计划时间：${DateFormat('yyyy-MM-dd HH:mm').format(log.scheduledTime)}',
                  style: const TextStyle(
                    fontSize: AppConstants.normalFontSize,
                    color: Color(AppConstants.textColorValue),
                  ),
                ),
              ],
            ),
            
            // 实际服用时间（如果有）
            if (log.takenTime != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    size: AppConstants.normalFontSize,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '实际时间：${DateFormat('yyyy-MM-dd HH:mm').format(log.takenTime!)}',
                    style: const TextStyle(
                      fontSize: AppConstants.normalFontSize,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ],
            
            // 备注（如果有）
            if (log.note != null && log.note!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(AppConstants.backgroundColorValue),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.note,
                      size: AppConstants.smallFontSize,
                      color: Color(AppConstants.secondaryTextColorValue),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        log.note!,
                        style: const TextStyle(
                          fontSize: AppConstants.smallFontSize,
                          color: Color(AppConstants.secondaryTextColorValue),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
