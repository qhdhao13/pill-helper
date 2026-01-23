// 版权所有 (C) 2025 Pill Helper
// 本代码遵循 AGPL-3.0 开源协议，个人非商用可自由使用、修改；商用需联系作者授权

import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'ai_service.dart';

/// 图片识别服务
/// 功能：拍照识别药品外包装上的药品名称
/// 使用方法：调用 takePhotoAndRecognize() 方法
class ImageRecognitionService {
  static final ImageRecognitionService instance = ImageRecognitionService._internal();
  ImageRecognitionService._internal();
  
  final ImagePicker _picker = ImagePicker();
  
  /// 拍照并识别药品名称
  /// 返回：识别出的药品名称，如果失败则返回null
  Future<String?> takePhotoAndRecognize() async {
    try {
      // 选择图片（拍照或从相册选择）
      XFile? image = await _picker.pickImage(
        source: ImageSource.camera, // 优先使用拍照
        imageQuality: 80, // 压缩质量
      );
      
      if (image == null) {
        return null;
      }
      
      // 读取图片文件
      Uint8List imageBytes;
      if (kIsWeb) {
        imageBytes = await image.readAsBytes();
      } else {
        File imageFile = File(image.path);
        imageBytes = await imageFile.readAsBytes();
      }
      
      // 使用AI识别药品名称
      String? medicineName = await _recognizeWithAI(imageBytes);
      
      return medicineName;
    } catch (e) {
      print('拍照识别失败: $e');
      return null;
    }
  }
  
  /// 从相册选择并识别
  /// 返回：识别出的药品名称
  Future<String?> pickImageAndRecognize() async {
    try {
      XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      
      if (image == null) {
        return null;
      }
      
      Uint8List imageBytes;
      if (kIsWeb) {
        imageBytes = await image.readAsBytes();
      } else {
        File imageFile = File(image.path);
        imageBytes = await imageFile.readAsBytes();
      }
      
      String? medicineName = await _recognizeWithAI(imageBytes);
      
      return medicineName;
    } catch (e) {
      print('图片识别失败: $e');
      return null;
    }
  }
  
  /// 使用AI识别图片中的药品名称
  /// 参数：图片字节数据
  /// 返回：识别出的药品名称
  /// 说明：使用火山方舟的多模态API支持图片识别
  /// 注意：先尝试使用base64，如果失败则尝试上传图片
  Future<String?> _recognizeWithAI(Uint8List imageBytes) async {
    try {
      print('开始识别图片，图片大小: ${imageBytes.length} bytes');
      
      // 方法1：尝试使用base64编码（如果API支持）
      String base64Image = base64Encode(imageBytes);
      String base64DataUrl = 'data:image/jpeg;base64,$base64Image';
      
      print('图片已转换为base64，长度: ${base64Image.length}');
      
      // 调用火山方舟多模态API
      String prompt = '请识别这张药品外包装图片中的药品名称，只返回药品的通用名称，不要返回其他信息。';
      
      // 尝试使用base64 URL
      print('尝试使用base64方式调用API...');
      Map<String, dynamic>? result = await AIService.instance.callVolcanoMultimodalAPI(base64DataUrl, prompt);
      
      // 如果base64失败，尝试上传到图床（待实现）
      if (result == null) {
        print('base64方式失败，尝试上传图片...');
        String imageUrl = await _uploadImageToURL(imageBytes);
        
        if (imageUrl.isNotEmpty) {
          print('图片上传成功，URL: $imageUrl');
          result = await AIService.instance.callVolcanoMultimodalAPI(imageUrl, prompt);
        } else {
          print('图片上传失败，无法进行识别');
          print('提示：需要实现图片上传功能（火山方舟TOS或其他图床）');
          return null;
        }
      }
      
      if (result != null) {
        // 提取药品名称
        String? medicineName = result['name'] ?? result['content'];
        if (medicineName != null && medicineName.isNotEmpty) {
          // 清理可能的JSON格式
          medicineName = medicineName.trim();
          if (medicineName.startsWith('"') && medicineName.endsWith('"')) {
            medicineName = medicineName.substring(1, medicineName.length - 1);
          }
          print('识别成功，药品名称: $medicineName');
          return medicineName;
        }
      }
      
      print('识别失败，未找到药品名称');
      return null;
    } catch (e) {
      print('AI识别失败: $e');
      print('错误类型: ${e.runtimeType}');
      return null;
    }
  }
  
  /// 上传图片到URL（待实现）
  /// 参数：图片字节数据
  /// 返回：图片URL
  /// 说明：当前返回空，需要实现图片上传功能
  /// 可以使用：火山方舟TOS、七牛云、阿里云OSS等
  Future<String> _uploadImageToURL(Uint8List imageBytes) async {
    // TODO: 实现图片上传到火山方舟TOS或其他图床服务
    // 
    // 方案1：使用火山方舟TOS
    // 1. 获取上传凭证（从火山方舟控制台）
    // 2. 上传图片到TOS
    // 3. 返回图片URL
    //
    // 方案2：使用其他图床服务
    // - 七牛云
    // - 阿里云OSS
    // - 腾讯云COS
    // - Imgur等
    
    print('图片上传功能待实现');
    return ''; // 返回空表示需要实现上传功能
  }
}
