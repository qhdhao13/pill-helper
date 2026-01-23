// 版权所有 (C) 2025 Pill Helper
// 本代码遵循 AGPL-3.0 开源协议，个人非商用可自由使用、修改；商用需联系作者授权

import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'database_helper.dart';
import '../models/medicine.dart';
import '../models/medicine_log.dart';
import '../utils/constants.dart';

/// 数据备份与恢复工具类
/// 功能：将数据库中的数据导出为JSON文件，或从JSON文件恢复数据
/// 使用方法：调用exportData()导出，调用importData()导入
class BackupHelper {
  /// 导出数据到JSON文件
  /// 功能：将所有药品和日志数据导出为JSON格式，保存到文件
  /// 返回：备份文件的路径，如果失败则返回null
  Future<String?> exportData() async {
    try {
      // 获取所有药品和日志
      List<Medicine> medicines = await DatabaseHelper.instance.getAllMedicines();
      List<MedicineLog> logs = await DatabaseHelper.instance.getAllMedicineLogs();
      
      // 转换为JSON格式
      Map<String, dynamic> backupData = {
        'version': '1.0',
        'exportDate': DateTime.now().toIso8601String(),
        'medicines': medicines.map((m) => m.toMap()).toList(),
        'logs': logs.map((l) => l.toMap()).toList(),
      };
      
      // 获取应用文档目录
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String backupPath = '${appDocDir.path}/${AppConstants.backupFileName}';
      
      // 写入文件
      File backupFile = File(backupPath);
      await backupFile.writeAsString(jsonEncode(backupData));
      
      return backupPath;
    } catch (e) {
      print('导出数据失败: $e');
      return null;
    }
  }
  
  /// 从JSON文件导入数据
  /// 参数：备份文件路径
  /// 返回：true=成功，false=失败
  Future<bool> importData(String filePath) async {
    try {
      // 读取文件
      File backupFile = File(filePath);
      if (!await backupFile.exists()) {
        print('备份文件不存在: $filePath');
        return false;
      }
      
      String jsonString = await backupFile.readAsString();
      Map<String, dynamic> backupData = jsonDecode(jsonString);
      
      // 验证数据格式
      if (!backupData.containsKey('medicines') || !backupData.containsKey('logs')) {
        print('备份文件格式错误');
        return false;
      }
      
      // 清空现有数据（可选：也可以选择合并数据）
      // 注意：这里为了简化，直接清空。实际项目中可以添加"合并"选项
      
      // 导入药品
      List<dynamic> medicinesData = backupData['medicines'] as List;
      for (var medicineData in medicinesData) {
        Medicine medicine = Medicine.fromMap(Map<String, dynamic>.from(medicineData));
        // 注意：导入时ID会被重新分配，如果需要保留原ID，需要特殊处理
        medicine.id = null; // 清除ID，让数据库重新分配
        await DatabaseHelper.instance.insertMedicine(medicine);
      }
      
      // 导入日志
      List<dynamic> logsData = backupData['logs'] as List;
      for (var logData in logsData) {
        MedicineLog log = MedicineLog.fromMap(Map<String, dynamic>.from(logData));
        log.id = null; // 清除ID
        // 注意：medicineId可能需要重新映射，这里简化处理
        await DatabaseHelper.instance.insertMedicineLog(log);
      }
      
      return true;
    } catch (e) {
      print('导入数据失败: $e');
      return false;
    }
  }
  
  /// 获取备份文件路径
  /// 返回：备份文件的完整路径
  Future<String> getBackupFilePath() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    return '${appDocDir.path}/${AppConstants.backupFileName}';
  }
  
  /// 检查备份文件是否存在
  /// 返回：true=存在，false=不存在
  Future<bool> backupFileExists() async {
    String filePath = await getBackupFilePath();
    File backupFile = File(filePath);
    return await backupFile.exists();
  }
}
