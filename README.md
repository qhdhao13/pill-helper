# Pill Helper - 吃药提醒助手

## 📱 项目简介

Pill Helper 是一款专为中老年群体设计的跨平台（Android/iOS）吃药提醒APP。采用 Flutter 开发，支持离线运行，界面简洁，操作便捷，字体大，对比度高，让长辈轻松管理日常用药。

## ✨ 核心功能

- ✅ **药品管理**：添加、编辑、删除药品信息（名称、剂量、服用时间、频次、禁忌、主治功能等）
- ✅ **AI智能搜索**：手动输入药品名称或拍照识别，自动搜索并填充药品信息
- ✅ **智能提醒**：基于系统通知的离线提醒，支持多时段、漏服二次提醒（15分钟后）
- ✅ **服药记录**：记录每次服药情况，支持查看历史记录和按日期筛选
- ✅ **剂量限制**：设置每日最大剂量限制，达到限制时明显提醒
- ✅ **设置功能**：服药人信息设置、提醒设置、开发者信息
- ✅ **离线运行**：所有数据本地存储，优先离线运行，无需联网即可使用
- ✅ **大字体适配**：统一大字体（22-28px），响应式适配不同手机屏幕，高对比度配色

## 🛠️ 技术栈

- **框架**：Flutter 3.0+
- **数据库**：SQLite (sqflite) - 支持移动平台和Web平台
- **通知**：flutter_local_notifications - 本地离线提醒
- **AI服务**：火山方舟（Volcengine Ark）- 药品信息搜索和图片识别
- **存储**：本地文件系统 + SharedPreferences（用户设置）
- **网络**：HTTP请求（用于AI搜索）

## 📋 项目结构

```
pill-helper/
├── lib/
│   ├── main.dart                 # 应用入口，初始化全局配置
│   ├── models/                   # 数据模型
│   │   ├── medicine.dart         # 药品信息模型
│   │   ├── medicine_log.dart     # 服药日志模型
│   │   └── user_profile.dart     # 用户信息模型
│   ├── database/                 # 数据库操作
│   │   ├── database_helper.dart  # 数据库接口（跨平台）
│   │   ├── database_helper_impl.dart  # 移动平台实现（SQLite）
│   │   ├── database_helper_web.dart   # Web平台实现（内存存储）
│   │   ├── memory_storage.dart   # 内存存储（Web平台）
│   │   └── backup_helper.dart    # 数据备份与恢复
│   ├── services/                 # 服务层
│   │   ├── notification_service.dart  # 本地通知服务
│   │   ├── ai_service.dart        # AI服务（火山方舟）
│   │   ├── medicine_search_service.dart  # 药品搜索服务
│   │   ├── image_recognition_service.dart  # 图片识别服务
│   │   └── dosage_limit_service.dart  # 剂量限制服务
│   ├── pages/                    # 页面
│   │   ├── home_page.dart        # 首页（显示当日待服药品）
│   │   ├── add_medicine_page.dart    # 添加/编辑药品页面
│   │   ├── medicine_list_page.dart    # 药品列表页面
│   │   ├── medicine_detail_page.dart  # 药品详情页面
│   │   ├── log_page.dart         # 服药日志页面
│   │   ├── settings_page.dart    # 设置页面
│   │   ├── user_profile_page.dart     # 服药人设置页面
│   │   └── reminder_settings_page.dart  # 提醒设置页面
│   ├── widgets/                  # 可复用组件
│   │   ├── medicine_card.dart    # 药品卡片组件
│   │   └── large_text_button.dart    # 大字体按钮组件
│   └── utils/                    # 工具类
│       ├── theme_helper.dart     # 主题配置（大字体、高对比度）
│       ├── constants.dart        # 常量定义
│       └── responsive_font.dart  # 响应式字体工具
├── pubspec.yaml                  # 依赖配置
├── LICENSE                       # AGPL-3.0 开源许可证
└── README.md                     # 项目说明文档
```

## 🚀 快速开始

### 环境要求

- Flutter SDK 3.0 或更高版本
- Android Studio / Xcode（用于真机调试）
- VS Code 或 Android Studio（代码编辑器）

### 安装步骤

#### 1. 安装 Flutter

