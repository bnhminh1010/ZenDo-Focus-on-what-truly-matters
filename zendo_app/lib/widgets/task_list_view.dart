import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../models/task.dart';
import '../providers/task_model.dart';
import 'task_card.dart';
import 'skeleton_loader.dart';
import 'haptic_feedback_widget.dart';
import 'enhanced_empty_state_widget.dart';

class TaskListView extends StatefulWidget {
  final TaskCategory? filterCategory;
  final bool showCompleted;
  final String? searchQuery;
  final Function(String)? onSearchChanged;

  const TaskListView({
    super.key,
    this.filterCategory,
    this.showCompleted = true,
    this.searchQuery,
    this.onSearchChanged,
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
        // Show skeleton loading while tasks are loading
        if (taskModel.isLoading) {
          return const TaskListSkeleton();
        }

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
    List<Task> incompleteTasks = tasks
        .where((task) => !task.isCompleted)
        .toList();
    List<Task> completedTasks = tasks
        .where((task) => task.isCompleted)
        .toList();

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
          HapticIconButton(
            onPressed: () {
              setState(() {
                _sortAscending = !_sortAscending;
              });
            },
            icon: _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
            feedbackType: HapticFeedbackType.selection,
          ),

          const Spacer(),

          // Task count
          Consumer<TaskModel>(
            builder: (context, taskModel, child) {
              final filteredCount = _getFilteredTasks(taskModel).length;
              final totalCount = taskModel.tasks.length;
              return Text(
                '$filteredCount trong tổng số $totalCount task',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    if (widget.searchQuery != null && widget.searchQuery!.isNotEmpty) {
      return SearchEmptyState(
        searchQuery: widget.searchQuery!,
        onClearSearch: () {
          // Callback để clear search
          if (widget.onSearchChanged != null) {
            widget.onSearchChanged!('');
          }
        },
      );
    }

    return TaskListEmptyState(
      onAddTask: () {
        // Callback để add task - có thể trigger từ parent widget
        // Hoặc show dialog trực tiếp
      },
    );
  }

  String _getSortByDisplayName(TaskSortBy sortBy) {
    switch (sortBy) {
      case TaskSortBy.title:
        return 'Tiêu đề';
      case TaskSortBy.dueDate:
        return 'Ngày hạn';
      case TaskSortBy.priority:
        return 'Độ ưu tiên';
      case TaskSortBy.category:
        return 'Danh mục';
      case TaskSortBy.createdAt:
        return 'Ngày tạo';
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

