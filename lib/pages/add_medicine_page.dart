// 版权所有 (C) 2025 Pill Helper
// 本代码遵循 AGPL-3.0 开源协议，个人非商用可自由使用、修改；商用需联系作者授权

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/medicine.dart';
import '../database/database_helper.dart';
import '../services/notification_service.dart';
import '../services/medicine_search_service.dart';
import '../services/image_recognition_service.dart';
import '../utils/constants.dart';

/// 添加药品页面
/// 功能：提供表单让用户输入药品信息并保存
/// 使用方法：从首页或其他页面导航到此页面
class AddMedicinePage extends StatefulWidget {
  // 可选：编辑模式时传入药品对象
  final Medicine? medicine;
  
  const AddMedicinePage({super.key, this.medicine});
  
  @override
  State<AddMedicinePage> createState() => _AddMedicinePageState();
}

class _AddMedicinePageState extends State<AddMedicinePage> {
  // 表单控制器
  final _formKey = GlobalKey<FormState>();
  
  // 药品名称输入框控制器
  final _nameController = TextEditingController();
  
  // 剂量输入框控制器
  final _dosageController = TextEditingController();
  
  // 频次输入框控制器
  final _frequencyController = TextEditingController();
  
  // 说明输入框控制器
  final _instructionsController = TextEditingController();
  
  // 禁忌输入框控制器
  final _contraindicationsController = TextEditingController();
  
  // 主治功能输入框控制器
  final _indicationsController = TextEditingController();
  
  // 最大剂量限制输入框控制器
  final _maxDailyDosageController = TextEditingController();
  
  // 选中的时间列表
  List<String> selectedTimes = [];
  
  // 是否启用提醒
  bool isActive = true;
  
  // 是否正在搜索
  bool isSearching = false;
  
  // 是否正在识别图片
  bool isRecognizing = false;
  
  @override
  void initState() {
    super.initState();
    // 如果是编辑模式，填充现有数据
    if (widget.medicine != null) {
      Medicine medicine = widget.medicine!;
      _nameController.text = medicine.name;
      _dosageController.text = medicine.dosage;
      _frequencyController.text = medicine.frequency;
      _instructionsController.text = medicine.instructions ?? '';
      _contraindicationsController.text = medicine.contraindications ?? '';
      _indicationsController.text = medicine.indications ?? '';
      _maxDailyDosageController.text = medicine.maxDailyDosage ?? '';
      selectedTimes = medicine.getTimeList();
      isActive = medicine.isActive;
    }
  }
  
  @override
  void dispose() {
    // 释放控制器资源
    _nameController.dispose();
    _dosageController.dispose();
    _frequencyController.dispose();
    _instructionsController.dispose();
    _contraindicationsController.dispose();
    _indicationsController.dispose();
    _maxDailyDosageController.dispose();
    super.dispose();
  }
  
