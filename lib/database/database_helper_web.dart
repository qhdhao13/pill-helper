// 版权所有 (C) 2025 Pill Helper
// 本代码遵循 AGPL-3.0 开源协议，个人非商用可自由使用、修改；商用需联系作者授权

// Web 平台实现（使用内存存储）

import '../models/medicine.dart';
import '../models/medicine_log.dart';
import 'memory_storage.dart';

/// 数据库操作工具类（Web 平台实现）
/// 注意：Web 平台使用内存存储，刷新页面后数据会丢失
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  DatabaseHelper._internal();
  
  MemoryStorage get _storage => MemoryStorage.instance;
  
  // 为了兼容接口，提供 database getter（Web 平台不需要）
  Future<void> get database async {
    // Web 平台不需要 Database 对象
  }
  
  // 药品操作
  Future<int> insertMedicine(Medicine medicine) async {
    return await _storage.insertMedicine(medicine);
  }
  
  Future<List<Medicine>> getAllMedicines({bool onlyActive = false}) async {
    return await _storage.getAllMedicines(onlyActive: onlyActive);
  }
  
  Future<Medicine?> getMedicineById(int id) async {
    return await _storage.getMedicineById(id);
  }
  
  Future<int> updateMedicine(Medicine medicine) async {
    return await _storage.updateMedicine(medicine);
  }
  
  Future<int> deleteMedicine(int id) async {
    return await _storage.deleteMedicine(id);
  }
  
  // 日志操作
  Future<int> insertMedicineLog(MedicineLog log) async {
    return await _storage.insertMedicineLog(log);
  }
  
  Future<List<MedicineLog>> getAllMedicineLogs({int? limit}) async {
    return await _storage.getAllMedicineLogs(limit: limit);
  }
  
  Future<List<MedicineLog>> getLogsByMedicineId(int medicineId) async {
    return await _storage.getLogsByMedicineId(medicineId);
  }
  
  Future<List<MedicineLog>> getLogsByDate(DateTime date) async {
    return await _storage.getLogsByDate(date);
  }
  
  Future<int> updateMedicineLog(MedicineLog log) async {
    return await _storage.updateMedicineLog(log);
  }
  
  Future<int> deleteMedicineLog(int id) async {
    return await _storage.deleteMedicineLog(id);
  }
  
  Future<List<MedicineLog>> getTodayPendingLogs() async {
    return await _storage.getTodayPendingLogs();
  }
  
  Future<void> close() async {
    await _storage.close();
  }
}
