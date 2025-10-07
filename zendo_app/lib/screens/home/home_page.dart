import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../providers/task_model.dart';
import '../../providers/auth_model.dart';
import '../../models/task.dart';
import '../../theme.dart';
import '../../widgets/add_task_dialog.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Khởi tạo TaskModel để load tasks từ database
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskModel>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          'ZenDo - Trang chủ',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Tìm kiếm nhiệm vụ...',
                          hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Create buttons section (moved to top for better UX)
              _buildCreateButtons(),
              const SizedBox(height: 32),
              
              // Categories Grid
              Text(
                'Danh mục nhiệm vụ',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              _buildCategoriesGrid(),
              const SizedBox(height: 32),
              
              // Recent Tasks Section
              _buildRecentTasksSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesGrid() {
    return Consumer<TaskModel>(
      builder: (context, taskModel, child) {
        final categories = [
          {
            'name': 'Work',
            'icon': Icons.work_outline,
            'color': AppTheme.workColor,
            'taskCount': taskModel.getTasksByCategory(TaskCategory.work).length,
          },
          {
            'name': 'Family',
            'icon': Icons.family_restroom,
            'color': AppTheme.familyColor,
            'taskCount': taskModel.getTasksByCategory(TaskCategory.learning).length,
          },
          {
            'name': 'Healthy',
            'icon': Icons.favorite_outline,
            'color': AppTheme.healthColor,
            'taskCount': taskModel.getTasksByCategory(TaskCategory.health).length,
          },
          {
            'name': 'Personal',
            'icon': Icons.person_outline,
            'color': AppTheme.personalColor,
            'taskCount': taskModel.getTasksByCategory(TaskCategory.personal).length,
          },
        ];

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
          children: categories.map((category) {
            return GestureDetector(
              onTap: () {
                // Navigate to category detail page
                context.pushNamed(
                  'categoryDetail',
                  pathParameters: {'categoryName': category['name'] as String},
                  extra: {
                    'icon': category['icon'] as IconData,
                    'color': category['color'] as Color,
                  },
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: (category['color'] as Color).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          category['icon'] as IconData,
                          color: category['color'] as Color,
                          size: 24,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        category['name'] as String,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${category['taskCount']} Tasks',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildRecentTasksSection() {
    return Consumer<TaskModel>(
      builder: (context, taskModel, child) {
        final recentTasks = taskModel.tasks.take(5).toList(); // Lấy 5 task gần đây nhất
        
        if (recentTasks.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.task_alt,
                  size: 48,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'Chưa có nhiệm vụ nào',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tạo nhiệm vụ đầu tiên của bạn!',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Nhiệm vụ gần đây',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // TODO: Navigate to all tasks page
                  },
                  child: const Text('Xem tất cả'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recentTasks.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final task = recentTasks[index];
                return _buildTaskCard(task);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildCreateButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Create Task Button
        ElevatedButton.icon(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => const AddTaskDialog(),
            );
          },
          icon: const Icon(Icons.add),
          label: const Text('Tạo Task'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Ask AI Button
        ElevatedButton.icon(
          onPressed: () {
            // TODO: Implement AI chat functionality
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tính năng AI đang được phát triển')),
            );
          },
          icon: const Icon(Icons.psychology),
          label: const Text('Hỏi AI'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.secondary,
            foregroundColor: Theme.of(context).colorScheme.onSecondary,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTaskCard(Task task) {
    Color priorityColor;
    switch (task.priority) {
      case TaskPriority.high:
        priorityColor = Colors.red;
        break;
      case TaskPriority.medium:
        priorityColor = Colors.orange;
        break;
      case TaskPriority.low:
        priorityColor = Colors.green;
        break;
      case TaskPriority.urgent:
        priorityColor = Colors.purple;
        break;
    }

    Color categoryColor;
    switch (task.category) {
      case TaskCategory.work:
        categoryColor = AppTheme.workColor;
        break;
      case TaskCategory.learning:
        categoryColor = AppTheme.familyColor;
        break;
      case TaskCategory.health:
        categoryColor = AppTheme.healthColor;
        break;
      case TaskCategory.personal:
        categoryColor = AppTheme.personalColor;
        break;
      case TaskCategory.finance:
        categoryColor = AppTheme.workColor; // Sử dụng màu work thay thế
        break;
      case TaskCategory.social:
        categoryColor = AppTheme.personalColor; // Sử dụng màu personal thay thế
        break;
      case TaskCategory.other:
        categoryColor = AppTheme.grey500; // Sử dụng màu grey thay thế
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: priorityColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  task.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
              Checkbox(
                value: task.isCompleted,
                onChanged: (value) {
                  context.read<TaskModel>().toggleTaskCompletion(task.id);
                },
              ),
            ],
          ),
          if (task.description != null && task.description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              task.description!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: categoryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  task.category.name.toUpperCase(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: categoryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              if (task.dueDate != null)
                Text(
                  DateFormat('dd/MM/yyyy').format(task.dueDate!),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}