import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/task.dart';
import '../../providers/task_model.dart';
import '../../widgets/add_task_dialog.dart';
import '../../widgets/subtask_list_widget.dart';
import '../ai/ai_chat_page.dart';

/// Trang hiển thị chi tiết task với đầy đủ thông tin và actions
class TaskDetailPage extends StatefulWidget {
  final Task task;

  const TaskDetailPage({
    super.key,
    required this.task,
  });

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  late Task _currentTask;

  @override
  void initState() {
    super.initState();
    _currentTask = widget.task;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentTask.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          // Edit button
          IconButton(
            onPressed: () => _editTask(),
            icon: const Icon(Icons.edit),
            tooltip: 'Chỉnh sửa',
          ),
          // Delete button
          IconButton(
            onPressed: () => _deleteTask(),
            icon: const Icon(Icons.delete),
            tooltip: 'Xóa',
          ),
          // More options
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'duplicate':
                  _duplicateTask();
                  break;
                case 'share':
                  _shareTask();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'duplicate',
                child: Row(
                  children: [
                    Icon(Icons.copy),
                    SizedBox(width: 8),
                    Text('Nhân bản'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share),
                    SizedBox(width: 8),
                    Text('Chia sẻ'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Task completion status
            _buildCompletionCard(),
            const SizedBox(height: 16),

            // Task image (if exists)
            if (_currentTask.imageUrl?.isNotEmpty == true)
              _buildImageSection(),

            // Task details
            _buildDetailsCard(),
            const SizedBox(height: 16),

            // Subtasks section
            if (!_currentTask.isSubtask)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SubtaskListWidget(taskId: _currentTask.id),
                ),
              ),
            const SizedBox(height: 16),

            // Task metadata
            _buildMetadataCard(),
            const SizedBox(height: 16),

            // Task notes (if exists)
            if (_currentTask.notes?.isNotEmpty == true)
              _buildNotesCard(),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // AI Chat FAB
          FloatingActionButton(
            heroTag: "ai_chat",
            onPressed: () => _openAIChat(),
            backgroundColor: Colors.blue.shade600,
            tooltip: 'Chat với AI Assistant',
            child: const Icon(
              Icons.smart_toy,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          // Task completion FAB
          FloatingActionButton(
            heroTag: "task_completion",
            onPressed: () => _toggleCompletion(),
            backgroundColor: _currentTask.isCompleted ? Colors.green : Colors.orange.shade600,
            tooltip: _currentTask.isCompleted ? 'Đánh dấu chưa hoàn thành' : 'Đánh dấu hoàn thành',
            child: Icon(
              _currentTask.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              _currentTask.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
              color: _currentTask.isCompleted 
                  ? Colors.green 
                  : Theme.of(context).colorScheme.outline,
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _currentTask.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      decoration: _currentTask.isCompleted 
                          ? TextDecoration.lineThrough 
                          : null,
                      color: _currentTask.isCompleted 
                          ? Theme.of(context).colorScheme.outline 
                          : null,
                    ),
                  ),
                  if (_currentTask.isCompleted && _currentTask.completedAt != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Hoàn thành: ${_formatDateTime(_currentTask.completedAt!)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.green,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hình ảnh',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _currentTask.imageUrl!.startsWith('http')
                  ? Image.network(
                      _currentTask.imageUrl!,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.broken_image,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                size: 48,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Không thể tải hình ảnh',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    )
                  : Image.asset(
                      _currentTask.imageUrl!,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.broken_image,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                size: 48,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Không thể tải hình ảnh',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chi tiết',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Description
            if (_currentTask.description?.isNotEmpty == true) ...[
              _buildDetailRow(
                icon: Icons.description,
                label: 'Mô tả',
                value: _currentTask.description!,
              ),
              const SizedBox(height: 12),
            ],

            // Category
            _buildDetailRow(
              icon: Icons.category,
              label: 'Danh mục',
              value: _currentTask.category.displayName,
              valueColor: _getCategoryColor(_currentTask.category),
            ),
            const SizedBox(height: 12),

            // Priority
            _buildDetailRow(
              icon: Icons.flag,
              label: 'Độ ưu tiên',
              value: _currentTask.priority.displayName,
              valueColor: _getPriorityColor(_currentTask.priority),
            ),
            const SizedBox(height: 12),

            // Due date
            if (_currentTask.dueDate != null) ...[
              _buildDetailRow(
                icon: Icons.schedule,
                label: 'Hạn hoàn thành',
                value: _formatDate(_currentTask.dueDate!),
                valueColor: _getDueDateColor(_currentTask.dueDate!),
              ),
              const SizedBox(height: 12),
            ],

            // Time estimates
            if (_currentTask.estimatedMinutes > 0) ...[
              _buildDetailRow(
                icon: Icons.timer,
                label: 'Thời gian dự kiến',
                value: '${_currentTask.estimatedMinutes} phút',
              ),
              const SizedBox(height: 12),
            ],

            if (_currentTask.actualMinutes > 0) ...[
              _buildDetailRow(
                icon: Icons.timer_outlined,
                label: 'Thời gian thực tế',
                value: '${_currentTask.actualMinutes} phút',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetadataCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thông tin khác',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            _buildDetailRow(
              icon: Icons.add_circle_outline,
              label: 'Ngày tạo',
              value: _formatDateTime(_currentTask.createdAt),
            ),
            const SizedBox(height: 12),

            // Tags (if any)
            if (_currentTask.tags.isNotEmpty) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.label,
                    size: 20,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tags',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: _currentTask.tags.map((tag) => Chip(
                            label: Text(tag),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          )).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNotesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ghi chú',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _currentTask.notes!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: valueColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper methods
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Color _getCategoryColor(TaskCategory category) {
    switch (category) {
      case TaskCategory.work:
        return Colors.blue;
      case TaskCategory.personal:
        return Colors.green;
      case TaskCategory.learning:
        return Colors.orange;
      case TaskCategory.health:
        return Colors.red;
      case TaskCategory.finance:
        return Colors.purple;
      case TaskCategory.social:
        return Colors.pink;
      case TaskCategory.other:
        return Colors.grey;
    }
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return Colors.green;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.high:
        return Colors.red;
      case TaskPriority.urgent:
        return Colors.deepOrange;
    }
  }

  Color _getDueDateColor(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now).inDays;
    
    if (difference < 0) {
      return Colors.red; // Overdue
    } else if (difference == 0) {
      return Colors.orange; // Due today
    } else if (difference <= 3) {
      return Colors.amber; // Due soon
    } else {
      return Theme.of(context).colorScheme.onSurface; // Normal
    }
  }

  // Action methods
  void _toggleCompletion() async {
    final taskModel = Provider.of<TaskModel>(context, listen: false);
    await taskModel.toggleTaskCompletion(_currentTask.id);
    
    // Reload task from provider to get updated state
    final updatedTask = taskModel.tasks.firstWhere(
      (task) => task.id == _currentTask.id,
      orElse: () => _currentTask,
    );
    
    setState(() {
      _currentTask = updatedTask;
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _currentTask.isCompleted 
                ? 'Đã đánh dấu hoàn thành' 
                : 'Đã đánh dấu chưa hoàn thành',
          ),
        ),
      );
    }
  }

  void _editTask() async {
    final result = await showDialog<Task>(
      context: context,
      builder: (context) => AddTaskDialog(editingTask: _currentTask),
    );

    if (result != null) {
      setState(() {
        _currentTask = result;
      });
    }
  }

  Future<void> _deleteTask() async {
    try {
      await TaskModel().deleteTask(widget.task.id);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting task: $e')),
        );
      }
    }
  }

  void _duplicateTask() async {
    final taskModel = Provider.of<TaskModel>(context, listen: false);
    final duplicatedTask = _currentTask.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: '${_currentTask.title} (Copy)',
      isCompleted: false,
      completedAt: null,
      createdAt: DateTime.now(),
    );

    try {
      await taskModel.addTask(duplicatedTask);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã nhân bản task thành công')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi nhân bản task: $e')),
        );
      }
    }
  }

  void _shareTask() {
    // TODO: Implement share functionality
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tính năng chia sẻ sẽ được phát triển sau')),
      );
    }
  }

  void _openAIChat() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AIChatPage(
          extra: {
            'initialTask': _currentTask,
          },
        ),
      ),
    );
  }

}