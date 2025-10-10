import 'package:flutter/material.dart';
import '../models/subtask.dart';
import '../services/subtask_service.dart';

/// Widget hiển thị danh sách subtasks của một task
class SubtaskListWidget extends StatefulWidget {
  final String taskId;
  final bool isEditable;
  final Function(List<Subtask>)? onSubtasksChanged;

  const SubtaskListWidget({
    super.key,
    required this.taskId,
    this.isEditable = true,
    this.onSubtasksChanged,
  });

  @override
  State<SubtaskListWidget> createState() => _SubtaskListWidgetState();
}

class _SubtaskListWidgetState extends State<SubtaskListWidget> {
  final SubtaskService _subtaskService = SubtaskService();
  List<Subtask> _subtasks = [];
  bool _isLoading = true;
  final TextEditingController _newSubtaskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSubtasks();
  }

  @override
  void dispose() {
    _newSubtaskController.dispose();
    super.dispose();
  }

  Future<void> _loadSubtasks() async {
    try {
      setState(() => _isLoading = true);
      final subtasks = await _subtaskService.getSubtasksByTaskId(widget.taskId);
      setState(() {
        _subtasks = subtasks;
        _isLoading = false;
      });
      widget.onSubtasksChanged?.call(_subtasks);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi tải subtasks: $e')),
        );
      }
    }
  }

  Future<void> _addSubtask() async {
    final title = _newSubtaskController.text.trim();
    if (title.isEmpty) return;

    try {
      final newSubtask = await _subtaskService.createSubtask(
        taskId: widget.taskId,
        title: title,
        sortOrder: _subtasks.length,
      );

      setState(() {
        _subtasks.add(newSubtask);
        _newSubtaskController.clear();
      });
      widget.onSubtasksChanged?.call(_subtasks);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi thêm subtask: $e')),
        );
      }
    }
  }

  Future<void> _toggleSubtask(String subtaskId) async {
    try {
      final updatedSubtask = await _subtaskService.toggleSubtaskCompletion(subtaskId);
      
      setState(() {
        final index = _subtasks.indexWhere((s) => s.id == subtaskId);
        if (index != -1) {
          _subtasks[index] = updatedSubtask;
        }
      });
      widget.onSubtasksChanged?.call(_subtasks);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi cập nhật subtask: $e')),
        );
      }
    }
  }

  Future<void> _deleteSubtask(String subtaskId) async {
    try {
      await _subtaskService.deleteSubtask(subtaskId);
      
      setState(() {
        _subtasks.removeWhere((s) => s.id == subtaskId);
      });
      widget.onSubtasksChanged?.call(_subtasks);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi xóa subtask: $e')),
        );
      }
    }
  }

  void _showEditSubtaskDialog(Subtask subtask) {
    final controller = TextEditingController(text: subtask.title);
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Chỉnh sửa Subtask'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Tiêu đề subtask',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () async {
              final navigator = Navigator.of(dialogContext);
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              
              if (controller.text.trim().isNotEmpty) {
                try {
                  await _subtaskService.updateSubtask(
                    subtask.copyWith(
                      title: controller.text.trim(),
                    ),
                  );
                  
                  setState(() {
                    final index = _subtasks.indexWhere((s) => s.id == subtask.id);
                    if (index != -1) {
                      _subtasks[index] = subtask.copyWith(
                        title: controller.text.trim(),
                      );
                    }
                  });
                  widget.onSubtasksChanged?.call(_subtasks);
                } catch (e) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(content: Text('Lỗi khi cập nhật subtask: $e')),
                  );
                }
              }
              navigator.pop();
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header với progress
        if (_subtasks.isNotEmpty) ...[
          Row(
            children: [
              Icon(
                Icons.checklist,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Subtasks',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              _buildProgressIndicator(),
            ],
          ),
          const SizedBox(height: 12),
        ],

        // Danh sách subtasks
        ..._subtasks.map((subtask) => _buildSubtaskItem(subtask)),

        // Thêm subtask mới (nếu có thể chỉnh sửa)
        if (widget.isEditable) ...[
          const SizedBox(height: 8),
          _buildAddSubtaskField(),
        ],
      ],
    );
  }

  Widget _buildProgressIndicator() {
    final completedCount = _subtasks.where((s) => s.isCompleted).length;
    final totalCount = _subtasks.length;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 60,
          height: 4,
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$completedCount/$totalCount',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildSubtaskItem(Subtask subtask) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          // Checkbox
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: subtask.isCompleted,
              onChanged: widget.isEditable 
                  ? (_) => _toggleSubtask(subtask.id)
                  : null,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          const SizedBox(width: 12),
          
          // Tiêu đề subtask
          Expanded(
            child: GestureDetector(
              onTap: widget.isEditable 
                  ? () => _showEditSubtaskDialog(subtask)
                  : null,
              child: Text(
                subtask.title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  decoration: subtask.isCompleted 
                      ? TextDecoration.lineThrough 
                      : null,
                  color: subtask.isCompleted 
                      ? theme.colorScheme.onSurfaceVariant
                      : theme.colorScheme.onSurface,
                ),
              ),
            ),
          ),
          
          // Nút xóa (nếu có thể chỉnh sửa)
          if (widget.isEditable)
            IconButton(
              onPressed: () => _deleteSubtask(subtask.id),
              icon: Icon(
                Icons.close,
                size: 18,
                color: theme.colorScheme.error,
              ),
              constraints: const BoxConstraints(
                minWidth: 32,
                minHeight: 32,
              ),
              padding: EdgeInsets.zero,
            ),
        ],
      ),
    );
  }

  Widget _buildAddSubtaskField() {
    return Row(
      children: [
        const SizedBox(width: 36), // Căn chỉnh với checkbox
        Expanded(
          child: TextField(
            controller: _newSubtaskController,
            decoration: InputDecoration(
              hintText: 'Thêm subtask...',
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            onSubmitted: (_) => _addSubtask(),
            textInputAction: TextInputAction.done,
          ),
        ),
        IconButton(
          onPressed: _addSubtask,
          icon: Icon(
            Icons.add,
            color: Theme.of(context).colorScheme.primary,
          ),
          constraints: const BoxConstraints(
            minWidth: 32,
            minHeight: 32,
          ),
          padding: EdgeInsets.zero,
        ),
      ],
    );
  }
}