// 版权所有 (C) 2025 Pill Helper
// 本代码遵循 AGPL-3.0 开源协议，个人非商用可自由使用、修改；商用需联系作者授权

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/medicine.dart';
import 'ai_service.dart';

/// 药品搜索服务
/// 功能：通过药品名称搜索药品说明书信息，自动填充表单
/// 使用方法：调用 searchMedicine() 方法，传入药品名称
class MedicineSearchService {
  static final MedicineSearchService instance = MedicineSearchService._internal();
  MedicineSearchService._internal();
  
  /// 搜索药品信息
  /// 参数：药品名称
  /// 返回：包含药品详细信息的Map，如果未找到则返回null
  /// 说明：优先使用AI服务，如果失败则使用药品数据库API
  Future<Map<String, dynamic>?> searchMedicine(String medicineName) async {
    if (medicineName.trim().isEmpty) {
      return null;
    }
    
    try {
      // 方法1：使用AI服务搜索（推荐，更智能）
      Map<String, dynamic>? aiResult = await AIService.instance.searchMedicineInfo(medicineName);
      if (aiResult != null && aiResult.isNotEmpty) {
        return aiResult;
      }
    } catch (e) {
      print('AI搜索失败: $e');
      // 继续执行，不返回null，让用户知道搜索失败
    }
    
    // 方法2：使用药品数据库API（备用方案）
    // 注意：当前已禁用，因为使用的是示例API地址
    // 如果需要启用，请替换为真实的药品数据库API地址
    // 暂时完全禁用，避免不必要的网络请求和错误
    return null;
  }
  
  /// 从药品数据库API搜索
  /// 参数：药品名称
  /// 返回：药品信息Map
  /// 说明：这里使用示例API，实际使用时需要替换为真实的药品数据库API
  Future<Map<String, dynamic>?> _searchFromAPI(String medicineName) async {
    try {
      // 示例：使用药监局或第三方药品数据库API
      // 注意：需要替换为真实的API地址和参数
      String apiUrl = 'https://api.example.com/medicine/search'; // 示例URL
      
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': medicineName,
        }),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        
        // 解析API返回的数据
        return {
          'name': data['name'] ?? medicineName,
          'dosage': data['dosage'] ?? '',
          'frequency': data['frequency'] ?? '',
          'instructions': data['instructions'] ?? data['usage'] ?? '',
          'contraindications': data['contraindications'] ?? data['warning'] ?? '',
          'indications': data['indications'] ?? data['function'] ?? '', // 主治功能
        };
      }
    } catch (e) {
      print('API请求失败: $e');
    }
    
    return null;
  }
  
  /// 将搜索结果转换为Medicine对象（部分填充）
  /// 参数：搜索结果Map
  /// 返回：部分填充的Medicine对象
  Medicine? convertToMedicine(Map<String, dynamic> searchResult) {
    try {
      return Medicine(
        name: searchResult['name'] ?? '',
        dosage: searchResult['dosage'] ?? '',
        frequency: searchResult['frequency'] ?? '',
        times: '[]', // 时间需要用户手动设置
        instructions: searchResult['instructions'],
        contraindications: searchResult['contraindications'],
      );
    } catch (e) {
      print('转换失败: $e');
      return null;
    }
  }
}
