import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';
import '../providers/task_model.dart';

class AddTaskDialog extends StatefulWidget {
  const AddTaskDialog({super.key});

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();
  final _estimatedMinutesController = TextEditingController();
  final _tagController = TextEditingController();
  
  TaskCategory _selectedCategory = TaskCategory.personal;
  TaskPriority _selectedPriority = TaskPriority.medium;
  DateTime? _selectedDueDate;
  List<String> _tags = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    _estimatedMinutesController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Dialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: screenWidth * 0.9,
          maxHeight: screenHeight * 0.85,
          minHeight: screenHeight * 0.5,
        ),
        child: IntrinsicHeight(
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  children: [
                    Text(
                      'Tạo nhiệm vụ mới',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Form
                Flexible(
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title field
                          _buildTextField(
                            controller: _titleController,
                            label: 'Tiêu đề *',
                            hint: 'Nhập tiêu đề nhiệm vụ',
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Vui lòng nhập tiêu đề';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          // Description field
                          _buildTextField(
                            controller: _descriptionController,
                            label: 'Mô tả',
                            hint: 'Mô tả chi tiết nhiệm vụ',
                            maxLines: 3,
                          ),
                          const SizedBox(height: 16),
                          
                          // Category and Priority row
                          Row(
                            children: [
                              Expanded(child: _buildCategoryDropdown()),
                              const SizedBox(width: 16),
                              Expanded(child: _buildPriorityDropdown()),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          // Due date and estimated time row
                          Row(
                            children: [
                              Expanded(child: _buildDueDatePicker()),
                              const SizedBox(width: 16),
                              Expanded(child: _buildEstimatedTimeField()),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          // Tags section
                          _buildTagsSection(),
                          const SizedBox(height: 16),
                          
                          // Notes field
                          _buildTextField(
                            controller: _notesController,
                            label: 'Ghi chú',
                            hint: 'Thêm ghi chú cho nhiệm vụ',
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Action buttons
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Hủy'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _createTask,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Tạo nhiệm vụ'),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Danh mục',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<TaskCategory>(
          value: _selectedCategory,
          isExpanded: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          items: TaskCategory.values.map((category) {
            return DropdownMenuItem(
              value: category,
              child: Text(
                category.displayName,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedCategory = value;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildPriorityDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mức độ ưu tiên',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<TaskPriority>(
          value: _selectedPriority,
          isExpanded: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          items: TaskPriority.values.map((priority) {
            return DropdownMenuItem(
              value: priority,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _getPriorityColor(priority),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      priority.displayName,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedPriority = value;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildDueDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hạn chót',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectDueDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 20,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _selectedDueDate != null
                        ? '${_selectedDueDate!.day}/${_selectedDueDate!.month}/${_selectedDueDate!.year}'
                        : 'Chọn ngày',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: _selectedDueDate != null
                          ? Theme.of(context).colorScheme.onSurface
                          : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ),
                if (_selectedDueDate != null)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDueDate = null;
                      });
                    },
                    child: Icon(
                      Icons.clear,
                      size: 20,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEstimatedTimeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Thời gian dự kiến (phút)',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _estimatedMinutesController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: '25',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tags',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        
        // Tag input field
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _tagController,
                decoration: InputDecoration(
                  hintText: 'Thêm tag',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onFieldSubmitted: _addTag,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => _addTag(_tagController.text),
              icon: const Icon(Icons.add),
              style: IconButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ],
        ),
        
        // Tags display
        if (_tags.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _tags.map((tag) {
              return Chip(
                label: Text(tag),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () {
                  setState(() {
                    _tags.remove(tag);
                  });
                },
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                labelStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
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
        return Colors.purple;
    }
  }

  Future<void> _selectDueDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDueDate) {
      setState(() {
        _selectedDueDate = picked;
      });
    }
  }

  void _addTag(String tag) {
    if (tag.trim().isNotEmpty && !_tags.contains(tag.trim())) {
      setState(() {
        _tags.add(tag.trim());
        _tagController.clear();
      });
    }
  }

  Future<void> _createTask() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final task = Task(
        id: const Uuid().v4(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        category: _selectedCategory,
        priority: _selectedPriority,
        createdAt: DateTime.now(),
        dueDate: _selectedDueDate,
        tags: _tags,
        notes: _notesController.text.trim().isEmpty 
            ? null 
            : _notesController.text.trim(),
        estimatedMinutes: int.tryParse(_estimatedMinutesController.text) ?? 0,
      );

      final taskModel = context.read<TaskModel>();
      await taskModel.addTask(task);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã tạo nhiệm vụ "${task.title}" thành công!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi tạo nhiệm vụ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}