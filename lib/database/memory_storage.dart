// 版权所有 (C) 2025 Pill Helper
// 本代码遵循 AGPL-3.0 开源协议，个人非商用可自由使用、修改；商用需联系作者授权

/// Web 平台内存存储（临时方案）
/// 功能：在 Web 平台使用内存存储，数据在刷新页面后会丢失
/// 注意：这是临时方案，建议在移动设备上使用以获得完整功能
library;


import '../models/medicine.dart';
import '../models/medicine_log.dart';

class MemoryStorage {
  static final MemoryStorage instance = MemoryStorage._internal();
  MemoryStorage._internal();
  
  // 内存中的数据
  final List<Medicine> _medicines = [];
  final List<MedicineLog> _logs = [];
  int _medicineIdCounter = 1;
  int _logIdCounter = 1;
  
  // 药品操作
  Future<int> insertMedicine(Medicine medicine) async {
    medicine.id = _medicineIdCounter++;
    _medicines.add(medicine);
    return medicine.id!;
  }
  
  Future<List<Medicine>> getAllMedicines({bool onlyActive = false}) async {
    if (onlyActive) {
      return _medicines.where((m) => m.isActive).toList();
    }
    return List.from(_medicines);
  }
  
  Future<Medicine?> getMedicineById(int id) async {
    try {
      return _medicines.firstWhere((m) => m.id == id);
    } catch (e) {
      return null;
    }
  }
  
  Future<int> updateMedicine(Medicine medicine) async {
    int index = _medicines.indexWhere((m) => m.id == medicine.id);
    if (index >= 0) {
      _medicines[index] = medicine;
      return 1;
    }
    return 0;
  }
  
  Future<int> deleteMedicine(int id) async {
    int index = _medicines.indexWhere((m) => m.id == id);
    if (index >= 0) {
      _medicines.removeAt(index);
      // 删除相关日志
      _logs.removeWhere((log) => log.medicineId == id);
      return 1;
    }
    return 0;
  }
  
  // 日志操作
  Future<int> insertMedicineLog(MedicineLog log) async {
    log.id = _logIdCounter++;
    _logs.add(log);
    return log.id!;
  }
  
  Future<List<MedicineLog>> getAllMedicineLogs({int? limit}) async {
    var result = List<MedicineLog>.from(_logs);
    result.sort((a, b) => b.scheduledTime.compareTo(a.scheduledTime));
    if (limit != null) {
      return result.take(limit).toList();
    }
    return result;
  }
  
  Future<List<MedicineLog>> getLogsByMedicineId(int medicineId) async {
    return _logs.where((log) => log.medicineId == medicineId).toList();
  }
  
  Future<List<MedicineLog>> getLogsByDate(DateTime date) async {
    DateTime startDate = DateTime(date.year, date.month, date.day);
    DateTime endDate = DateTime(date.year, date.month, date.day, 23, 59, 59);
    return _logs.where((log) => 
      log.scheduledTime.isAfter(startDate.subtract(const Duration(seconds: 1))) &&
      log.scheduledTime.isBefore(endDate.add(const Duration(seconds: 1)))
    ).toList();
  }
  
  Future<int> updateMedicineLog(MedicineLog log) async {
    int index = _logs.indexWhere((l) => l.id == log.id);
    if (index >= 0) {
      _logs[index] = log;
      return 1;
    }
    return 0;
  }
  
  Future<int> deleteMedicineLog(int id) async {
    int index = _logs.indexWhere((l) => l.id == id);
    if (index >= 0) {
      _logs.removeAt(index);
      return 1;
    }
    return 0;
  }
  
  Future<List<MedicineLog>> getTodayPendingLogs() async {
    DateTime today = DateTime.now();
    DateTime startDate = DateTime(today.year, today.month, today.day);
    DateTime endDate = DateTime(today.year, today.month, today.day, 23, 59, 59);
    return _logs.where((log) => 
      log.scheduledTime.isAfter(startDate.subtract(const Duration(seconds: 1))) &&
      log.scheduledTime.isBefore(endDate.add(const Duration(seconds: 1))) &&
      !log.isTaken
    ).toList();
  }
  
  Future<void> close() async {
    // 内存存储无需关闭
  }
}
