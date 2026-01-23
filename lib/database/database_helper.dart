// 版权所有 (C) 2025 Pill Helper
// 本代码遵循 AGPL-3.0 开源协议，个人非商用可自由使用、修改；商用需联系作者授权

/// 数据库操作工具类
/// 功能：根据平台自动选择实现（移动平台使用SQLite，Web平台使用内存存储）
/// 使用方法：通过 DatabaseHelper.instance 获取单例，然后调用相应方法
library;


import '../models/medicine.dart';
import '../models/medicine_log.dart';

// 根据平台选择不同的实现
export 'database_helper_impl.dart' if (dart.library.html) 'database_helper_web.dart';
