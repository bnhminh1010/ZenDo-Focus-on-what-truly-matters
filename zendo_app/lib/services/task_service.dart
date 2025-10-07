import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/task.dart';

/// Service chuyên xử lý các operations liên quan đến tasks
/// Bao gồm CRUD operations, filtering, sorting và realtime updates
class TaskService extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  List<Task> _tasks = [];
  List<Task> get tasks => _tasks;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  // Getter để lấy user ID hiện tại
  String? get _currentUserId => _supabase.auth.currentUser?.id;

  /// Kiểm tra user đã đăng nhập chưa
  bool get isUserAuthenticated => _currentUserId != null;

  /// Khởi tạo service và load tasks
  Future<void> initialize() async {
    if (!isUserAuthenticated) {
      debugPrint('TaskService: User not authenticated');
      return;
    }

    await loadTasks();
    _setupRealtimeSubscription();
  }

  /// Load tất cả tasks của user
  Future<void> loadTasks() async {
    if (!isUserAuthenticated) {
      _error = 'User not authenticated';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _supabase
          .from('tasks')
          .select('*')
          .eq('user_id', _currentUserId!)
          .order('created_at', ascending: false);

      _tasks = (response as List)
          .map((taskData) => Task.fromSupabaseMap(taskData))
          .toList();

      debugPrint('TaskService: Loaded ${_tasks.length} tasks');
    } catch (e) {
      _error = 'Error loading tasks: $e';
      debugPrint('TaskService: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Tạo task mới
  Future<bool> createTask(Task task) async {
    if (!isUserAuthenticated) {
      _error = 'User not authenticated';
      notifyListeners();
      return false;
    }

    try {
      final taskData = task.toSupabaseMap();
      taskData['user_id'] = _currentUserId!;
      taskData['created_at'] = DateTime.now().toIso8601String();
      taskData['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabase
          .from('tasks')
          .insert(taskData)
          .select()
          .single();

      final newTask = Task.fromSupabaseMap(response);
      _tasks.insert(0, newTask); // Thêm vào đầu list

      debugPrint('TaskService: Task created successfully - ${newTask.title}');
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error creating task: $e';
      debugPrint('TaskService: $_error');
      notifyListeners();
      return false;
    }
  }

  /// Cập nhật task
  Future<bool> updateTask(Task task) async {
    if (!isUserAuthenticated) {
      _error = 'User not authenticated';
      notifyListeners();
      return false;
    }

    try {
      final taskData = task.toSupabaseMap();
      taskData['updated_at'] = DateTime.now().toIso8601String();

      await _supabase
          .from('tasks')
          .update(taskData)
          .eq('id', task.id)
          .eq('user_id', _currentUserId!);

      // Cập nhật trong local list
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = task;
        notifyListeners();
      }

      debugPrint('TaskService: Task updated successfully - ${task.title}');
      return true;
    } catch (e) {
      _error = 'Error updating task: $e';
      debugPrint('TaskService: $_error');
      notifyListeners();
      return false;
    }
  }

  /// Xóa task
  Future<bool> deleteTask(String taskId) async {
    if (!isUserAuthenticated) {
      _error = 'User not authenticated';
      notifyListeners();
      return false;
    }

    try {
      await _supabase
          .from('tasks')
          .delete()
          .eq('id', taskId)
          .eq('user_id', _currentUserId!);

      // Xóa khỏi local list
      _tasks.removeWhere((task) => task.id == taskId);

      debugPrint('TaskService: Task deleted successfully');
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error deleting task: $e';
      debugPrint('TaskService: $_error');
      notifyListeners();
      return false;
    }
  }

  /// Toggle trạng thái completed của task
  Future<bool> toggleTaskCompletion(String taskId) async {
    final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
    if (taskIndex == -1) return false;

    final task = _tasks[taskIndex];
    final updatedTask = task.copyWith(isCompleted: !task.isCompleted);

    return await updateTask(updatedTask);
  }

  /// Lấy tasks theo category
  List<Task> getTasksByCategory(String? categoryId) {
    if (categoryId == null) {
      return _tasks.where((task) => task.categoryId == null).toList();
    }
    return _tasks.where((task) => task.categoryId == categoryId).toList();
  }

  /// Lấy tasks hoàn thành
  List<Task> getCompletedTasks() {
    return _tasks.where((task) => task.isCompleted).toList();
  }

  /// Lấy tasks chưa hoàn thành
  List<Task> getPendingTasks() {
    return _tasks.where((task) => !task.isCompleted).toList();
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

  /// Lấy tasks hôm nay
  List<Task> getTodayTasks() {
    return getTasksByDate(DateTime.now());
  }

  /// Lấy tasks quá hạn
  List<Task> getOverdueTasks() {
    final now = DateTime.now();
    return _tasks.where((task) {
      if (task.dueDate == null || task.isCompleted) return false;
      return task.dueDate!.isBefore(now);
    }).toList();
  }

  /// Lấy tasks theo priority
  List<Task> getTasksByPriority(TaskPriority priority) {
    return _tasks.where((task) => task.priority == priority).toList();
  }

  /// Tìm kiếm tasks
  List<Task> searchTasks(String query) {
    if (query.isEmpty) return _tasks;

    final lowercaseQuery = query.toLowerCase();
    return _tasks.where((task) {
      return task.title.toLowerCase().contains(lowercaseQuery) ||
          (task.description?.toLowerCase().contains(lowercaseQuery) ?? false);
    }).toList();
  }

  /// Sắp xếp tasks
  List<Task> sortTasks(
    List<Task> tasks, {
    required String sortBy, // 'title', 'dueDate', 'priority', 'createdAt'
    required bool ascending,
  }) {
    final sortedTasks = List<Task>.from(tasks);

    switch (sortBy) {
      case 'title':
        sortedTasks.sort(
          (a, b) => ascending
              ? a.title.compareTo(b.title)
              : b.title.compareTo(a.title),
        );
        break;
      case 'dueDate':
        sortedTasks.sort((a, b) {
          if (a.dueDate == null && b.dueDate == null) return 0;
          if (a.dueDate == null) return ascending ? 1 : -1;
          if (b.dueDate == null) return ascending ? -1 : 1;
          return ascending
              ? a.dueDate!.compareTo(b.dueDate!)
              : b.dueDate!.compareTo(a.dueDate!);
        });
        break;
      case 'priority':
        sortedTasks.sort(
          (a, b) => ascending
              ? a.priority.compareTo(b.priority)
              : b.priority.compareTo(a.priority),
        );
        break;
      case 'createdAt':
        sortedTasks.sort(
          (a, b) => ascending
              ? a.createdAt.compareTo(b.createdAt)
              : b.createdAt.compareTo(a.createdAt),
        );
        break;
    }

    return sortedTasks;
  }

  /// Lấy thống kê tasks
  Map<String, int> getTasksStatistics() {
    final total = _tasks.length;
    final completed = _tasks.where((task) => task.isCompleted).length;
    final pending = total - completed;
    final overdue = getOverdueTasks().length;
    final today = getTodayTasks().length;

    return {
      'total': total,
      'completed': completed,
      'pending': pending,
      'overdue': overdue,
      'today': today,
    };
  }

  /// Setup realtime subscription để sync tasks
  void _setupRealtimeSubscription() {
    if (!isUserAuthenticated) return;

    _supabase
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
          callback: (payload) {
            debugPrint('TaskService: Realtime update received');
            loadTasks(); // Reload tasks khi có thay đổi
          },
        )
        .subscribe();
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _supabase.removeAllChannels();
    super.dispose();
  }
}
