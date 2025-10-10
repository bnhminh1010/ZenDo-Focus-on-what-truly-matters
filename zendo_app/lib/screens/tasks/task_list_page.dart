import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/task.dart';
import '../../providers/task_model.dart';
import '../../widgets/task_list_view.dart';
import '../../widgets/add_task_dialog.dart';

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
                  Tab(text: 'All'),
                  Tab(text: 'Active'),
                  Tab(text: 'Completed'),
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
            tooltip: 'Filter by category',
            onSelected: (TaskCategory? category) {
              setState(() {
                _selectedCategory = category;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem<TaskCategory?>(
                value: null,
                child: Text('All Categories'),
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
                    Text('Mark all complete'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'delete_completed',
                child: Row(
                  children: [
                    Icon(Icons.delete_sweep),
                    SizedBox(width: 8),
                    Text('Delete completed'),
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
                        'No completed tasks',
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
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTaskDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),
    );
  }

  void _showAddTaskDialog() {
    showDialog(context: context, builder: (context) => const AddTaskDialog());
  }

  void _markAllComplete() {
    final taskModel = Provider.of<TaskModel>(context, listen: false);
    final incompleteTasks = taskModel.tasks
        .where((task) => !task.isCompleted)
        .toList();

    if (incompleteTasks.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All tasks are already completed')),
        );
      }
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark All Complete'),
        content: Text(
          'Are you sure you want to mark ${incompleteTasks.length} tasks as complete?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();

              for (final task in incompleteTasks) {
                await taskModel.toggleTaskCompletion(task.id);
              }

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${incompleteTasks.length} tasks marked as complete',
                    ),
                  ),
                );
              }
            },
            child: const Text('Mark Complete'),
          ),
        ],
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
          const SnackBar(content: Text('No completed tasks to delete')),
        );
      }
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Completed Tasks'),
        content: Text(
          'Are you sure you want to delete ${completedTasks.length} completed tasks? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();

              for (final task in completedTasks) {
                await taskModel.deleteTask(task.id);
              }

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${completedTasks.length} completed tasks deleted',
                    ),
                  ),
                );
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
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
