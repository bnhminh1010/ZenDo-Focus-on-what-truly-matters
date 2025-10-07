import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/task.dart';
import '../services/supabase_database_service.dart';

/// Model quản lý trạng thái tasks
/// Sử dụng Provider pattern để quản lý danh sách tasks với Supabase
class TaskModel extends ChangeNotifier {
  final List<Task> _tasks = [];
  final Uuid _uuid = const Uuid();
  final SupabaseDatabaseService _databaseService = SupabaseDatabaseService();
  bool _isLoading = false;
  RealtimeChannel? _tasksSubscription;

  // Getters
  List<Task> get tasks => List.unmodifiable(_tasks);
  bool get isLoading => _isLoading;

  /// Khởi tạo và load tasks từ Supabase
  Future<void> initialize() async {
    await loadTasks();
    _setupRealtimeSubscription();
  }

  /// Load tasks từ Supabase
  Future<void> loadTasks() async {
    _isLoading = true;
    notifyListeners();

    try {
      final tasks = await _databaseService.getTasks();
      _tasks.clear();
      _tasks.addAll(tasks);
    } catch (e) {
      debugPrint('Error loading tasks: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Setup realtime subscription cho tasks
  void _setupRealtimeSubscription() {
    try {
      _tasksSubscription = _databaseService.subscribeToTasks((updatedTasks) {
        _tasks.clear();
        _tasks.addAll(updatedTasks);
        notifyListeners();
      });
    } catch (e) {
      debugPrint('Error setting up realtime subscription: $e');
    }
  }

  /// Cleanup subscription
  void dispose() {
    _tasksSubscription?.unsubscribe();
    super.dispose();
  }

  /// Lấy tasks theo category
  List<Task> getTasksByCategory(TaskCategory category) {
    return _tasks.where((task) => task.category == category).toList();
  }

  /// Lấy tasks theo ngày
  List<Task> getTasksByDate(DateTime date) {
    return _tasks.where((task) {
      if (task.dueDate == null) return false;
      return task.dueDate!.year == date.year &&
          task.dueDate!.month == date.month &&
          task.dueDate!.day == date.day;
    }).toList();
  }

  /// Lấy tasks hoàn thành
  List<Task> get completedTasks {
    return _tasks.where((task) => task.isCompleted).toList();
  }

  /// Lấy tasks chưa hoàn thành
  List<Task> get pendingTasks {
    return _tasks.where((task) => !task.isCompleted).toList();
  }

  /// Thêm task mới
  Future<void> addTask(Task task) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Kiểm tra user authentication trước khi tạo task
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final createdTask = await _databaseService.createTask(task);
      if (createdTask != null) {
        _tasks.add(createdTask);
        debugPrint('TaskModel: Task added successfully - ${createdTask.title}');
      } else {
        throw Exception('Failed to create task');
      }
    } catch (e) {
      debugPrint('TaskModel: Error adding task: $e');
      rethrow; // Re-throw để UI có thể handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Cập nhật task
  Future<void> updateTask(Task updatedTask) async {
    _isLoading = true;
    notifyListeners();

    try {
      final updated = await _databaseService.updateTask(
        updatedTask.id,
        updatedTask,
      );
      if (updated != null) {
        final index = _tasks.indexWhere((task) => task.id == updatedTask.id);
        if (index != -1) {
          _tasks[index] = updated;
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error updating task: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Xóa task
  Future<void> deleteTask(String taskId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _databaseService.deleteTask(taskId);
      if (success) {
        _tasks.removeWhere((task) => task.id == taskId);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error deleting task: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Toggle trạng thái hoàn thành của task
  Future<void> toggleTaskCompletion(String taskId) async {
    try {
      final updatedTask = await _databaseService.toggleTaskComplete(taskId);
      if (updatedTask != null) {
        final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
        if (taskIndex != -1) {
          _tasks[taskIndex] = updatedTask;
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error toggling task completion: $e');
    }
  }

  /// Tạo task mới với thông tin cơ bản
  Task createTask({
    required String title,
    String? description,
    TaskCategory category = TaskCategory.personal,
    TaskPriority priority = TaskPriority.medium,
    DateTime? dueDate,
  }) {
    return Task(
      id: _uuid.v4(),
      title: title,
      description: description,
      category: category,
      priority: priority,
      dueDate: dueDate,
      createdAt: DateTime.now(),
    );
  }
}
