/*
 * Tên: services/subtask_service.dart
 * Tác dụng: Service quản lý các thao tác CRUD với Subtasks trong Supabase
 * Khi nào dùng: Cần xử lý subtasks của một task (tạo, sửa, xóa, reorder)
 */

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/subtask.dart';

/// Service quản lý các thao tác với Subtasks
class SubtaskService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Lấy tất cả subtasks của một task
  Future<List<Subtask>> getSubtasksByTaskId(String taskId) async {
    try {
      final response = await _supabase
          .from('subtasks')
          .select()
          .eq('task_id', taskId)
          .order('sort_order', ascending: true);

      return (response as List)
          .map((subtask) => Subtask.fromSupabaseMap(subtask))
          .toList();
    } catch (e) {
      throw Exception('Lỗi khi lấy danh sách subtasks: $e');
    }
  }

  /// Tạo subtask mới
  Future<Subtask> createSubtask({
    required String taskId,
    required String title,
    String? description,
    int? sortOrder,
  }) async {
    try {
      // Lấy user_id từ auth session
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Người dùng chưa đăng nhập');
      }

      final now = DateTime.now();
      final subtaskData = {
        'task_id': taskId,
        'user_id': userId, // Thêm user_id để thỏa mãn RLS policy
        'title': title,
        'description': description,
        'is_completed': false,
        'sort_order': sortOrder ?? 0,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };

      final response = await _supabase
          .from('subtasks')
          .insert(subtaskData)
          .select()
          .single();

      return Subtask.fromSupabaseMap(response);
    } catch (e) {
      throw Exception('Lỗi khi tạo subtask: $e');
    }
  }

  /// Cập nhật subtask
  Future<Subtask> updateSubtask(Subtask subtask) async {
    try {
      final updateData = subtask.toMap();
      updateData['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabase
          .from('subtasks')
          .update(updateData)
          .eq('id', subtask.id)
          .select()
          .single();

      return Subtask.fromSupabaseMap(response);
    } catch (e) {
      throw Exception('Lỗi khi cập nhật subtask: $e');
    }
  }

  /// Đánh dấu subtask hoàn thành/chưa hoàn thành
  Future<Subtask> toggleSubtaskCompletion(String subtaskId) async {
    try {
      // Lấy subtask hiện tại
      final currentResponse = await _supabase
          .from('subtasks')
          .select()
          .eq('id', subtaskId)
          .single();

      final currentSubtask = Subtask.fromSupabaseMap(currentResponse);
      final newCompletionStatus = !currentSubtask.isCompleted;
      final now = DateTime.now();

      final updateData = {
        'is_completed': newCompletionStatus,
        'completed_at': newCompletionStatus ? now.toIso8601String() : null,
        'updated_at': now.toIso8601String(),
      };

      final response = await _supabase
          .from('subtasks')
          .update(updateData)
          .eq('id', subtaskId)
          .select()
          .single();

      return Subtask.fromSupabaseMap(response);
    } catch (e) {
      throw Exception('Lỗi khi thay đổi trạng thái subtask: $e');
    }
  }

  /// Xóa subtask
  Future<void> deleteSubtask(String subtaskId) async {
    try {
      await _supabase.from('subtasks').delete().eq('id', subtaskId);
    } catch (e) {
      throw Exception('Lỗi khi xóa subtask: $e');
    }
  }

  /// Sắp xếp lại thứ tự subtasks
  Future<void> reorderSubtasks(List<Subtask> subtasks) async {
    try {
      final batch = <Map<String, dynamic>>[];

      for (int i = 0; i < subtasks.length; i++) {
        batch.add({
          'id': subtasks[i].id,
          'sort_order': i,
          'updated_at': DateTime.now().toIso8601String(),
        });
      }

      // Cập nhật từng subtask với sort_order mới
      for (final update in batch) {
        await _supabase
            .from('subtasks')
            .update({
              'sort_order': update['sort_order'],
              'updated_at': update['updated_at'],
            })
            .eq('id', update['id']);
      }
    } catch (e) {
      throw Exception('Lỗi khi sắp xếp lại subtasks: $e');
    }
  }

  /// Lấy số lượng subtasks hoàn thành của một task
  Future<int> getCompletedSubtaskCount(String taskId) async {
    try {
      final response = await _supabase
          .from('subtasks')
          .select('id')
          .eq('task_id', taskId)
          .eq('is_completed', true);

      return (response as List).length;
    } catch (e) {
      throw Exception('Lỗi khi đếm subtasks hoàn thành: $e');
    }
  }

  /// Lấy tổng số subtasks của một task
  Future<int> getTotalSubtaskCount(String taskId) async {
    try {
      final response = await _supabase
          .from('subtasks')
          .select('id')
          .eq('task_id', taskId);

      return (response as List).length;
    } catch (e) {
      throw Exception('Lỗi khi đếm tổng subtasks: $e');
    }
  }

  /// Tính phần trăm hoàn thành subtasks của một task
  Future<double> getSubtaskProgress(String taskId) async {
    try {
      final total = await getTotalSubtaskCount(taskId);
      if (total == 0) return 0.0;

      final completed = await getCompletedSubtaskCount(taskId);
      return completed / total;
    } catch (e) {
      throw Exception('Lỗi khi tính phần trăm hoàn thành subtasks: $e');
    }
  }

  /// Xóa tất cả subtasks của một task
  Future<void> deleteAllSubtasksByTaskId(String taskId) async {
    try {
      await _supabase.from('subtasks').delete().eq('task_id', taskId);
    } catch (e) {
      throw Exception('Lỗi khi xóa tất cả subtasks: $e');
    }
  }

  /// Tạo nhiều subtasks cùng lúc
  Future<List<Subtask>> createMultipleSubtasks({
    required String taskId,
    required List<String> titles,
  }) async {
    try {
      final now = DateTime.now();
      final subtasksData = titles.asMap().entries.map((entry) {
        return {
          'task_id': taskId,
          'title': entry.value,
          'is_completed': false,
          'sort_order': entry.key,
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        };
      }).toList();

      final response = await _supabase
          .from('subtasks')
          .insert(subtasksData)
          .select();

      return (response as List)
          .map((subtask) => Subtask.fromSupabaseMap(subtask))
          .toList();
    } catch (e) {
      throw Exception('Lỗi khi tạo nhiều subtasks: $e');
    }
  }
}

