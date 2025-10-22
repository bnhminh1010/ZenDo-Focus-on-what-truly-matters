import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

/// Utility class để kiểm tra cấu trúc database
class DatabaseChecker {
  static final _supabase = Supabase.instance.client;

  /// Kiểm tra xem cột image_url đã tồn tại trong bảng tasks chưa
  static Future<bool> checkImageUrlColumnExists() async {
    try {
      // Thử query một task với cột image_url
      await _supabase
          .from('tasks')
          .select('id, image_url')
          .limit(1)
          .maybeSingle();

      // Nếu không có lỗi, nghĩa là cột đã tồn tại
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Lỗi khi kiểm tra cột image_url: $e');
      }
      return false;
    }
  }

  /// Kiểm tra cấu trúc bảng tasks
  static Future<void> checkTasksTableStructure() async {
    try {
      final response = await _supabase
          .from('tasks')
          .select('*')
          .limit(1)
          .maybeSingle();

      if (response != null && kDebugMode) {
        debugPrint('Cấu trúc bảng tasks:');
        for (final key in response.keys) {
          debugPrint('- $key: ${response[key]?.runtimeType}');
        }
      } else if (kDebugMode) {
        debugPrint('Bảng tasks trống hoặc không tồn tại');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Lỗi khi kiểm tra cấu trúc bảng: $e');
      }
    }
  }

  /// Test tạo task với image_url
  static Future<bool> testCreateTaskWithImage() async {
    try {
      final testTask = {
        'id': 'test-image-${DateTime.now().millisecondsSinceEpoch}',
        'title': 'Test Task với Image',
        'description': 'Test task để kiểm tra image_url',
        'category': 'work',
        'priority': 'medium',
        'created_at': DateTime.now().toIso8601String(),
        'image_url': '/test/path/image.jpg',
      };

      final response = await _supabase
          .from('tasks')
          .insert(testTask)
          .select()
          .single();

      if (kDebugMode) {
        debugPrint('Tạo test task thành công: ${response['id']}');
      }

      // Xóa test task
      await _supabase.from('tasks').delete().eq('id', response['id']);

      if (kDebugMode) {
        debugPrint('Đã xóa test task');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Lỗi khi test tạo task với image: $e');
      }
      return false;
    }
  }
}

