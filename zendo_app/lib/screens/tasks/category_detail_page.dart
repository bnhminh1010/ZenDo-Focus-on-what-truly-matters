/*
 * Tên: screens/tasks/category_detail_page.dart
 * Tác dụng: Màn hình chi tiết category hiển thị các task thuộc category đó với filter và sort
 * Khi nào dùng: Người dùng muốn xem tất cả tasks trong một category cụ thể
 */

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/task.dart';
import '../../providers/task_model.dart';
import '../../widgets/glass_button.dart';

/// Trang chi tiết category hiển thị các task trong category đó
class CategoryDetailPage extends StatelessWidget {
  final String categoryName;
  final IconData categoryIcon;
  final Color categoryColor;
  final TaskCategory category;

  const CategoryDetailPage({
    super.key,
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryColor,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(categoryName),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GlassIconButton(
          icon: Icons.arrow_back_ios,
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // TODO: Hiển thị menu options
            },
          ),
        ],
      ),
      body: Consumer<TaskModel>(
        builder: (context, taskModel, child) {
          // Lọc tasks theo category
          final categoryTasks = taskModel?.getTasksByCategory(category) ?? [];

          return Column(
            children: [
              // Header với thống kê
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: categoryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: categoryColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: categoryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(categoryIcon, color: categoryColor, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            categoryName,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${categoryTasks.length} công việc',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Danh sách tasks
              Expanded(
                child: categoryTasks.isEmpty
                    ? _buildEmptyState(context)
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: categoryTasks.length,
                        itemBuilder: (context, index) {
                          final task = categoryTasks[index];
                          return _buildTaskItem(context, task, taskModel);
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAIChat(context),
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Image.asset(
          'assets/icons/bot.png',
          width: 28,
          height: 28,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
        tooltip: 'BilyBily AI Assistant',
      ),
    );
  }

  /// Widget hiển thị khi không có task nào
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            categoryIcon,
            size: 64,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withOpacity(0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'Chưa có công việc nào',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Thêm công việc đầu tiên cho $categoryName',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          GlassElevatedButton.icon(
            onPressed: () => _openAIChat(context),
            icon: Image.asset(
              'assets/icons/bot.png',
              width: 20,
              height: 20,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            label: const Text('Tạo với AI'),
          ),
        ],
      ),
    );
  }

  /// Widget hiển thị từng task item
  Widget _buildTaskItem(
    BuildContext context,
    dynamic task,
    TaskModel taskModel,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        onTap: () {
          // Navigate to task detail page
          context.pushNamed(
            'taskDetail',
            pathParameters: {'taskId': task.id},
            extra: task,
          );
        },
        leading: GestureDetector(
          onTap: () {
            // Toggle task completion
            taskModel.toggleTaskCompletion(task.id);
          },
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: categoryColor, width: 2),
              color: task.isCompleted ? categoryColor : Colors.transparent,
            ),
            child: task.isCompleted
                ? Icon(
                    Icons.check,
                    size: 16,
                    color: Theme.of(context).colorScheme.onPrimary,
                  )
                : null,
          ),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            color: task.isCompleted
                ? Theme.of(context).colorScheme.onSurface.withOpacity(0.5)
                : null,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: task.description?.isNotEmpty == true
            ? Text(
                task.description!,
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (task.priority != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getPriorityColor(
                    context,
                    task.priority,
                  ).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getPriorityText(task.priority),
                  style: TextStyle(
                    color: _getPriorityColor(context, task.priority),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            const SizedBox(width: 8),
            PopupMenuButton(
              icon: const Icon(Icons.more_vert, size: 20),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 18),
                      SizedBox(width: 8),
                      Text('Chỉnh sửa'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 18, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Xóa', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'edit') {
                  // Navigate to task detail for editing
                  context.pop();
                  context.pushNamed(
                    'taskDetail',
                    pathParameters: {'taskId': task.id},
                  );
                  context.pop();
                  // Thêm task và hiển thị kết quả
                } else if (value == 'delete') {
                  // Delete task
                  taskModel.deleteTask(task.id);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Lấy màu theo độ ưu tiên
  Color _getPriorityColor(BuildContext context, TaskPriority? priority) {
    if (priority == null)
      return Theme.of(context).colorScheme.onSurface.withOpacity(0.5);
    switch (priority) {
      case TaskPriority.high:
        return Colors.red;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.low:
        return Colors.green;
      case TaskPriority.urgent:
        return Theme.of(context).colorScheme.error;
    }
  }

  /// Lấy text theo độ ưu tiên
  String _getPriorityText(TaskPriority? priority) {
    if (priority == null) return '';
    return priority.displayName;
  }

  /// Mở AI Chat với context của category
  void _openAIChat(BuildContext context) {
    final initialMessage =
        '''Tôi muốn tạo task mới cho category "$categoryName". 
Hãy hỏi tôi các thông tin cần thiết để tạo một task hoàn chỉnh:
- Tiêu đề task
- Mô tả chi tiết
- Độ ưu tiên (thấp, trung bình, cao, khẩn cấp)
- Thời gian ước tính hoàn thành
- Ngày hạn (nếu có)
- Ghi chú bổ sung (nếu có)

Category hiện tại: $categoryName
Icon: ${categoryIcon.codePoint}
Màu sắc: ${categoryColor.toARGB32()}''';

    context.push(
      '/ai-chat',
      extra: {
        'categoryContext': {
          'name': categoryName,
          'icon': categoryIcon,
          'color': categoryColor,
          'category': category,
        },
        'initialMessage': initialMessage,
      },
    );
  }
}

