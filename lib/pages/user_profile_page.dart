// 版权所有 (C) 2025 Pill Helper
// 本代码遵循 AGPL-3.0 开源协议，个人非商用可自由使用、修改；商用需联系作者授权

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

/// 服药人设置页面
/// 功能：设置服药人的姓名、年龄、性别
/// 使用方法：从设置页面进入
class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});
  
  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  String? _selectedGender;
  
  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }
  
  /// 加载用户信息
  Future<void> _loadUserProfile() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? name = prefs.getString('user_name');
      int? age = prefs.getInt('user_age');
      String? gender = prefs.getString('user_gender');
      
      setState(() {
        _nameController.text = name ?? '';
        _ageController.text = age != null ? age.toString() : '';
        _selectedGender = gender;
      });
    } catch (e) {
      print('加载用户信息失败: $e');
    }
  }
  
  /// 保存用户信息
  Future<void> _saveUserProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', _nameController.text.trim());
      
      if (_ageController.text.trim().isNotEmpty) {
        int age = int.parse(_ageController.text.trim());
        await prefs.setInt('user_age', age);
      } else {
        await prefs.remove('user_age');
      }
      
      if (_selectedGender != null && _selectedGender!.isNotEmpty) {
        await prefs.setString('user_gender', _selectedGender!);
      } else {
        await prefs.remove('user_gender');
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('保存成功'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      print('保存用户信息失败: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('保存失败，请重试'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('服药人设置'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 姓名
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '姓名 *',
                  hintText: '请输入姓名',
                  prefixIcon: Icon(Icons.person),
                ),
                style: const TextStyle(fontSize: AppConstants.largeFontSize),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '请输入姓名';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // 年龄
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(
                  labelText: '年龄（可选）',
                  hintText: '请输入年龄',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                style: const TextStyle(fontSize: AppConstants.largeFontSize),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    int? age = int.tryParse(value.trim());
                    if (age == null || age < 0 || age > 150) {
                      return '请输入有效的年龄（0-150）';
                    }
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // 性别
              const Text(
                '性别（可选）',
                style: TextStyle(
                  fontSize: AppConstants.largeFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('男'),
                      value: '男',
                      groupValue: _selectedGender,
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('女'),
                      value: '女',
                      groupValue: _selectedGender,
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('其他'),
                      value: '其他',
                      groupValue: _selectedGender,
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // 保存按钮
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveUserProfile,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(AppConstants.primaryColorValue),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    '保存',
                    style: TextStyle(
                      fontSize: AppConstants.largeFontSize + 2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
