// 版权所有 (C) 2025 Pill Helper
// 本代码遵循 AGPL-3.0 开源协议，个人非商用可自由使用、修改；商用需联系作者授权

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../utils/constants.dart';
import 'user_profile_page.dart';
import 'reminder_settings_page.dart';

/// 设置页面
/// 功能：提供应用设置选项，包括服药人设置、提醒设置、开发者信息等
/// 使用方法：从首页右上角设置按钮进入
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // 用户信息
  UserProfile? userProfile;
  
  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }
  
  /// 加载用户信息
  Future<void> _loadUserProfile() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? name = prefs.getString('user_name');
      int? age = prefs.getInt('user_age');
      String? gender = prefs.getString('user_gender');
      
      if (name != null) {
        setState(() {
          userProfile = UserProfile(
            name: name,
            age: age,
            gender: gender,
          );
        });
      }
    } catch (e) {
      print('加载用户信息失败: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 服药人设置
          _buildSectionTitle('服药人设置'),
          Card(
            child: ListTile(
              leading: const Icon(Icons.person, size: 28),
              title: const Text(
                '服药人信息',
                style: TextStyle(fontSize: AppConstants.largeFontSize),
              ),
              subtitle: Text(
                userProfile != null
                    ? '${userProfile!.name}${userProfile!.age != null ? '，${userProfile!.age}岁' : ''}${userProfile!.gender != null ? '，${userProfile!.gender}' : ''}'
                    : '未设置',
                style: const TextStyle(fontSize: AppConstants.normalFontSize),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UserProfilePage(),
                  ),
                ).then((_) => _loadUserProfile());
              },
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 提醒设置
          _buildSectionTitle('提醒设置'),
          Card(
            child: ListTile(
              leading: const Icon(Icons.alarm, size: 28),
              title: const Text(
                '定时吃药提醒',
                style: TextStyle(fontSize: AppConstants.largeFontSize),
              ),
              subtitle: const Text(
                '设置手机闹钟提醒',
                style: TextStyle(fontSize: AppConstants.normalFontSize),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ReminderSettingsPage(),
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 升级功能
          _buildSectionTitle('功能'),
          Card(
            child: ListTile(
              leading: const Icon(Icons.upgrade, size: 28),
              title: const Text(
                '升级功能',
                style: TextStyle(fontSize: AppConstants.largeFontSize),
              ),
              subtitle: const Text(
                '待开发',
                style: TextStyle(
                  fontSize: AppConstants.normalFontSize,
                  color: Color(AppConstants.secondaryTextColorValue),
                ),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('升级功能正在开发中，敬请期待'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 开发者信息
          _buildSectionTitle('关于'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.code, size: 28),
                  title: const Text(
                    '开发者信息',
                    style: TextStyle(fontSize: AppConstants.largeFontSize),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _InfoRow(
                        icon: Icons.wechat,
                        label: '微信号',
                        value: 'qhdhao',
                      ),
                      SizedBox(height: 12),
                      _InfoRow(
                        icon: Icons.phone,
                        label: '手机号',
                        value: '18903351102',
                      ),
                      SizedBox(height: 16),
                      Padding(
                        padding: EdgeInsets.only(left: 40),
                        child: Text(
                          '本应用仅对个人使用免费，商业用途需要联系开发者授权。',
                          style: TextStyle(
                            fontSize: AppConstants.smallFontSize,
                            color: Color(AppConstants.secondaryTextColorValue),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  /// 构建章节标题
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: AppConstants.largeFontSize,
          fontWeight: FontWeight.bold,
          color: Color(AppConstants.primaryColorValue),
        ),
      ),
    );
  }
}

/// 信息行组件
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });
  
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: const Color(AppConstants.primaryColorValue),
        ),
        const SizedBox(width: 12),
        Text(
          '$label：',
          style: const TextStyle(
            fontSize: AppConstants.normalFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: AppConstants.normalFontSize,
          ),
        ),
      ],
    );
  }
}
