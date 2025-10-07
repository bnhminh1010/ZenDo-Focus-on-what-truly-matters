import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/task.dart';
import '../models/focus_session.dart';

/// Service quản lý database operations với Supabase
/// Xử lý CRUD cho tasks, categories và các operations khác
class SupabaseDatabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Getter để lấy user ID hiện tại
  String? get _currentUserId => _supabase.auth.currentUser?.id;

  /// Kiểm tra user đã đăng nhập chưa
  bool get isUserAuthenticated => _currentUserId != null;

  // ==================== TASKS OPERATIONS ====================

  /// Lấy tất cả tasks của user hiện tại
  Future<List<Task>> getTasks() async {
    try {
      if (!isUserAuthenticated) {
        throw Exception('User not authenticated');
      }

      final response = await _supabase
          .from('tasks')
          .select('*')
          .eq('user_id', _currentUserId!)
          .order('created_at', ascending: false);

      return (response as List)
          .map((taskData) => Task.fromSupabaseMap(taskData))
          .toList();
    } catch (e) {
      debugPrint('Error getting tasks: $e');
      return [];
    }
  }

  /// Lấy tasks theo category
  Future<List<Task>> getTasksByCategory(String categoryId) async {
    try {
      if (!isUserAuthenticated) {
        throw Exception('User not authenticated');
      }

      final response = await _supabase
          .from('tasks')
          .select('*')
          .eq('user_id', _currentUserId!)
          .eq('category_id', categoryId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((taskData) => Task.fromSupabaseMap(taskData))
          .toList();
    } catch (e) {
      debugPrint('Error getting tasks by category: $e');
      return [];
    }
  }

  /// Tạo task mới
  Future<Task?> createTask(Task task) async {
    try {
      if (!isUserAuthenticated) {
        throw Exception('User not authenticated');
      }

      final taskData = task.toSupabaseMap();
      taskData['user_id'] = _currentUserId!;
      taskData['created_at'] = DateTime.now().toIso8601String();
      taskData['updated_at'] = DateTime.now().toIso8601String();

      debugPrint('Creating task with data: $taskData');

      final response = await _supabase
          .from('tasks')
          .insert(taskData)
          .select()
          .single()
          .timeout(
            const Duration(seconds: 15), // Timeout cho operation
            onTimeout: () {
              throw Exception('Request timeout - please check your internet connection');
            },
          );

      debugPrint('Task created successfully: ${response['title']}');
      return Task.fromSupabaseMap(response);
    } on TimeoutException catch (e) {
      debugPrint('Timeout error creating task: $e');
      throw Exception('Connection timeout - please try again');
    } catch (e) {
      debugPrint('Error creating task: $e');
      if (e.toString().contains('HandshakeException')) {
        throw Exception('Connection error - please check your internet connection and try again');
      }
      rethrow;
    }
  }

  /// Cập nhật task
  Future<Task?> updateTask(String taskId, Task updatedTask) async {
    try {
      if (!isUserAuthenticated) {
        throw Exception('User not authenticated');
      }

      final taskData = updatedTask.toSupabaseMap();
      taskData['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabase
          .from('tasks')
          .update(taskData)
          .eq('id', taskId)
          .eq('user_id', _currentUserId!)
          .select()
          .single();

      debugPrint('Task updated successfully: ${response['title']}');
      return Task.fromSupabaseMap(response);
    } catch (e) {
      debugPrint('Error updating task: $e');
      return null;
    }
  }

  /// Xóa task
  Future<bool> deleteTask(String taskId) async {
    try {
      if (!isUserAuthenticated) {
        throw Exception('User not authenticated');
      }

      await _supabase
          .from('tasks')
          .delete()
          .eq('id', taskId)
          .eq('user_id', _currentUserId!);

      debugPrint('Task deleted successfully: $taskId');
      return true;
    } catch (e) {
      debugPrint('Error deleting task: $e');
      return false;
    }
  }

  /// Toggle trạng thái completed của task
  Future<Task?> toggleTaskComplete(String taskId) async {
    try {
      if (!isUserAuthenticated) {
        throw Exception('User not authenticated');
      }

      // Lấy task hiện tại
      final currentTask = await _supabase
          .from('tasks')
          .select('is_completed')
          .eq('id', taskId)
          .eq('user_id', _currentUserId!)
          .single();

      final newCompletedStatus = !(currentTask['is_completed'] ?? false);

      // Cập nhật trạng thái
      final response = await _supabase
          .from('tasks')
          .update({
            'is_completed': newCompletedStatus,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', taskId)
          .eq('user_id', _currentUserId!)
          .select()
          .single();

      debugPrint('Task completion toggled: ${response['title']} -> $newCompletedStatus');
      return Task.fromSupabaseMap(response);
    } catch (e) {
      debugPrint('Error toggling task completion: $e');
      return null;
    }
  }

  // ==================== FOCUS SESSIONS OPERATIONS ====================

  /// Tạo focus session mới
  Future<FocusSession?> createFocusSession(FocusSession session) async {
    try {
      if (!isUserAuthenticated) {
        throw Exception('User not authenticated');
      }

      final sessionData = session.toSupabaseMap();
      sessionData['user_id'] = _currentUserId!;
      sessionData['created_at'] = DateTime.now().toIso8601String();
      sessionData['updated_at'] = DateTime.now().toIso8601String();

      debugPrint('Creating focus session with data: $sessionData');

      final response = await _supabase
          .from('focus_sessions')
          .insert(sessionData)
          .select()
          .single()
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw Exception('Request timeout - please check your internet connection');
            },
          );

      debugPrint('Focus session created successfully: ${response['id']}');
      return FocusSession.fromSupabaseMap(response);
    } on TimeoutException catch (e) {
      debugPrint('Timeout error creating focus session: $e');
      throw Exception('Connection timeout - please try again');
    } catch (e) {
      debugPrint('Error creating focus session: $e');
      if (e.toString().contains('HandshakeException')) {
        throw Exception('Connection error - please check your internet connection and try again');
      }
      rethrow;
    }
  }

  /// Cập nhật focus session
  Future<FocusSession?> updateFocusSession(String sessionId, FocusSession updatedSession) async {
    try {
      if (!isUserAuthenticated) {
        throw Exception('User not authenticated');
      }

      final sessionData = updatedSession.toSupabaseMap();
      sessionData['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabase
          .from('focus_sessions')
          .update(sessionData)
          .eq('id', sessionId)
          .eq('user_id', _currentUserId!)
          .select()
          .single();

      debugPrint('Focus session updated successfully: ${response['id']}');
      return FocusSession.fromSupabaseMap(response);
    } catch (e) {
      debugPrint('Error updating focus session: $e');
      return null;
    }
  }

  /// Lấy tất cả focus sessions của user
  Future<List<FocusSession>> getFocusSessions() async {
    try {
      if (!isUserAuthenticated) {
        throw Exception('User not authenticated');
      }

      final response = await _supabase
          .from('focus_sessions')
          .select('*')
          .eq('user_id', _currentUserId!)
          .order('started_at', ascending: false);

      return (response as List)
          .map((sessionData) => FocusSession.fromSupabaseMap(sessionData))
          .toList();
    } catch (e) {
      debugPrint('Error getting focus sessions: $e');
      return [];
    }
  }

  /// Lấy focus sessions theo task ID
  Future<List<FocusSession>> getFocusSessionsByTask(String taskId) async {
    try {
      if (!isUserAuthenticated) {
        throw Exception('User not authenticated');
      }

      final response = await _supabase
          .from('focus_sessions')
          .select('*')
          .eq('user_id', _currentUserId!)
          .eq('task_id', taskId)
          .order('started_at', ascending: false);

      return (response as List)
          .map((sessionData) => FocusSession.fromSupabaseMap(sessionData))
          .toList();
    } catch (e) {
      debugPrint('Error getting focus sessions by task: $e');
      return [];
    }
  }

  /// Xóa focus session
  Future<bool> deleteFocusSession(String sessionId) async {
    try {
      if (!isUserAuthenticated) {
        throw Exception('User not authenticated');
      }

      await _supabase
          .from('focus_sessions')
          .delete()
          .eq('id', sessionId)
          .eq('user_id', _currentUserId!);

      debugPrint('Focus session deleted successfully: $sessionId');
      return true;
    } catch (e) {
      debugPrint('Error deleting focus session: $e');
      return false;
    }
  }

  /// Lấy thống kê focus sessions
  Future<Map<String, dynamic>> getFocusSessionsStatistics() async {
    try {
      if (!isUserAuthenticated) {
        throw Exception('User not authenticated');
      }

      final sessions = await getFocusSessions();
      final completedSessions = sessions.where((s) => s.status == FocusSessionStatus.completed).toList();
      
      final totalSessions = sessions.length;
      final totalCompletedSessions = completedSessions.length;
      final totalFocusMinutes = completedSessions.fold<int>(0, (sum, s) => sum + s.actualDurationMinutes);
      final averageProductivityRating = completedSessions.isNotEmpty 
          ? completedSessions
              .where((s) => s.productivityRating != null)
              .fold<double>(0, (sum, s) => sum + s.productivityRating!) / 
              completedSessions.where((s) => s.productivityRating != null).length
          : 0.0;

      return {
        'total_sessions': totalSessions,
        'completed_sessions': totalCompletedSessions,
        'total_focus_minutes': totalFocusMinutes,
        'average_productivity_rating': averageProductivityRating,
        'completion_rate': totalSessions > 0 ? (totalCompletedSessions / totalSessions * 100) : 0.0,
      };
    } catch (e) {
      debugPrint('Error getting focus sessions statistics: $e');
      return {
        'total_sessions': 0,
        'completed_sessions': 0,
        'total_focus_minutes': 0,
        'average_productivity_rating': 0.0,
        'completion_rate': 0.0,
      };
    }
  }

  // ==================== CATEGORIES OPERATIONS ====================

  /// Lấy tất cả categories của user
  Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      if (!isUserAuthenticated) {
        throw Exception('User not authenticated');
      }

      final response = await _supabase
          .from('categories')
          .select('*')
          .eq('user_id', _currentUserId!)
          .order('created_at', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error getting categories: $e');
      return [];
    }
  }

  /// Tạo category mới
  Future<Map<String, dynamic>?> createCategory({
    required String name,
    required String icon,
    required String color,
  }) async {
    try {
      if (!isUserAuthenticated) {
        throw Exception('User not authenticated');
      }

      final response = await _supabase
          .from('categories')
          .insert({
            'name': name,
            'icon': icon,
            'color': color,
            'user_id': _currentUserId!,
            'created_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      debugPrint('Category created successfully: $name');
      return response;
    } catch (e) {
      debugPrint('Error creating category: $e');
      return null;
    }
  }

  /// Cập nhật category
  Future<Map<String, dynamic>?> updateCategory(
    String categoryId, {
    required String name,
    required String icon,
    required String color,
  }) async {
    try {
      if (!isUserAuthenticated) {
        throw Exception('User not authenticated');
      }

      final response = await _supabase
          .from('categories')
          .update({
            'name': name,
            'icon': icon,
            'color': color,
          })
          .eq('id', categoryId)
          .eq('user_id', _currentUserId!)
          .select()
          .single();

      debugPrint('Category updated successfully: $name');
      return response;
    } catch (e) {
      debugPrint('Error updating category: $e');
      return null;
    }
  }

  /// Xóa category
  Future<bool> deleteCategory(String categoryId) async {
    try {
      if (!isUserAuthenticated) {
        throw Exception('User not authenticated');
      }

      // Xóa category (tasks sẽ có category_id = null do ON DELETE SET NULL)
      await _supabase
          .from('categories')
          .delete()
          .eq('id', categoryId)
          .eq('user_id', _currentUserId!);

      debugPrint('Category deleted successfully: $categoryId');
      return true;
    } catch (e) {
      debugPrint('Error deleting category: $e');
      return false;
    }
  }

  // ==================== REALTIME SUBSCRIPTIONS ====================

  /// Subscribe to tasks changes
  RealtimeChannel subscribeToTasks(Function(List<Task>) onTasksChanged) {
    if (!isUserAuthenticated) {
      throw Exception('User not authenticated');
    }

    return _supabase
        .channel('tasks_channel')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'tasks',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: _currentUserId!,
          ),
          callback: (payload) async {
            debugPrint('Tasks changed: ${payload.eventType}');
            // Reload tasks và notify
            final tasks = await getTasks();
            onTasksChanged(tasks);
          },
        )
        .subscribe();
  }

  /// Subscribe to categories changes
  RealtimeChannel subscribeToCategories(Function(List<Map<String, dynamic>>) onCategoriesChanged) {
    if (!isUserAuthenticated) {
      throw Exception('User not authenticated');
    }

    return _supabase
        .channel('categories_channel')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'categories',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: _currentUserId!,
          ),
          callback: (payload) async {
            debugPrint('Categories changed: ${payload.eventType}');
            // Reload categories và notify
            final categories = await getCategories();
            onCategoriesChanged(categories);
          },
        )
        .subscribe();
  }

  // ==================== STATISTICS ====================

  /// Lấy thống kê tasks
  Future<Map<String, int>> getTasksStatistics() async {
    try {
      if (!isUserAuthenticated) {
        throw Exception('User not authenticated');
      }

      final tasks = await getTasks();
      final completedTasks = tasks.where((task) => task.isCompleted).length;
      final pendingTasks = tasks.length - completedTasks;

      return {
        'total': tasks.length,
        'completed': completedTasks,
        'pending': pendingTasks,
      };
    } catch (e) {
      debugPrint('Error getting tasks statistics: $e');
      return {
        'total': 0,
        'completed': 0,
        'pending': 0,
      };
    }
  }
}