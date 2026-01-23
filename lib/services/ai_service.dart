// 版权所有 (C) 2025 Pill Helper
// 本代码遵循 AGPL-3.0 开源协议，个人非商用可自由使用、修改；商用需联系作者授权

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/medicine.dart';

/// AI服务（集成国内AI服务）
/// 功能：使用AI搜索药品信息、分析用药情况等
/// 支持：文心一言、通义千问、智谱AI等
/// 使用方法：配置API密钥后调用相应方法
class AIService {
  static final AIService instance = AIService._internal();
  AIService._internal();
  
  // AI服务配置（需要用户配置API密钥）
  // 可以从环境变量或配置文件读取
  String? _apiKey;
  String _apiType = 'volcano'; // wenxin(文心一言) / tongyi(通义千问) / zhipu(智谱AI) / volcano(火山方舟)
  String? _endpointId; // 火山方舟需要接入点ID（ep-开头）
  
  /// 设置API密钥
  /// 参数：API密钥和类型，火山方舟需要endpointId
  void setApiKey(String apiKey, {String type = 'volcano', String? endpointId}) {
    _apiKey = apiKey;
    _apiType = type;
    _endpointId = endpointId;
  }
  
  /// 搜索药品信息（使用AI）
  /// 参数：药品名称
  /// 返回：包含药品详细信息的Map
  Future<Map<String, dynamic>?> searchMedicineInfo(String medicineName) async {
    if (_apiKey == null || _apiKey!.isEmpty) {
      print('AI API密钥未配置，跳过AI搜索');
      return null;
    }
    
    try {
      // 构建AI提示词
      String prompt = '''
请帮我查找药品"$medicineName"的详细信息，包括：
1. 用法用量（剂量和频次）
2. 服用说明（饭前/饭后等）
3. 禁忌症
4. 主治功能

请以JSON格式返回，格式如下：
{
  "name": "药品名称",
  "dosage": "用法用量",
  "frequency": "服用频次",
  "instructions": "服用说明",
  "contraindications": "禁忌症",
  "indications": "主治功能"
}
''';
      
      // 根据API类型调用不同的服务
      switch (_apiType) {
        case 'wenxin':
          return await _callWenxinAPI(prompt);
        case 'tongyi':
          return await _callTongyiAPI(prompt);
        case 'zhipu':
          return await _callZhipuAPI(prompt);
        case 'volcano':
          return await _callVolcanoAPI(prompt);
        default:
          return await _callVolcanoAPI(prompt); // 默认使用火山方舟
      }
    } catch (e) {
      print('AI搜索失败: $e');
      return null;
    }
  }
  
