/*
 * Tên: screens/tasks/task_list_page.dart
 * Tác dụng: Màn hình danh sách tasks với filter, sort và haptic feedback
 * Khi nào dùng: Người dùng muốn xem tổng quan tất cả tasks với các tùy chọn lọc
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../models/task.dart';
import '../../providers/task_model.dart';
import '../../widgets/task_list_view.dart';
import '../../widgets/haptic_feedback_widget.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/glass_button.dart';

class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  TaskCategory? _selectedCategory;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Lấy search parameter từ URL nếu có
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uri = GoRouterState.of(context).uri;
      final searchQuery = uri.queryParameters['search'];
      if (searchQuery != null && searchQuery.isNotEmpty) {
        _searchController.text = searchQuery;
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search tasks...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                  ),
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
              ),

              // Filter tabs
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Tất cả'),
                  Tab(text: 'Đang thực hiện'),
                  Tab(text: 'Hoàn thành'),
                ],
                onTap: (index) {
                  setState(() {
                    switch (index) {
                      case 0:
                        // Show all tasks
                        break;
                      case 1:
                        // Show pending tasks
                        break;
                      case 2:
                        // Show completed tasks
                        break;
                    }
                  });
                },
              ),
            ],
          ),
        ),
        actions: [
          // Category filter
          PopupMenuButton<TaskCategory?>(
            icon: Icon(
              Icons.filter_list,
              color: _selectedCategory != null
                  ? Theme.of(context).colorScheme.primary
                  : null,
            ),
            tooltip: 'Lọc theo danh mục',
            onSelected: (TaskCategory? category) {
              setState(() {
                _selectedCategory = category;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem<TaskCategory?>(
                value: null,
                child: Text('Tất cả danh mục'),
              ),
              ...TaskCategory.values.map(
                (category) => PopupMenuItem<TaskCategory?>(
                  value: category,
                  child: Row(
                    children: [
                      Icon(
                        _getCategoryIcon(category),
                        size: 20,
                        color: _getCategoryColor(category),
                      ),
                      const SizedBox(width: 8),
                      Text(category.name),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // More options
          PopupMenuButton<String>(
            onSelected: (String value) {
              switch (value) {
                case 'mark_all_complete':
                  _markAllComplete();
                  break;
                case 'delete_completed':
                  _deleteCompleted();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'mark_all_complete',
                child: Row(
                  children: [
                    Icon(Icons.done_all),
                    SizedBox(width: 8),
                    Text('Đánh dấu tất cả hoàn thành'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'delete_completed',
                child: Row(
                  children: [
                    Icon(Icons.delete_sweep),
                    SizedBox(width: 8),
                    Text('Xóa các task đã hoàn thành'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // All tasks
          TaskListView(
            filterCategory: _selectedCategory,
            showCompleted: true,
            searchQuery: _searchController.text,
            onSearchChanged: (query) {
              setState(() {
                _searchController.text = query;
              });
            },
          ),

          // Active tasks only
          Consumer<TaskModel>(
            builder: (context, taskModel, child) {
              final activeTasks = taskModel.tasks
                  .where((task) => !task.isCompleted)
                  .toList();
              if (_selectedCategory != null) {
                activeTasks.removeWhere(
                  (task) => task.category != _selectedCategory,
                );
              }

              return TaskListView(
                filterCategory: _selectedCategory,
                showCompleted: false,
                searchQuery: _searchController.text,
                onSearchChanged: (query) {
                  setState(() {
                    _searchController.text = query;
                  });
                },
              );
            },
          ),

          // Completed tasks only
          Consumer<TaskModel>(
            builder: (context, taskModel, child) {
              final completedTasks = taskModel.tasks
                  .where((task) => task.isCompleted)
                  .toList();
              if (_selectedCategory != null) {
                completedTasks.removeWhere(
                  (task) => task.category != _selectedCategory,
                );
              }

              if (completedTasks.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.task_alt, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Không có task nào đã hoàn thành',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return TaskListView(
                filterCategory: _selectedCategory,
                showCompleted: true,
                searchQuery: _searchController.text,
                onSearchChanged: (query) {
                  setState(() {
                    _searchController.text = query;
                  });
                },
              );
            },
          ),
        ],
      ),
      floatingActionButton: HapticFloatingActionButton(
        onPressed: () => context.push('/ai-chat'),
        feedbackType: HapticFeedbackType.medium,
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Image.asset(
          'assets/icons/bot.png',
          width: 28,
          height: 28,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  void _markAllComplete() {
    final taskModel = Provider.of<TaskModel>(context, listen: false);
    final incompleteTasks = taskModel.tasks
        .where((task) => !task.isCompleted)
        .toList();

    if (incompleteTasks.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tất cả task đã được hoàn thành')),
        );
      }
      return;
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          borderRadius: 24,
          blur: 20,
          opacity: 0.15,
          padding: const EdgeInsets.all(32),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Header with icon
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text('✅', style: TextStyle(fontSize: 32)),
                  ),
                ),

                const SizedBox(height: 20),

                // Title
                Text(
                  'Đánh dấu tất cả hoàn thành',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                // Message
                Text(
                  'Bạn có chắc chắn muốn đánh dấu ${incompleteTasks.length} task là hoàn thành?',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 24),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: Semantics(
                        label: 'Hủy thao tác',
                        hint: 'Nhấn để hủy đánh dấu hoàn thành',
                        child: GlassOutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Hủy'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Semantics(
                        label: 'Xác nhận đánh dấu hoàn thành',
                        hint:
                            'Nhấn để đánh dấu ${incompleteTasks.length} task hoàn thành',
                        child: GlassElevatedButton(
                          onPressed: () async {
                            Navigator.of(context).pop();

                            for (final task in incompleteTasks) {
                              await taskModel.toggleTaskCompletion(task.id);
                            }

                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${incompleteTasks.length} task đã được đánh dấu hoàn thành',
                                  ),
                                ),
                              );
                            }
                          },
                          child: const Text('Đánh dấu hoàn thành'),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _deleteCompleted() {
    final taskModel = Provider.of<TaskModel>(context, listen: false);
    final completedTasks = taskModel.tasks
        .where((task) => task.isCompleted)
        .toList();

    if (completedTasks.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không có task nào đã hoàn thành để xóa'),
          ),
        );
      }
      return;
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          borderRadius: 24,
          blur: 20,
          opacity: 0.15,
          padding: const EdgeInsets.all(32),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Header with icon
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text('🗑️', style: TextStyle(fontSize: 32)),
                  ),
                ),

                const SizedBox(height: 20),

                // Title
                Text(
                  'Xóa các Task đã hoàn thành',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                // Message
                Text(
                  'Bạn có chắc chắn muốn xóa ${completedTasks.length} task đã hoàn thành? Hành động này không thể hoàn tác.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 24),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: Semantics(
                        label: 'Hủy thao tác',
                        hint: 'Nhấn để hủy xóa task',
                        child: GlassOutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Hủy'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Semantics(
                        label: 'Xác nhận xóa task',
                        hint:
                            'Nhấn để xóa ${completedTasks.length} task đã hoàn thành',
                        child: GlassElevatedButton(
                          onPressed: () async {
                            Navigator.of(context).pop();

                            for (final task in completedTasks) {
                              await taskModel.deleteTask(task.id);
                            }

                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${completedTasks.length} task đã hoàn thành đã được xóa',
                                  ),
                                ),
                              );
                            }
                          },
                          child: const Text('Xóa'),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(TaskCategory category) {
    switch (category) {
      case TaskCategory.work:
        return Icons.work;
      case TaskCategory.personal:
        return Icons.person;
      case TaskCategory.learning:
        return Icons.school;
      case TaskCategory.health:
        return Icons.favorite;
      case TaskCategory.finance:
        return Icons.attach_money;
      case TaskCategory.social:
        return Icons.people;
      case TaskCategory.other:
        return Icons.category;
    }
  }

  Color _getCategoryColor(TaskCategory category) {
    switch (category) {
      case TaskCategory.work:
        return Colors.blue;
      case TaskCategory.personal:
        return Colors.green;
      case TaskCategory.learning:
        return Colors.purple;
      case TaskCategory.health:
        return Colors.red;
      case TaskCategory.finance:
        return Colors.orange;
      case TaskCategory.social:
        return Colors.pink;
      case TaskCategory.other:
        return Colors.grey;
    }
  }
}
