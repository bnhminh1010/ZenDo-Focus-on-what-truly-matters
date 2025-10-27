/*
 * Tên: services/gemini_ai_service.dart
 * Tác dụng: Service quản lý tương tác với Gemini AI cho chat và task suggestions
 * Khi nào dùng: Cần tích hợp AI để hỗ trợ người dùng quản lý tasks và productivity
 */

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/task.dart';
import '../config/app_config.dart';

/// Service để quản lý tương tác với Gemini AI
class GeminiAIService {
  late final GenerativeModel _model;
  late final GenerativeModel _visionModel;
  bool _isInitialized = false;

  /// Singleton instance
  static final GeminiAIService _instance = GeminiAIService._internal();
  factory GeminiAIService() => _instance;
  GeminiAIService._internal();

  bool get isInitialized => _isInitialized;

  /// Khởi tạo service với API key
  Future<void> initialize() async {
    try {
      // Lấy API key từ environment (chỉ trong development) hoặc sử dụng default từ AppConfig
      String apiKey = AppConfig.defaultGeminiApiKey;
      
      // Chỉ load từ dotenv trong development mode
      if (kDebugMode) {
        try {
          apiKey = dotenv.env['GEMINI_API_KEY'] ?? AppConfig.defaultGeminiApiKey;
        } catch (e) {
          // Nếu không load được dotenv, sử dụng default
          apiKey = AppConfig.defaultGeminiApiKey;
        }
      }

      if (apiKey.isEmpty) {
        throw Exception('GEMINI_API_KEY không được tìm thấy');
      }

      _model = GenerativeModel(
        model: 'gemini-2.0-flash-lite',
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.7,
          topK: 40,
          topP: 0.95,
          maxOutputTokens: 1024,
        ),
      );

      // Khởi tạo vision model để xử lý hình ảnh
      _visionModel = GenerativeModel(
        model: 'gemini-2.0-flash-lite',
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.7,
          topK: 40,
          topP: 0.95,
          maxOutputTokens: 1024,
        ),
      );