  /// 调用文心一言API
  Future<Map<String, dynamic>?> _callWenxinAPI(String prompt) async {
    try {
      // 文心一言API地址（示例，需要替换为真实地址）
      final response = await http.post(
        Uri.parse('https://aip.baidubce.com/rpc/2.0/ai_custom/v1/wenxinworkshop/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
          'temperature': 0.7,
        }),
      ).timeout(Duration(seconds: 15));
      
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        String content = data['result'] ?? '';
        
        // 尝试解析JSON
        try {
          // 提取JSON部分
          int jsonStart = content.indexOf('{');
          int jsonEnd = content.lastIndexOf('}') + 1;
          if (jsonStart >= 0 && jsonEnd > jsonStart) {
            String jsonStr = content.substring(jsonStart, jsonEnd);
            return jsonDecode(jsonStr) as Map<String, dynamic>;
          }
        } catch (e) {
          print('解析AI返回的JSON失败: $e');
        }
      }
    } catch (e) {
      print('文心一言API调用失败: $e');
    }
    
    return null;
  }
  
  /// 调用通义千问API
  Future<Map<String, dynamic>?> _callTongyiAPI(String prompt) async {
    try {
      // 通义千问API地址（示例）
      final response = await http.post(
        Uri.parse('https://dashscope.aliyuncs.com/api/v1/services/aigc/text-generation/generation'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'qwen-turbo',
          'input': {'messages': [{'role': 'user', 'content': prompt}]},
        }),
      ).timeout(Duration(seconds: 15));
      
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        String content = data['output']?['text'] ?? '';
        
        // 解析JSON
        try {
          int jsonStart = content.indexOf('{');
          int jsonEnd = content.lastIndexOf('}') + 1;
          if (jsonStart >= 0 && jsonEnd > jsonStart) {
            String jsonStr = content.substring(jsonStart, jsonEnd);
            return jsonDecode(jsonStr) as Map<String, dynamic>;
          }
        } catch (e) {
          print('解析AI返回的JSON失败: $e');
        }
      }
    } catch (e) {
      print('通义千问API调用失败: $e');
    }
    
    return null;
  }
  
  /// 调用智谱AI API
  Future<Map<String, dynamic>?> _callZhipuAPI(String prompt) async {
    try {
      // 智谱AI API地址（示例）
      final response = await http.post(
        Uri.parse('https://open.bigmodel.cn/api/paas/v4/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'glm-4',
          'messages': [{'role': 'user', 'content': prompt}],
        }),
      ).timeout(Duration(seconds: 15));
      
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        String content = data['choices']?[0]?['message']?['content'] ?? '';
        
        // 解析JSON
        try {
          int jsonStart = content.indexOf('{');
          int jsonEnd = content.lastIndexOf('}') + 1;
          if (jsonStart >= 0 && jsonEnd > jsonStart) {
            String jsonStr = content.substring(jsonStart, jsonEnd);
            return jsonDecode(jsonStr) as Map<String, dynamic>;
          }
        } catch (e) {
          print('解析AI返回的JSON失败: $e');
        }
      }
    } catch (e) {
      print('智谱AI API调用失败: $e');
    }
    
    return null;
  }
  
  /// 分析用药情况（AI辅助）
  /// 参数：药品列表和服药记录
  /// 返回：AI分析结果和建议
  Future<String?> analyzeMedicationUsage(List<Medicine> medicines, List<dynamic> logs) async {
    if (_apiKey == null || _apiKey!.isEmpty) {
      return null;
    }
    
    try {
      String prompt = '''
请分析以下用药情况：
药品列表：${medicines.map((m) => '${m.name} - ${m.dosage} - ${m.frequency}').join('\n')}
服药记录：${logs.length}条

请提供：
1. 用药合理性分析
2. 潜在风险提醒
3. 用药建议
''';
      
      // 如果medicines为空，返回null
      if (medicines.isEmpty) {
        return null;
      }
      
      // 调用AI（使用默认服务）
      Map<String, dynamic>? result = await _callVolcanoAPI(prompt);
      return result?['content'] ?? result?['result'];
    } catch (e) {
      print('AI分析失败: $e');
      return null;
    }
  }
  
  /// 调用火山方舟多模态API（图片+文本）
  /// 功能：使用火山方舟的多模态API识别图片内容
  /// 参数：imageUrl - 图片URL，prompt - 文本提示词
  /// 返回：AI识别结果
  Future<Map<String, dynamic>?> callVolcanoMultimodalAPI(String imageUrl, String prompt) async {
    try {
      String model = _endpointId ?? 'ep-20260121173048-dmlkh';
      
      print('正在调用火山方舟多模态API，模型: $model');
      print('图片URL: $imageUrl');
      
      final response = await http.post(
        Uri.parse('https://ark.cn-beijing.volces.com/api/v3/responses'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': model,
          'input': [
            {
              'role': 'user',
              'content': [
                {
                  'type': 'input_image',
                  'image_url': imageUrl
                },
                {
                  'type': 'input_text',
                  'text': prompt
                }
              ]
            }
          ],
        }),
      ).timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          print('火山方舟多模态API调用超时（60秒）');
          throw TimeoutException('API调用超时', const Duration(seconds: 60));
        },
      );
      
      print('多模态API响应状态码: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        
        // 解析响应（与文本API相同的格式）
        String content = '';
        
        try {
          if (data['output'] != null && data['output'] is List) {
            List outputList = data['output'] as List;
            
            for (var item in outputList) {
              if (item is Map && item['type'] == 'message') {
                if (item['content'] != null && item['content'] is List) {
                  List contentList = item['content'] as List;
                  
                  for (var contentItem in contentList) {
                    if (contentItem is Map && contentItem['type'] == 'output_text') {
                      content = contentItem['text'] ?? '';
                      break;
                    }
                  }
                }
                if (content.isNotEmpty) break;
              }
            }
          }
        } catch (e) {
          print('解析多模态API响应失败: $e');
        }
        
        if (content.isNotEmpty) {
          // 尝试解析JSON
          try {
            int jsonStart = content.indexOf('{');
            int jsonEnd = content.lastIndexOf('}') + 1;
            if (jsonStart >= 0 && jsonEnd > jsonStart) {
              String jsonStr = content.substring(jsonStart, jsonEnd);
              return jsonDecode(jsonStr) as Map<String, dynamic>;
            }
          } catch (e) {
            print('解析AI返回的JSON失败: $e');
          }
          return {'content': content};
        }
      } else {
        print('火山方舟多模态API调用失败，状态码: ${response.statusCode}');
        print('响应内容: ${response.body}');
      }
    } catch (e) {
      print('火山方舟多模态API调用失败: $e');
    }
    
    return null;
  }
  
  /// 调用火山方舟API（文本）
  /// 功能：使用火山方舟（字节跳动）的AI服务
  /// 说明：使用正确的火山方舟API格式（/api/v3/responses）
  Future<Map<String, dynamic>?> _callVolcanoAPI(String prompt) async {
    try {
      // 火山方舟API地址（使用正确的端点）
      // 如果没有设置endpointId，使用默认接入点ID
      String model = _endpointId ?? 'ep-20260121173048-dmlkh';
      
      print('正在调用火山方舟API');
      print('模型: $model');
      print('API密钥: ${_apiKey != null ? (_apiKey!.substring(0, 8) + '...') : '未配置'}');
      print('提示词长度: ${prompt.length}');
      
      final response = await http.post(
        Uri.parse('https://ark.cn-beijing.volces.com/api/v3/responses'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': model,
          'input': [
            {
              'role': 'user',
              'content': [
                {
                  'type': 'input_text',
                  'text': prompt
                }
              ]
            }
          ],
        }),
      ).timeout(
        const Duration(seconds: 60), // 增加到60秒，AI响应可能需要较长时间
        onTimeout: () {
          print('火山方舟API调用超时（60秒）');
          throw TimeoutException('API调用超时', const Duration(seconds: 60));
        },
      );
      
      print('API响应状态码: ${response.statusCode}');
      print('响应内容长度: ${response.body.length}');
      
      // 打印响应内容的前500字符用于调试
      if (response.body.length > 0) {
        print('响应内容预览: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}');
      }
      
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        
        // 火山方舟API返回格式：
        // output是一个数组，包含reasoning和message
        // message的content数组包含output_text，text字段是实际内容
        String content = '';
        
        try {
          // 尝试从output数组中获取message
          if (data['output'] != null && data['output'] is List) {
            List outputList = data['output'] as List;
            
            // 查找message类型的元素
            for (var item in outputList) {
              if (item is Map && item['type'] == 'message') {
                // 获取content数组
                if (item['content'] != null && item['content'] is List) {
                  List contentList = item['content'] as List;
                  
                  // 查找output_text类型的内容
                  for (var contentItem in contentList) {
                    if (contentItem is Map && contentItem['type'] == 'output_text') {
                      content = contentItem['text'] ?? '';
                      break;
                    }
                  }
                }
                if (content.isNotEmpty) break;
              }
            }
          }
        } catch (e) {
          print('解析output数组失败: $e');
          print('响应数据结构: ${data.keys}');
          // 尝试直接打印响应以便调试
          print('完整响应（前500字符）: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}');
        }
        
        if (content.isEmpty) {
          print('火山方舟API返回内容为空');
          print('响应状态码: ${response.statusCode}');
          print('响应头: ${response.headers}');
          print('完整响应（前1000字符）: ${response.body.substring(0, response.body.length > 1000 ? 1000 : response.body.length)}');
          return null;
        }
        
        print('成功获取AI响应内容，长度: ${content.length}');
        
        // 尝试解析JSON
        try {
          int jsonStart = content.indexOf('{');
          int jsonEnd = content.lastIndexOf('}') + 1;
          if (jsonStart >= 0 && jsonEnd > jsonStart) {
            String jsonStr = content.substring(jsonStart, jsonEnd);
            return jsonDecode(jsonStr) as Map<String, dynamic>;
          }
        } catch (e) {
          print('解析AI返回的JSON失败: $e');
          print('原始内容: $content');
          // 如果解析失败，尝试直接返回内容
          return {'content': content};
        }
      } else {
        print('火山方舟API调用失败，状态码: ${response.statusCode}');
        print('响应内容: ${response.body}');
      }
    } catch (e) {
      print('火山方舟API调用失败: $e');
    }
    
    return null;
  }
}
