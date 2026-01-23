// 版权所有 (C) 2025 Pill Helper
// 本代码遵循 AGPL-3.0 开源协议，个人非商用可自由使用、修改；商用需联系作者授权

import 'dart:convert';

/// 药品信息数据模型
/// 功能：定义药品的所有属性，包括名称、剂量、服用时间等
/// 使用方法：创建 Medicine 对象存储药品信息，然后保存到数据库
class Medicine {
  // 药品ID（主键，自增）
  int? id;
  
  // 药品名称（必填）
  String name;
  
  // 药品剂量（例如：1片、2粒、5ml等）
  String dosage;
  
  // 服用频次（例如：每天1次、每天2次、每8小时1次等）
  String frequency;
  
  // 服用时间列表（JSON格式存储，例如：["08:00", "12:00", "20:00"]）
  // 说明：使用JSON格式可以存储多个时间点
  String times;
  
  // 药品说明（可选，例如：饭前服用、饭后服用等）
  String? instructions;
  
  // 禁忌说明（可选，例如：孕妇禁用、不能与XX同服等）
  String? contraindications;
  
  // 主治功能（可选）
  String? indications;
  
  // 每日最大剂量限制（可选，例如：最多3次、最多6片等）
  String? maxDailyDosage;
  
  // 是否启用提醒（true=启用，false=禁用）
  bool isActive;
  
  // 创建时间
  DateTime createdAt;
  
  // 更新时间
  DateTime updatedAt;
  
  /// 构造函数
  /// 参数说明：
  /// - id: 药品ID（新建时为null，数据库会自动分配）
  /// - name: 药品名称（必填）
  /// - dosage: 剂量（必填）
  /// - frequency: 频次（必填）
  /// - times: 时间列表的JSON字符串（必填）
  /// - instructions: 说明（可选）
  /// - contraindications: 禁忌（可选）
  /// - indications: 主治功能（可选）
  /// - maxDailyDosage: 每日最大剂量限制（可选）
  /// - isActive: 是否启用（默认true）
  /// - createdAt: 创建时间（默认当前时间）
  /// - updatedAt: 更新时间（默认当前时间）
  Medicine({
    this.id,
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.times,
    this.instructions,
    this.contraindications,
    this.indications,
    this.maxDailyDosage,
    this.isActive = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();
  
  /// 将对象转换为Map（用于保存到数据库）
  /// 返回：包含所有字段的Map对象
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'times': times,
      'instructions': instructions ?? '',
      'contraindications': contraindications ?? '',
      'indications': indications ?? '',
      'maxDailyDosage': maxDailyDosage ?? '',
      'isActive': isActive ? 1 : 0, // SQLite中布尔值用0/1表示
      'createdAt': createdAt.toIso8601String(), // 日期转换为字符串
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
  
  /// 从Map创建对象（用于从数据库读取）
  /// 参数：包含药品信息的Map对象
  /// 返回：Medicine对象
  factory Medicine.fromMap(Map<String, dynamic> map) {
    return Medicine(
      id: map['id'] as int?,
      name: map['name'] as String,
      dosage: map['dosage'] as String,
      frequency: map['frequency'] as String,
      times: map['times'] as String,
      instructions: map['instructions'] as String?,
      contraindications: map['contraindications'] as String?,
      indications: map['indications'] as String?,
      maxDailyDosage: map['maxDailyDosage'] as String?,
      isActive: (map['isActive'] as int) == 1, // 将0/1转换回布尔值
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }
  
  /// 复制对象并修改部分属性（用于更新药品信息）
  /// 参数：要修改的属性（可选）
  /// 返回：新的Medicine对象
  Medicine copyWith({
    int? id,
    String? name,
    String? dosage,
    String? frequency,
    String? times,
    String? instructions,
    String? contraindications,
    String? indications,
    String? maxDailyDosage,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Medicine(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      times: times ?? this.times,
      instructions: instructions ?? this.instructions,
      contraindications: contraindications ?? this.contraindications,
      indications: indications ?? this.indications,
      maxDailyDosage: maxDailyDosage ?? this.maxDailyDosage,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  /// 获取时间列表（将JSON字符串解析为List）
  /// 返回：时间字符串列表，例如：["08:00", "12:00", "20:00"]
  List<String> getTimeList() {
    try {
      if (times.isEmpty) return [];
      // 使用dart:convert的jsonDecode进行JSON解析
      List<dynamic> decoded = jsonDecode(times);
      return decoded.map((e) => e.toString()).toList();
    } catch (e) {
      // 如果解析失败，返回空列表
      print('解析时间列表失败: $e');
      return [];
    }
  }
  
  /// 设置时间列表（将List转换为JSON字符串）
  /// 参数：时间字符串列表
  void setTimeList(List<String> timeList) {
    // 使用dart:convert的jsonEncode进行JSON序列化
    times = jsonEncode(timeList);
  }
  
  @override
  String toString() {
    return 'Medicine{id: $id, name: $name, dosage: $dosage, frequency: $frequency, times: $times}';
  }
}