  /// 添加时间
  /// 功能：弹出时间选择器，让用户选择服用时间
  Future<void> _addTime() async {
    // 显示时间选择器
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      // 格式化时间为 HH:mm
      String timeStr = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      
      // 检查是否已存在
      if (!selectedTimes.contains(timeStr)) {
        setState(() {
          selectedTimes.add(timeStr);
          selectedTimes.sort(); // 按时间排序
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('该时间已添加')),
        );
      }
    }
  }
  
  /// 删除时间
  /// 参数：要删除的时间字符串
  void _removeTime(String time) {
    setState(() {
      selectedTimes.remove(time);
    });
  }
  
  /// 搜索药品信息
  /// 功能：根据药品名称搜索说明书信息并自动填充
  Future<void> _searchMedicine() async {
    String medicineName = _nameController.text.trim();
    if (medicineName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先输入药品名称')),
      );
      return;
    }
    
    setState(() {
      isSearching = true;
    });
    
    try {
      // 搜索药品信息
      Map<String, dynamic>? result = await MedicineSearchService.instance.searchMedicine(medicineName);
      
      if (result != null && mounted) {
        // 自动填充表单
        setState(() {
          _dosageController.text = result['dosage'] ?? _dosageController.text;
          _frequencyController.text = result['frequency'] ?? _frequencyController.text;
          _instructionsController.text = result['instructions'] ?? _instructionsController.text;
          _contraindicationsController.text = result['contraindications'] ?? _contraindicationsController.text;
          _indicationsController.text = result['indications'] ?? _indicationsController.text;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('搜索成功，已自动填充信息'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        // 显示更详细的错误信息
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('未找到该药品信息\n请检查：1.网络连接 2.或手动填写'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      print('搜索失败: $e');
      if (mounted) {
        String errorMsg = '搜索失败';
        if (e.toString().contains('Timeout') || e.toString().contains('超时')) {
          errorMsg = '请求超时，请检查网络连接';
        } else if (e.toString().contains('SocketException') || e.toString().contains('网络')) {
          errorMsg = '网络连接失败，请检查网络设置';
        } else if (e.toString().contains('401') || e.toString().contains('403')) {
          errorMsg = 'API配置错误，请检查设置';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isSearching = false;
        });
      }
    }
  }
  
  /// 拍照识别药品
  /// 功能：拍照识别药品外包装上的名称
  Future<void> _takePhotoAndRecognize() async {
    setState(() {
      isRecognizing = true;
    });
    
    try {
      print('开始拍照识别...');
      
      // 拍照识别
      String? medicineName = await ImageRecognitionService.instance.takePhotoAndRecognize();
      
      if (mounted) {
        if (medicineName != null && medicineName.isNotEmpty) {
          print('识别成功: $medicineName');
          
          // 填充药品名称
          setState(() {
            _nameController.text = medicineName;
          });
          
          // 自动搜索药品信息
          await _searchMedicine();
        } else {
          // 如果识别失败，提示用户手动输入
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('识别失败，请手动输入药品名称\n提示：确保照片清晰，药品名称可见'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      print('拍照识别失败: $e');
      if (mounted) {
        String errorMsg = '拍照识别失败';
        if (e.toString().contains('权限') || e.toString().contains('permission')) {
          errorMsg = '需要相机权限，请在设置中允许';
        } else if (e.toString().contains('网络') || e.toString().contains('Network')) {
          errorMsg = '网络连接失败，请检查网络';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$errorMsg\n请手动输入药品名称'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isRecognizing = false;
        });
      }
    }
  }
  
  /// 保存药品
  /// 功能：验证表单并保存药品到数据库，同时设置提醒
  Future<void> _saveMedicine() async {
    // 验证表单
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    // 验证至少选择一个时间
    if (selectedTimes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请至少选择一个服用时间'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    try {
      // 打印调试信息
      print('开始保存药品...');
      print('药品名称: ${_nameController.text.trim()}');
      print('剂量: ${_dosageController.text.trim()}');
      print('频次: ${_frequencyController.text.trim()}');
      print('时间列表: $selectedTimes');
      
      // 创建临时 Medicine 对象以使用 setTimeList 方法
      Medicine tempMedicine = Medicine(
        id: widget.medicine?.id, // 编辑模式时保留ID
        name: _nameController.text.trim(),
        dosage: _dosageController.text.trim(),
        frequency: _frequencyController.text.trim(),
        times: '[]', // 临时值，稍后设置
        instructions: _instructionsController.text.trim().isEmpty 
            ? null 
            : _instructionsController.text.trim(),
        contraindications: _contraindicationsController.text.trim().isEmpty 
            ? null 
            : _contraindicationsController.text.trim(),
        indications: _indicationsController.text.trim().isEmpty 
            ? null 
            : _indicationsController.text.trim(),
        maxDailyDosage: _maxDailyDosageController.text.trim().isEmpty 
            ? null 
            : _maxDailyDosageController.text.trim(),
        isActive: isActive,
      );
      // 设置时间列表
      tempMedicine.setTimeList(selectedTimes);
      Medicine medicine = tempMedicine;
      
      print('Medicine对象创建成功: ${medicine.toMap()}');
      
      // 保存到数据库
      if (widget.medicine != null) {
        // 更新现有药品
        print('更新药品，ID: ${medicine.id}');
        await DatabaseHelper.instance.updateMedicine(medicine);
        print('药品更新成功');
        // 取消旧提醒
        await NotificationService.instance.cancelMedicineReminders(medicine.id!);
      } else {
        // 插入新药品
        print('插入新药品...');
        int id = await DatabaseHelper.instance.insertMedicine(medicine);
        print('药品插入成功，ID: $id');
        medicine.id = id;
      }
      
      // 设置提醒
      if (medicine.isActive) {
        await NotificationService.instance.scheduleMedicineReminders(medicine);
      }
      
      // 显示成功提示
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.medicine != null ? '更新成功' : '添加成功'),
            backgroundColor: Colors.green,
          ),
        );
        
        // 返回上一页
        Navigator.pop(context, true);
      }
    } catch (e, stackTrace) {
      // 打印详细的错误信息，方便调试
      print('保存失败: $e');
      print('错误堆栈: $stackTrace');
      
      if (mounted) {
        // 显示详细的错误信息，帮助用户了解问题
        String errorMessage = '保存失败，请重试';
        String errorDetail = e.toString();
        
        if (errorDetail.contains('no such column') || errorDetail.contains('column')) {
          errorMessage = '数据库结构错误，请重新安装应用';
        } else if (errorDetail.contains('NOT NULL constraint')) {
          errorMessage = '请填写所有必填项（药品名称、剂量、频次）';
        } else if (errorDetail.contains('database') || errorDetail.contains('Database')) {
          errorMessage = '数据库错误，请重试或重启应用';
        } else if (errorDetail.contains('permission') || errorDetail.contains('权限')) {
          errorMessage = '权限不足，请检查应用权限设置';
        } else {
          // 显示原始错误信息的前100个字符，帮助调试
          errorMessage = '保存失败：${errorDetail.length > 100 ? errorDetail.substring(0, 100) : errorDetail}';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5), // 延长显示时间，让用户看清楚
            action: SnackBarAction(
              label: '查看详情',
              textColor: Colors.white,
              onPressed: () {
                // 显示完整的错误信息
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('错误详情'),
                    content: SingleChildScrollView(
                      child: Text(errorDetail),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('关闭'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.medicine != null ? '编辑药品' : '添加药品'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 药品名称（带搜索和拍照按钮）
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: '药品名称 *',
                        hintText: '例如：阿司匹林',
                        prefixIcon: Icon(Icons.medication),
                      ),
                      style: const TextStyle(fontSize: AppConstants.largeFontSize),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return '请输入药品名称';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  // 拍照按钮
                  IconButton(
                    icon: const Icon(Icons.camera_alt),
                    onPressed: _takePhotoAndRecognize,
                    tooltip: '拍照识别',
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  // 搜索按钮
                  IconButton(
                    icon: isSearching 
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.search),
                    onPressed: isSearching ? null : _searchMedicine,
                    tooltip: '搜索药品信息',
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // 剂量
              TextFormField(
                controller: _dosageController,
                decoration: const InputDecoration(
                  labelText: '剂量 *',
                  hintText: '例如：1片、2粒、5ml',
                  prefixIcon: Icon(Icons.straighten),
                ),
                style: const TextStyle(fontSize: AppConstants.largeFontSize),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '请输入剂量';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // 频次
              TextFormField(
                controller: _frequencyController,
                decoration: const InputDecoration(
                  labelText: '服用频次 *',
                  hintText: '例如：每天1次、每天2次、每8小时1次',
                  prefixIcon: Icon(Icons.repeat),
                ),
                style: const TextStyle(fontSize: AppConstants.largeFontSize),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '请输入服用频次';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // 服用时间
              const Text(
                '服用时间 *',
                style: TextStyle(
                  fontSize: AppConstants.largeFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // 时间列表
              if (selectedTimes.isEmpty)
                const Text(
                  '请点击下方按钮添加服用时间',
                  style: TextStyle(
                    fontSize: AppConstants.normalFontSize,
                    color: Color(AppConstants.secondaryTextColorValue),
                  ),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: selectedTimes.map((time) {
                    return Chip(
                      label: Text(
                        time,
                        style: const TextStyle(fontSize: AppConstants.normalFontSize),
                      ),
                      onDeleted: () => _removeTime(time),
                      deleteIcon: const Icon(Icons.close, size: 18),
                    );
                  }).toList(),
                ),
              
              const SizedBox(height: 8),
              
              // 添加时间按钮
              ElevatedButton.icon(
                onPressed: _addTime,
                icon: const Icon(Icons.add),
                label: const Text('添加服用时间'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // 说明
              TextFormField(
                controller: _instructionsController,
                decoration: const InputDecoration(
                  labelText: '服用说明（可选）',
                  hintText: '例如：饭前服用、饭后服用',
                  prefixIcon: Icon(Icons.info_outline),
                ),
                style: const TextStyle(fontSize: AppConstants.largeFontSize),
                maxLines: 2,
              ),
              
              const SizedBox(height: 16),
              
              // 禁忌
              TextFormField(
                controller: _contraindicationsController,
                decoration: const InputDecoration(
                  labelText: '禁忌说明（可选）',
                  hintText: '例如：孕妇禁用、不能与XX同服',
                  prefixIcon: Icon(Icons.warning),
                ),
                style: const TextStyle(fontSize: AppConstants.largeFontSize),
                maxLines: 2,
              ),
              
              const SizedBox(height: 16),
              
              // 主治功能
              TextFormField(
                controller: _indicationsController,
                decoration: const InputDecoration(
                  labelText: '主治功能（可选）',
                  hintText: '例如：治疗高血压、缓解疼痛',
                  prefixIcon: Icon(Icons.healing),
                ),
                style: const TextStyle(fontSize: AppConstants.largeFontSize),
                maxLines: 2,
              ),
              
              const SizedBox(height: 16),
              
              // 每日最大剂量限制
              TextFormField(
                controller: _maxDailyDosageController,
                decoration: const InputDecoration(
                  labelText: '每日最大剂量限制（可选）',
                  hintText: '例如：最多3次、最多6片',
                  prefixIcon: Icon(Icons.warning_amber),
                  helperText: '设置后，达到限制时会提醒',
                ),
                style: const TextStyle(fontSize: AppConstants.largeFontSize),
              ),
              
              const SizedBox(height: 24),
              
              // 启用提醒开关
              SwitchListTile(
                title: const Text(
                  '启用提醒',
                  style: TextStyle(fontSize: AppConstants.largeFontSize),
                ),
                subtitle: const Text(
                  '关闭后将不会收到提醒通知',
                  style: TextStyle(fontSize: AppConstants.smallFontSize),
                ),
                value: isActive,
                onChanged: (value) {
                  setState(() {
                    isActive = value;
                  });
                },
              ),
              
              const SizedBox(height: 32),
              
              // 保存按钮 - 使用自定义Container确保文字可见
              Container(
                width: double.infinity,
                height: 56, // 固定高度，确保按钮足够大
                decoration: BoxDecoration(
                  color: const Color(AppConstants.primaryColorValue), // 蓝色背景
                  borderRadius: BorderRadius.circular(8), // 圆角
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent, // 透明，让Container的颜色显示
                  child: InkWell(
                    onTap: _saveMedicine,
                    borderRadius: BorderRadius.circular(8),
                    child: Center(
                      child: Text(
                        '保存',
                        style: TextStyle(
                          fontSize: AppConstants.largeFontSize + 2,
                          fontWeight: FontWeight.bold,
                          color: Colors.white, // 白色文字，确保可见
                        ),
                      ),
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