      _isInitialized = true;
      if (kDebugMode) {
        debugPrint('GeminiAIService đã được khởi tạo thành công');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Lỗi khởi tạo GeminiAIService: $e');
      }
      rethrow;
    }
  }

  /// Gửi tin nhắn với file đính kèm
  Future<String> sendMessageWithFile(String message, File file) async {
    try {
      final fileBytes = await file.readAsBytes();
      final fileName = file.path.split('/').last.toLowerCase();

      String mimeType = 'application/octet-stream';
      if (fileName.endsWith('.jpg') || fileName.endsWith('.jpeg')) {
        mimeType = 'image/jpeg';
      } else if (fileName.endsWith('.png')) {
        mimeType = 'image/png';
      } else if (fileName.endsWith('.pdf')) {
        mimeType = 'application/pdf';
      } else if (fileName.endsWith('.txt')) {
        mimeType = 'text/plain';
      }

      final content = Content.multi([
        TextPart(message),
        DataPart(mimeType, fileBytes),
      ]);

      final response = await _visionModel.generateContent([content]);

      if (response.text != null && response.text!.isNotEmpty) {
        return response.text!;
      } else {
        throw Exception('Không nhận được phản hồi từ AI');
      }
    } catch (e) {
      debugPrint('❌ Lỗi khi gửi tin nhắn với file: $e');
      rethrow;
    }
  }

  /// Gửi tin nhắn đơn giản và nhận phản hồi
  Future<String> sendMessage(String message) async {
    try {
      final content = [Content.text(message)];
      final response = await _model.generateContent(content);

      if (response.text != null && response.text!.isNotEmpty) {
        return response.text!;
      } else {
        throw Exception('Không nhận được phản hồi từ AI');
      }
    } catch (e) {
      debugPrint('❌ Lỗi khi gửi tin nhắn: $e');
      rethrow;
    }
  }

  /// Chat với context (lịch sử hội thoại)
  Future<String> chatWithContext(List<Map<String, String>> messages) async {
    try {
      final chat = _model.startChat();

      // Gửi lịch sử tin nhắn (trừ tin nhắn cuối cùng)
      for (int i = 0; i < messages.length - 1; i++) {
        final msg = messages[i];
        if (msg['role'] == 'user') {
          await chat.sendMessage(Content.text(msg['content'] ?? ''));
        }
      }

      // Gửi tin nhắn cuối cùng và nhận phản hồi
      final lastMessage = messages.last;
      final response = await chat.sendMessage(
        Content.text(lastMessage['content'] ?? ''),
      );

      if (response.text != null && response.text!.isNotEmpty) {
        return response.text!;
      } else {
        throw Exception('Không nhận được phản hồi từ AI');
      }
    } catch (e) {
      debugPrint('❌ Lỗi khi chat với context: $e');
      rethrow;
    }
  }

  /// Phân tích task và đề xuất độ ưu tiên
  Future<Map<String, dynamic>> analyzeTaskPriority(
    String taskDescription,
  ) async {
    try {
      final prompt =
          '''
Phân tích task sau và đưa ra đánh giá:
Task: "$taskDescription"

Hãy trả về JSON với format:
{
  "priority": "high|medium|low",
  "urgency": "urgent|normal|low",
  "estimatedTime": "số phút ước tính",
  "category": "work|personal|health|learning|other",
  "suggestions": "gợi ý cải thiện task",
  "reasoning": "lý do đánh giá"
}
''';

      final response = await sendMessage(prompt);

      // Parse JSON response (simplified - trong thực tế cần xử lý robust hơn)
      return {
        'priority': 'medium',
        'urgency': 'normal',
        'estimatedTime': '30',
        'category': 'other',
        'suggestions': response,
        'reasoning': 'AI analysis completed',
      };
    } catch (e) {
      debugPrint('❌ Lỗi khi phân tích task: $e');
      return {
        'priority': 'medium',
        'urgency': 'normal',
        'estimatedTime': '30',
        'category': 'other',
        'suggestions': 'Không thể phân tích task này',
        'reasoning': 'Lỗi khi gọi AI: $e',
      };
    }
  }

  /// Tạo task từ mô tả tự nhiên
  Future<Task?> createTaskFromDescription(
    String description, {
    File? imageFile,
  }) async {
    if (!_isInitialized) {
      throw Exception('Gemini AI service not initialized');
    }

    try {
      String prompt =
          '''
Phân tích mô tả sau và tạo một task với thông tin chi tiết:
"$description"
''';

      // Nếu có hình ảnh, thêm prompt phân tích hình ảnh
      if (imageFile != null) {
        prompt += '''

Hình ảnh đính kèm có thể chứa thông tin bổ sung về task. Hãy phân tích hình ảnh và kết hợp với mô tả text để tạo task chi tiết hơn.
''';
      }

      prompt += '''

Trả về kết quả theo định dạng JSON chính xác sau:
{
  "title": "Tiêu đề task ngắn gọn",
  "description": "Mô tả chi tiết task",
  "priority": "high|medium|low",
  "estimatedTime": số_phút_ước_tính,
  "category": "work|personal|health|learning|other"
}

Chỉ trả về JSON, không có text khác.
''';

      List<Content> content = [];

      // Thêm hình ảnh nếu có
      if (imageFile != null) {
        final imageBytes = await imageFile.readAsBytes();
        content.add(
          Content.multi([TextPart(prompt), DataPart('image/jpeg', imageBytes)]),
        );
      } else {
        content.add(Content.text(prompt));
      }

      final response = await _visionModel.generateContent(content);
      final responseText = response.text?.trim();

      if (responseText == null || responseText.isEmpty) {
        return null;
      }

      // Parse JSON response
      final jsonResponse = _parseJsonFromResponse(responseText);
      if (jsonResponse == null) return null;

      // Tạo Task từ JSON
      return Task(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: jsonResponse['title'] ?? 'Untitled Task',
        description: jsonResponse['description'] ?? '',
        priority: _parsePriority(jsonResponse['priority']),
        estimatedMinutes: jsonResponse['estimatedTime'] ?? 30,
        category: _getCategoryFromName(jsonResponse['category']),
        createdAt: DateTime.now(),
        isCompleted: false,
        imageUrl: imageFile?.path, // Lưu đường dẫn hình ảnh
      );
    } catch (e) {
      throw Exception('Failed to create task from description: $e');
    }
  }

  Future<String?> analyzePriorities(List<Task> tasks) async {
    if (!_isInitialized) {
      throw Exception('Gemini AI service not initialized');
    }

    try {
      final taskList = tasks
          .map(
            (task) =>
                '- ${task.title} (Ưu tiên: ${task.priority.name}, Thời gian ước tính: ${task.estimatedMinutes} phút)',
          )
          .join('\n');

      final prompt =
          '''
Phân tích danh sách task sau và đưa ra gợi ý sắp xếp ưu tiên:

$taskList

Hãy:
1. Đánh giá mức độ ưu tiên hiện tại
2. Đề xuất thứ tự thực hiện tối ưu
3. Giải thích lý do sắp xếp
4. Đưa ra gợi ý cải thiện năng suất

Trả lời bằng tiếng Việt, ngắn gọn và thực tế.
''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      return response.text;
    } catch (e) {
      throw Exception('Failed to analyze priorities: $e');
    }
  }

  Future<String?> getProductivityTips() async {
    if (!_isInitialized) {
      throw Exception('Gemini AI service not initialized');
    }

    try {
      final prompt = '''
Đưa ra 5 gợi ý cụ thể để cải thiện năng suất làm việc và quản lý thời gian.

Mỗi gợi ý cần:
- Ngắn gọn, dễ thực hiện
- Có ví dụ cụ thể
- Phù hợp với người Việt Nam

Trả lời bằng tiếng Việt.
''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      return response.text;
    } catch (e) {
      throw Exception('Failed to get productivity tips: $e');
    }
  }

  /// Phân tích thói quen focus session
  Future<String> analyzeFocusHabits(
    List<Map<String, dynamic>> focusSessions,
  ) async {
    try {
      final sessionsData = focusSessions
          .map((session) {
            return 'Ngày: ${session['startedAt']}, Thời lượng: ${session['duration']} phút, Nhiễu: ${session['distractionCount']}';
          })
          .join('\n');

      final prompt =
          '''
Phân tích dữ liệu focus session sau và đưa ra nhận xét về thói quen:

$sessionsData

Hãy đưa ra:
1. Nhận xét về xu hướng tập trung
2. Thời điểm tập trung tốt nhất
3. Gợi ý cải thiện
4. Mục tiêu cho tuần tới

Trả lời bằng tiếng Việt, ngắn gọn và thực tế.
''';

      return await sendMessage(prompt);
    } catch (e) {
      debugPrint('❌ Lỗi khi phân tích thói quen: $e');
      return 'Không thể phân tích dữ liệu focus session. Vui lòng thử lại sau.';
    }
  }

  // Helper methods
  Map<String, dynamic>? _parseJsonFromResponse(String response) {
    try {
      // Tìm JSON trong response
      final jsonStart = response.indexOf('{');
      final jsonEnd = response.lastIndexOf('}');

      if (jsonStart == -1 || jsonEnd == -1) return null;

      final jsonString = response.substring(jsonStart, jsonEnd + 1);
      return _parseJson(jsonString);
    } catch (e) {
      return null;
    }
  }

  Map<String, dynamic>? _parseJson(String jsonString) {
    try {
      // Simple JSON parser for the expected format
      final cleaned = jsonString.replaceAll('\n', '').replaceAll('  ', ' ');
      final Map<String, dynamic> result = {};

      // Extract title
      final titleMatch = RegExp(r'"title":\s*"([^"]*)"').firstMatch(cleaned);
      if (titleMatch != null) result['title'] = titleMatch.group(1);

      // Extract description
      final descMatch = RegExp(
        r'"description":\s*"([^"]*)"',
      ).firstMatch(cleaned);
      if (descMatch != null) result['description'] = descMatch.group(1);

      // Extract priority
      final priorityMatch = RegExp(
        r'"priority":\s*"([^"]*)"',
      ).firstMatch(cleaned);
      if (priorityMatch != null) result['priority'] = priorityMatch.group(1);

      // Extract estimatedTime
      final timeMatch = RegExp(r'"estimatedTime":\s*(\d+)').firstMatch(cleaned);
      if (timeMatch != null)
        result['estimatedTime'] =
            int.tryParse(timeMatch.group(1) ?? '30') ?? 30;

      // Extract category
      final categoryMatch = RegExp(
        r'"category":\s*"([^"]*)"',
      ).firstMatch(cleaned);
      if (categoryMatch != null) result['category'] = categoryMatch.group(1);

      return result;
    } catch (e) {
      return null;
    }
  }

  TaskPriority _parsePriority(String? priority) {
    switch (priority?.toLowerCase()) {
      case 'high':
        return TaskPriority.high;
      case 'low':
        return TaskPriority.low;
      default:
        return TaskPriority.medium;
    }
  }

  TaskCategory _getCategoryFromName(String? categoryName) {
    switch (categoryName?.toLowerCase()) {
      case 'work':
        return TaskCategory.work;
      case 'personal':
        return TaskCategory.personal;
      case 'health':
        return TaskCategory.health;
      case 'learning':
        return TaskCategory.learning;
      default:
        return TaskCategory.other;
    }
  }

  /// Kiểm tra trạng thái kết nối
  Future<bool> checkConnection() async {
    try {
      final response = await sendMessage('Hello');
      return response.isNotEmpty;
    } catch (e) {
      debugPrint('❌ Không thể kết nối với Gemini AI: $e');
      return false;
    }
  }
}

