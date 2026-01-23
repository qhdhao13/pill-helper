// 版权所有 (C) 2025 Pill Helper
// 本代码遵循 AGPL-3.0 开源协议，个人非商用可自由使用、修改；商用需联系作者授权

// 移动平台实现（使用 SQLite）

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/medicine.dart';
import '../models/medicine_log.dart';
import '../utils/constants.dart';

/// 数据库操作工具类（移动平台实现）
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  DatabaseHelper._internal();
  
  static Database? _database;
  
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  
  Future<Database> _initDatabase() async {
    String dbPath = await getDatabasesPath();
    String path = join(dbPath, AppConstants.databaseName);
    
    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }
  
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${AppConstants.tableMedicines} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        dosage TEXT NOT NULL,
        frequency TEXT NOT NULL,
        times TEXT NOT NULL,
        instructions TEXT,
        contraindications TEXT,
        indications TEXT,
        maxDailyDosage TEXT,
        isActive INTEGER NOT NULL DEFAULT 1,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');
    
    await db.execute('''
      CREATE TABLE ${AppConstants.tableMedicineLogs} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        medicineId INTEGER NOT NULL,
        medicineName TEXT NOT NULL,
        scheduledTime TEXT NOT NULL,
        takenTime TEXT,
        isTaken INTEGER NOT NULL DEFAULT 0,
        isOnTime INTEGER NOT NULL DEFAULT 0,
        note TEXT,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (medicineId) REFERENCES ${AppConstants.tableMedicines}(id) ON DELETE CASCADE
      )
    ''');
    
    await db.execute('''
      CREATE INDEX idx_medicine_active ON ${AppConstants.tableMedicines}(isActive)
    ''');
    await db.execute('''
      CREATE INDEX idx_log_medicine_id ON ${AppConstants.tableMedicineLogs}(medicineId)
    ''');
    await db.execute('''
      CREATE INDEX idx_log_scheduled_time ON ${AppConstants.tableMedicineLogs}(scheduledTime)
    ''');
  }
  
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // 升级逻辑：从版本1升级到版本2，添加indications和maxDailyDosage字段
    if (oldVersion < 2) {
      try {
        // 添加indications字段（主治功能）
        await db.execute('''
          ALTER TABLE ${AppConstants.tableMedicines}
          ADD COLUMN indications TEXT
        ''');
        
        // 添加maxDailyDosage字段（每日最大剂量限制）
        await db.execute('''
          ALTER TABLE ${AppConstants.tableMedicines}
          ADD COLUMN maxDailyDosage TEXT
        ''');
        
        print('数据库升级成功：已添加indications和maxDailyDosage字段');
      } catch (e) {
        // 如果字段已存在，忽略错误
        print('数据库升级警告：$e');
      }
    }
  }
  
  // 药品操作
  Future<int> insertMedicine(Medicine medicine) async {
    final db = await database;
    return await db.insert(
      AppConstants.tableMedicines,
      medicine.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  Future<List<Medicine>> getAllMedicines({bool onlyActive = false}) async {
    final db = await database;
    List<Map<String, dynamic>> maps;
    
    if (onlyActive) {
      maps = await db.query(
        AppConstants.tableMedicines,
        where: 'isActive = ?',
        whereArgs: [1],
        orderBy: 'name ASC',
      );
    } else {
      maps = await db.query(
        AppConstants.tableMedicines,
        orderBy: 'name ASC',
      );
    }
    
    return List.generate(maps.length, (i) => Medicine.fromMap(maps[i]));
  }
  
  Future<Medicine?> getMedicineById(int id) async {
    final db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableMedicines,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    
    if (maps.isEmpty) return null;
    return Medicine.fromMap(maps.first);
  }
  
  Future<int> updateMedicine(Medicine medicine) async {
    final db = await database;
    medicine.updatedAt = DateTime.now();
    return await db.update(
      AppConstants.tableMedicines,
      medicine.toMap(),
      where: 'id = ?',
      whereArgs: [medicine.id],
    );
  }
  
  Future<int> deleteMedicine(int id) async {
    final db = await database;
    return await db.delete(
      AppConstants.tableMedicines,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  // 日志操作
  Future<int> insertMedicineLog(MedicineLog log) async {
    final db = await database;
    return await db.insert(
      AppConstants.tableMedicineLogs,
      log.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  Future<List<MedicineLog>> getAllMedicineLogs({int? limit}) async {
    final db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableMedicineLogs,
      orderBy: 'scheduledTime DESC',
      limit: limit,
    );
    
    return List.generate(maps.length, (i) => MedicineLog.fromMap(maps[i]));
  }
  
  Future<List<MedicineLog>> getLogsByMedicineId(int medicineId) async {
    final db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableMedicineLogs,
      where: 'medicineId = ?',
      whereArgs: [medicineId],
      orderBy: 'scheduledTime DESC',
    );
    
    return List.generate(maps.length, (i) => MedicineLog.fromMap(maps[i]));
  }
  
  Future<List<MedicineLog>> getLogsByDate(DateTime date) async {
    final db = await database;
    String startDate = DateTime(date.year, date.month, date.day).toIso8601String();
    String endDate = DateTime(date.year, date.month, date.day, 23, 59, 59).toIso8601String();
    
    List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableMedicineLogs,
      where: 'scheduledTime >= ? AND scheduledTime <= ?',
      whereArgs: [startDate, endDate],
      orderBy: 'scheduledTime ASC',
    );
    
    return List.generate(maps.length, (i) => MedicineLog.fromMap(maps[i]));
  }
  
  Future<int> updateMedicineLog(MedicineLog log) async {
    final db = await database;
    return await db.update(
      AppConstants.tableMedicineLogs,
      log.toMap(),
      where: 'id = ?',
      whereArgs: [log.id],
    );
  }
  
  Future<int> deleteMedicineLog(int id) async {
    final db = await database;
    return await db.delete(
      AppConstants.tableMedicineLogs,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  Future<List<MedicineLog>> getTodayPendingLogs() async {
    final db = await database;
    DateTime today = DateTime.now();
    String startDate = DateTime(today.year, today.month, today.day).toIso8601String();
    String endDate = DateTime(today.year, today.month, today.day, 23, 59, 59).toIso8601String();
    
    List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableMedicineLogs,
      where: 'scheduledTime >= ? AND scheduledTime <= ? AND isTaken = ?',
      whereArgs: [startDate, endDate, 0],
      orderBy: 'scheduledTime ASC',
    );
    
    return List.generate(maps.length, (i) => MedicineLog.fromMap(maps[i]));
  }
  
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
