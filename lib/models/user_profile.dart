// 版权所有 (C) 2025 Pill Helper
// 本代码遵循 AGPL-3.0 开源协议，个人非商用可自由使用、修改；商用需联系作者授权

/// 用户个人信息数据模型
/// 功能：存储服药人的基本信息（姓名、年龄、性别）
/// 使用方法：创建 UserProfile 对象存储用户信息，然后保存到数据库或本地存储
class UserProfile {
  // 用户ID（主键，自增）
  int? id;
  
  // 姓名
  String name;
  
  // 年龄
  int? age;
  
  // 性别（'男'、'女'、'其他'）
  String? gender;
  
  // 创建时间
  DateTime createdAt;
  
  // 更新时间
  DateTime updatedAt;
  
  /// 构造函数
  UserProfile({
    this.id,
    required this.name,
    this.age,
    this.gender,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();
  
  /// 将对象转换为Map（用于保存到数据库）
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'gender': gender ?? '',
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
  
  /// 从Map创建对象（用于从数据库读取）
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as int?,
      name: map['name'] as String,
      age: map['age'] as int?,
      gender: map['gender'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }
  
  /// 复制对象并修改部分属性
  UserProfile copyWith({
    int? id,
    String? name,
    int? age,
    String? gender,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
