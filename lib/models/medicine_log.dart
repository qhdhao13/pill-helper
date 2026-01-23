// 版权所有 (C) 2025 Pill Helper
// 本代码遵循 AGPL-3.0 开源协议，个人非商用可自由使用、修改；商用需联系作者授权

/// 服药日志数据模型
/// 功能：记录每次服药的情况，包括是否按时服用、服用时间等
/// 使用方法：每次服药后创建 MedicineLog 对象并保存到数据库
class MedicineLog {
  // 日志ID（主键，自增）
  int? id;
  
  // 关联的药品ID（外键）
  int medicineId;
  
  // 药品名称（冗余存储，方便查询，即使药品被删除也能看到历史记录）
  String medicineName;
  
  // 计划服用时间（应该服药的时间）
  DateTime scheduledTime;
  
  // 实际服用时间（用户实际服药的时间，如果未服用则为null）
  DateTime? takenTime;
  
  // 是否已服用（true=已服用，false=未服用）
  bool isTaken;
  
  // 是否按时服用（true=按时，false=漏服或延迟）
  bool isOnTime;
  
  // 备注（可选，用户可以添加备注）
  String? note;
  
  // 创建时间
  DateTime createdAt;
  
  /// 构造函数
  /// 参数说明：
  /// - id: 日志ID（新建时为null）
  /// - medicineId: 药品ID（必填）
  /// - medicineName: 药品名称（必填）
  /// - scheduledTime: 计划服用时间（必填）
  /// - takenTime: 实际服用时间（可选，未服用时为null）
  /// - isTaken: 是否已服用（默认false）
  /// - isOnTime: 是否按时（默认false）
  /// - note: 备注（可选）
  /// - createdAt: 创建时间（默认当前时间）
  MedicineLog({
    this.id,
    required this.medicineId,
    required this.medicineName,
    required this.scheduledTime,
    this.takenTime,
    this.isTaken = false,
    this.isOnTime = false,
    this.note,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
  
  /// 将对象转换为Map（用于保存到数据库）
  /// 返回：包含所有字段的Map对象
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'medicineId': medicineId,
      'medicineName': medicineName,
      'scheduledTime': scheduledTime.toIso8601String(),
      'takenTime': takenTime?.toIso8601String(), // 可能为null
      'isTaken': isTaken ? 1 : 0,
      'isOnTime': isOnTime ? 1 : 0,
      'note': note ?? '',
      'createdAt': createdAt.toIso8601String(),
    };
  }
  
  /// 从Map创建对象（用于从数据库读取）
  /// 参数：包含日志信息的Map对象
  /// 返回：MedicineLog对象
  factory MedicineLog.fromMap(Map<String, dynamic> map) {
    return MedicineLog(
      id: map['id'] as int?,
      medicineId: map['medicineId'] as int,
      medicineName: map['medicineName'] as String,
      scheduledTime: DateTime.parse(map['scheduledTime'] as String),
      takenTime: map['takenTime'] != null 
          ? DateTime.parse(map['takenTime'] as String) 
          : null,
      isTaken: (map['isTaken'] as int) == 1,
      isOnTime: (map['isOnTime'] as int) == 1,
      note: map['note'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
  
  /// 复制对象并修改部分属性
  /// 参数：要修改的属性（可选）
  /// 返回：新的MedicineLog对象
  MedicineLog copyWith({
    int? id,
    int? medicineId,
    String? medicineName,
    DateTime? scheduledTime,
    DateTime? takenTime,
    bool? isTaken,
    bool? isOnTime,
    String? note,
    DateTime? createdAt,
  }) {
    return MedicineLog(
      id: id ?? this.id,
      medicineId: medicineId ?? this.medicineId,
      medicineName: medicineName ?? this.medicineName,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      takenTime: takenTime ?? this.takenTime,
      isTaken: isTaken ?? this.isTaken,
      isOnTime: isOnTime ?? this.isOnTime,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }
  
  @override
  String toString() {
    return 'MedicineLog{id: $id, medicineName: $medicineName, scheduledTime: $scheduledTime, isTaken: $isTaken}';
  }
}
