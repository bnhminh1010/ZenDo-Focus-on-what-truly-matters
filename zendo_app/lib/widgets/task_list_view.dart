import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../models/task.dart';
import '../providers/task_model.dart';
import 'task_card.dart';

class TaskListView extends StatefulWidget {
  final TaskCategory? filterCategory;
  final bool showCompleted;
  final String? searchQuery;

  const TaskListView({
    super.key,
    this.filterCategory,
    this.showCompleted = true,
    this.searchQuery,
  });

  @override
  State<TaskListView> createState() => _TaskListViewState();
}

class _TaskListViewState extends State<TaskListView> {
  TaskSortBy _sortBy = TaskSortBy.dueDate;
  bool _sortAscending = true;

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskModel>(
      builder: (context, taskModel, child) {
        List<Task> tasks = _getFilteredTasks(taskModel);

        if (tasks.isEmpty) {
          return _buildEmptyState();
        }

        return Column(
          children: [
            // Sort controls
            _buildSortControls(),

            // Task list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 8, bottom: 80),
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return TaskCard(
                    task: task,
                    onTap: () => _navigateToTaskDetail(context, task),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  List<Task> _getFilteredTasks(TaskModel taskModel) {
    List<Task> tasks = taskModel.tasks;

    // Filter by category
    if (widget.filterCategory != null) {
      tasks = tasks
          .where((task) => task.category == widget.filterCategory)
          .toList();
    }

    // Filter by completion status
    if (!widget.showCompleted) {
      tasks = tasks.where((task) => !task.isCompleted).toList();
    }

    // Filter by search query
    if (widget.searchQuery != null && widget.searchQuery!.isNotEmpty) {
      final query = widget.searchQuery!.toLowerCase();
      tasks = tasks.where((task) {
        return task.title.toLowerCase().contains(query) ||
            (task.description?.toLowerCase().contains(query) ?? false) ||
            (task.notes?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // Tách task hoàn thành và chưa hoàn thành
    List<Task> incompleteTasks = tasks.where((task) => !task.isCompleted).toList();
    List<Task> completedTasks = tasks.where((task) => task.isCompleted).toList();

    // Sort incomplete tasks
    incompleteTasks.sort((a, b) {
      int comparison = 0;

      switch (_sortBy) {
        case TaskSortBy.title:
          comparison = a.title.compareTo(b.title);
          break;
        case TaskSortBy.dueDate:
          if (a.dueDate == null && b.dueDate == null) {
            comparison = 0;
          } else if (a.dueDate == null) {
            comparison = 1; // Tasks without due date go to the end
          } else if (b.dueDate == null) {
            comparison = -1;
          } else {
            comparison = a.dueDate!.compareTo(b.dueDate!);
          }
          break;
        case TaskSortBy.priority:
          comparison = b.priority.index.compareTo(
            a.priority.index,
          ); // High priority first
          break;
        case TaskSortBy.category:
          comparison = a.category.name.compareTo(b.category.name);
          break;
        case TaskSortBy.createdAt:
          comparison = a.createdAt.compareTo(b.createdAt);
          break;
      }

      return _sortAscending ? comparison : -comparison;
    });

    // Sort completed tasks
    completedTasks.sort((a, b) {
      int comparison = 0;

      switch (_sortBy) {
        case TaskSortBy.title:
          comparison = a.title.compareTo(b.title);
          break;
        case TaskSortBy.dueDate:
          if (a.dueDate == null && b.dueDate == null) {
            comparison = 0;
          } else if (a.dueDate == null) {
            comparison = 1; // Tasks without due date go to the end
          } else if (b.dueDate == null) {
            comparison = -1;
          } else {
            comparison = a.dueDate!.compareTo(b.dueDate!);
          }
          break;
        case TaskSortBy.priority:
          comparison = b.priority.index.compareTo(
            a.priority.index,
          ); // High priority first
          break;
        case TaskSortBy.category:
          comparison = a.category.name.compareTo(b.category.name);
          break;
        case TaskSortBy.createdAt:
          comparison = a.createdAt.compareTo(b.createdAt);
          break;
      }

      return _sortAscending ? comparison : -comparison;
    });

    // Kết hợp: task chưa hoàn thành trước, task hoàn thành sau
    return [...incompleteTasks, ...completedTasks];
  }

  Widget _buildSortControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text('Sort by:', style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(width: 8),

          // Sort dropdown
          DropdownButton<TaskSortBy>(
            value: _sortBy,
            onChanged: (TaskSortBy? newValue) {
              if (newValue != null) {
                setState(() {
                  _sortBy = newValue;
                });
              }
            },
            items: TaskSortBy.values.map((TaskSortBy sortBy) {
              return DropdownMenuItem<TaskSortBy>(
                value: sortBy,
                child: Text(_getSortByDisplayName(sortBy)),
              );
            }).toList(),
          ),

          const SizedBox(width: 8),

          // Sort direction button
          IconButton(
            onPressed: () {
              setState(() {
                _sortAscending = !_sortAscending;
              });
            },
            icon: Icon(
              _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
            ),
            tooltip: _sortAscending ? 'Ascending' : 'Descending',
          ),

          const Spacer(),

          // Task count
          Consumer<TaskModel>(
            builder: (context, taskModel, child) {
              final filteredCount = _getFilteredTasks(taskModel).length;
              final totalCount = taskModel.tasks.length;
              return Text(
                '$filteredCount of $totalCount tasks',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.task_alt,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No tasks found',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.searchQuery != null && widget.searchQuery!.isNotEmpty
                ? 'Try adjusting your search terms'
                : 'Create your first task to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getSortByDisplayName(TaskSortBy sortBy) {
    switch (sortBy) {
      case TaskSortBy.title:
        return 'Title';
      case TaskSortBy.dueDate:
        return 'Due Date';
      case TaskSortBy.priority:
        return 'Priority';
      case TaskSortBy.category:
        return 'Category';
      case TaskSortBy.createdAt:
        return 'Created';
    }
  }

  void _navigateToTaskDetail(BuildContext context, Task task) {
    context.pushNamed(
      'taskDetail',
      pathParameters: {'taskId': task.id},
      extra: task,
    );
  }
}

enum TaskSortBy { title, dueDate, priority, category, createdAt }