**Windows 用户：**
1. 访问 [Flutter 官网](https://flutter.dev/docs/get-started/install/windows)
2. 下载 Flutter SDK 压缩包
3. 解压到 `C:\src\flutter`（或其他路径，避免中文路径）
4. 将 Flutter 的 `bin` 目录添加到系统环境变量 PATH
5. 打开命令行，运行 `flutter doctor` 检查环境

**macOS 用户：**
1. 访问 [Flutter 官网](https://flutter.dev/docs/get-started/install/macos)
2. 下载 Flutter SDK 压缩包
3. 解压到 `~/development/flutter`（或其他路径）
4. 将 Flutter 的 `bin` 目录添加到 `~/.zshrc` 或 `~/.bash_profile`：
   ```bash
   export PATH="$PATH:$HOME/development/flutter/bin"
   ```
5. 运行 `source ~/.zshrc` 或 `source ~/.bash_profile`
6. 运行 `flutter doctor` 检查环境

#### 2. 在 Cursor 中打开项目

1. 打开 Cursor 编辑器
2. 选择 `File` -> `Open Folder`
3. 选择 `pill-helper` 文件夹
4. Cursor 会自动识别 Flutter 项目

#### 3. 安装依赖

在 Cursor 的终端中运行：

```bash
flutter pub get
```

#### 4. 运行项目

**在 Android 设备/模拟器上运行：**
```bash
flutter run
```

**在 iOS 设备/模拟器上运行（仅限 macOS）：**
```bash
flutter run
```

**连接真机测试：**

- **Android**：
  1. 开启手机的 USB 调试模式
  2. 用 USB 连接电脑
  3. 运行 `flutter devices` 查看已连接设备
  4. 运行 `flutter run` 选择设备

- **iOS**（仅限 macOS）：
  1. 用 USB 连接 iPhone
  2. 在手机上信任此电脑
  3. 运行 `flutter devices` 查看已连接设备
  4. 运行 `flutter run` 选择设备

## 📦 打包发布

### Android APK 打包

1. 生成签名密钥（首次打包）：
```bash
keytool -genkey -v -keystore ~/pill-helper-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias pill-helper
```

2. 在 `android/app/build.gradle` 中配置签名（参考 Flutter 官方文档）

3. 打包 APK：
```bash
flutter build apk --release
```

生成的 APK 文件位于：`build/app/outputs/flutter-apk/app-release.apk`

### iOS IPA 打包（仅限 macOS）

1. 在 Xcode 中打开 `ios/Runner.xcworkspace`
2. 配置签名和证书
3. 选择 `Product` -> `Archive`
4. 按照向导完成打包

## 📄 知识产权声明

### 开源协议

本项目采用 **AGPL-3.0** 开源许可证。

### 使用条款

1. **个人非商业用途**：个人用户可以自由使用、修改、分发本项目的源代码和编译后的应用。

2. **商业用途限制**：
   - 任何企业、组织或个人将本项目用于商业行为（包括但不限于：售卖、嵌入商业APP、提供盈利性服务、作为商业产品的一部分），**必须提前联系项目作者获得书面授权**。
   - 未经授权的商业使用视为侵权，作者保留追究法律责任的权利。

3. **修改与分发**：
   - 基于本项目修改的代码，如果对外分发，必须同样遵循 AGPL-3.0 协议。
   - 必须保留原始版权声明和许可证文件。

4. **免责声明**：
   - 本项目仅供学习和个人使用，作者不对因使用本项目而产生的任何医疗事故、数据丢失或其他损失承担责任。
   - 用户应自行承担使用风险。

### 联系方式

如需商业授权或有其他问题，请通过以下方式联系：
- **微信号**：qhdhao
- **手机号**：18903351102
- GitHub Issues
- 项目仓库 Discussions

**重要提示**：本应用仅对个人使用免费，商业用途需要联系开发者授权。

## 🤝 贡献指南

欢迎提交 Issue 和 Pull Request！

## 📝 更新日志

### v1.0.0 (2025-01-23)
- ✅ 基础药品管理功能（添加、编辑、删除）
- ✅ AI智能搜索（手动输入和拍照识别）
- ✅ 本地提醒服务（多时段、漏服二次提醒）
- ✅ 服药日志记录（查看历史、按日期筛选）
- ✅ 剂量限制提醒功能
- ✅ 设置功能（服药人信息、提醒设置、开发者信息）
- ✅ 通知权限诊断和测试功能
- ✅ 统一大字体界面（22-28px，响应式适配）
- ✅ 离线运行支持（优先本地存储）
- ✅ 跨平台支持（Android/iOS/Web）

## 🔮 未来计划

- [ ] 升级功能（待开发）
- [ ] 数据云端同步（可选）
- [ ] 多语言支持
- [ ] 语音提醒
- [ ] 用药统计分析
- [ ] 药品相互作用检查

## ⚠️ 注意事项

1. **通知权限**：
   - 应用首次启动时会请求通知权限，请务必允许
   - 如果提醒不响，请进入"设置" → "定时吃药提醒设置"检查权限状态
   - 可以点击"测试通知"按钮验证通知功能是否正常
   - 如果权限被拒绝，需要在手机系统设置中手动开启

2. **AI搜索功能**：
   - 需要网络连接才能使用AI搜索和图片识别功能
   - 首次使用需要配置火山方舟API密钥（已在代码中配置默认值）
   - 如果搜索失败，可以手动输入药品信息

3. **数据备份**：
   - 所有数据存储在本地，建议定期备份
   - 卸载应用会清除所有数据，请谨慎操作

4. **医疗建议**：
   - 本应用仅为提醒工具，不能替代医生建议
   - 如有用药疑问，请咨询专业医生
   - 药品信息仅供参考，请以实际药品说明书为准

## 📞 技术支持

如遇到问题，请：
1. 查看本文档的常见问题部分
2. 在 GitHub Issues 中搜索相关问题
3. 提交新的 Issue 描述问题

---

**版权所有 (C) 2025 Pill Helper**  
**遵循 AGPL-3.0 开源协议**
