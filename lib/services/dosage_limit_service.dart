// 版权所有 (C) 2025 Pill Helper
// 本代码遵循 AGPL-3.0 开源协议，个人非商用可自由使用、修改；商用需联系作者授权

import '../models/medicine.dart';
import '../models/medicine_log.dart';
import '../database/database_helper.dart';

/// 剂量限制检查服务
/// 功能：检查是否达到用药剂量限制，并发出明显提醒
/// 使用方法：调用 checkDosageLimit() 方法检查
class DosageLimitService {
  static final DosageLimitService instance = DosageLimitService._internal();
  DosageLimitService._internal();
  
  /// 检查药品是否达到每日剂量限制
  /// 参数：药品对象
  /// 返回：如果达到限制返回true，否则返回false
  /// 说明：根据药品的maxDailyDosage和今日已服次数判断
  Future<bool> checkDosageLimit(Medicine medicine) async {
    if (medicine.maxDailyDosage == null || medicine.maxDailyDosage!.isEmpty) {
      return false; // 没有设置限制，不检查
    }
    
    try {
      // 获取今日该药品的服药记录
      DateTime today = DateTime.now();
      List<MedicineLog> todayLogs = await DatabaseHelper.instance.getLogsByDate(today);
      
      // 筛选出该药品且已服用的记录
      int takenCount = todayLogs
          .where((log) => log.medicineId == medicine.id && log.isTaken)
          .length;
      
      // 解析最大剂量限制（例如："最多3次"、"最多6片"）
      int? maxCount = _parseMaxDosage(medicine.maxDailyDosage!);
      
      if (maxCount != null && takenCount >= maxCount) {
        return true; // 达到限制
      }
      
      return false;
    } catch (e) {
      print('检查剂量限制失败: $e');
      return false;
    }
  }
  
  /// 解析最大剂量限制字符串
  /// 参数：限制字符串（例如："最多3次"、"最多6片"、"每日不超过4次"）
  /// 返回：最大次数，如果解析失败返回null
  int? _parseMaxDosage(String maxDosageStr) {
    try {
      // 提取数字
      RegExp regex = RegExp(r'\d+');
      Match? match = regex.firstMatch(maxDosageStr);
      
      if (match != null) {
        return int.parse(match.group(0)!);
      }
    } catch (e) {
      print('解析最大剂量失败: $e');
    }
    
    return null;
  }
  
  /// 获取今日已服次数
  /// 参数：药品ID
  /// 返回：今日已服次数
  Future<int> getTodayTakenCount(int medicineId) async {
    try {
      DateTime today = DateTime.now();
      List<MedicineLog> todayLogs = await DatabaseHelper.instance.getLogsByDate(today);
      
      return todayLogs
          .where((log) => log.medicineId == medicineId && log.isTaken)
          .length;
    } catch (e) {
      print('获取今日已服次数失败: $e');
      return 0;
    }
  }
  
  /// 获取剩余可服次数
  /// 参数：药品对象
  /// 返回：剩余可服次数，如果没有限制返回null
  Future<int?> getRemainingDosage(Medicine medicine) async {
    if (medicine.maxDailyDosage == null || medicine.maxDailyDosage!.isEmpty) {
      return null; // 没有限制
    }
    
    int? maxCount = _parseMaxDosage(medicine.maxDailyDosage!);
    if (maxCount == null) {
      return null;
    }
    
    int takenCount = await getTodayTakenCount(medicine.id!);
    int remaining = maxCount - takenCount;
    
    return remaining > 0 ? remaining : 0;
  }
  
  /// 检查是否可以继续服药
  /// 参数：药品对象
  /// 返回：true=可以继续，false=已达到限制
  Future<bool> canTakeMore(Medicine medicine) async {
    bool isLimitReached = await checkDosageLimit(medicine);
    return !isLimitReached;
  }
}
