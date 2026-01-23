// 版权所有 (C) 2025 Pill Helper
// 本代码遵循 AGPL-3.0 开源协议，个人非商用可自由使用、修改；商用需联系作者授权

/// 常量定义文件
/// 用于存储应用中使用的固定值，如字体大小、颜色、时间间隔等
library;


class AppConstants {
  // 字体大小配置 - 针对中老年用户优化（已放大，并支持响应式适配）
  static const double largeFontSize = 22.0; // 大字体大小（默认，已放大）
  static const double normalFontSize = 18.0; // 普通字体大小（已放大）
  static const double smallFontSize = 16.0; // 小字体大小（次要信息，已放大）
  static const double extraLargeFontSize = 28.0; // 超大字体（重要标题，已放大）
  
  // 高对比度颜色配置 - 确保文字清晰可见
  static const int primaryColorValue = 0xFF2196F3; // 主色调：蓝色
  static const int accentColorValue = 0xFFFF5722; // 强调色：橙红色（用于重要提醒）
  static const int backgroundColorValue = 0xFFFFFFFF; // 背景色：白色
  static const int textColorValue = 0xFF000000; // 文字色：黑色
  static const int secondaryTextColorValue = 0xFF666666; // 次要文字色：灰色
  
  // 提醒相关常量
  static const int reminderDelayMinutes = 15; // 漏服提醒延迟时间（分钟）
  static const int maxReminderTimes = 5; // 单个药品最多提醒次数
  
  // 数据库相关常量
  static const String databaseName = 'pill_helper.db'; // 数据库文件名
  static const int databaseVersion = 2; // 数据库版本号（升级：添加indications和maxDailyDosage字段）
  
  // 表名常量
  static const String tableMedicines = 'medicines'; // 药品表名
  static const String tableMedicineLogs = 'medicine_logs'; // 服药日志表名
  
  // 备份文件相关
  static const String backupFileName = 'pill_helper_backup.json'; // 备份文件名
}
