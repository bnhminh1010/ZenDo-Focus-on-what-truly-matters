/*
 * Tên: widgets/add_task_dialog.dart
 * Tác dụng: Dialog tạo/chỉnh sửa Task với form đầy đủ, hỗ trợ tag, ảnh, thời gian focus, và xác thực.
 * Khi nào dùng: Khi người dùng cần tạo nhiệm vụ mới hoặc cập nhật nhiệm vụ hiện có trong ứng dụng.
 */
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/task.dart';
import '../providers/task_model.dart';
import '../services/task_image_storage_service.dart';
import '../theme.dart';
import 'glass_button.dart';
import 'glass_container.dart';
import 'loading_state_widget.dart';

/*
 * Widget: AddTaskDialog
 * Tác dụng: Dialog nhập liệu để tạo/chỉnh sửa Task với các trường thông tin, ảnh và tag.
 * Khi nào dùng: Khi cần hiển thị form tạo/cập nhật nhiệm vụ với xác thực và hành động lưu/hủy.
 */
class AddTaskDialog extends StatefulWidget {
  final Task? editingTask;

  const AddTaskDialog({super.key, this.editingTask});

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

/*
 * State: _AddTaskDialogState
 * Tác dụng: Quản lý form, xác thực dữ liệu, xử lý chọn ảnh, và thao tác với TaskModel.
 * Khi nào dùng: Khi hiển thị AddTaskDialog để điều phối trạng thái nhập liệu và sự kiện người dùng.
 */
class _AddTaskDialogState extends State<AddTaskDialog> {
  /// Key dùng để validate form.
  final _formKey = GlobalKey<FormState>();
  /// Controller cho tiêu đề nhiệm vụ.
  final _titleController = TextEditingController();
  /// Controller cho mô tả nhiệm vụ.
  final _descriptionController = TextEditingController();
  /// Controller cho ghi chú chi tiết.
  final _notesController = TextEditingController();
  /// Controller cho trường thời gian ước tính.
  final _estimatedMinutesController = TextEditingController();
  /// Controller cho input tag tạm.
  final _tagController = TextEditingController();
  /// ImagePicker để chọn ảnh đính kèm.
  final ImagePicker _imagePicker = ImagePicker(); // Thêm ImagePicker

  /// Danh mục được chọn hiện tại.
  TaskCategory _selectedCategory = TaskCategory.personal;
  /// Mức ưu tiên được chọn hiện tại.
  TaskPriority _selectedPriority = TaskPriority.medium;
  /// Deadline được chọn.
  DateTime? _selectedDueDate;
  /// Danh sách tag đã nhập.
  List<String> _tags = [];
  /// Cờ loading khi đang submit.
  bool _isLoading = false;
  /// Ảnh đã chọn (nếu có).
  File? _selectedImage; // Thêm biến lưu ảnh đã chọn
  /// Cờ loading khi đang chọn ảnh.
  bool _isPickingImage = false; // Thêm biến loading state cho image picker
  /// Thời gian focus mặc định cho task (phút).
  int _focusTimeMinutes = 25; // Thêm biến lưu thời gian focus mặc định

  @override
  void initState() {
    super.initState();
    if (widget.editingTask != null) {
      _initializeForEditing();
    }
  }

  /// _initializeForEditing Method
  /// Tác dụng: Khởi tạo dữ liệu form khi chỉnh sửa task hiện có
  /// Sử dụng khi: Dialog được mở với task để chỉnh sửa
  void _initializeForEditing() {
    final task = widget.editingTask!;
    _titleController.text = task.title;
    _descriptionController.text = task.description ?? '';
    _notesController.text = task.notes ?? '';
    _estimatedMinutesController.text = task.estimatedMinutes.toString();
    _selectedCategory = task.category;
    _selectedPriority = task.priority;
    _selectedDueDate = task.dueDate;
    _tags = List.from(task.tags);
    _focusTimeMinutes = task.focusTimeMinutes; // Khởi tạo focus time từ task
    // Không load image file khi edit để tránh lỗi file không tồn tại
    // User sẽ cần chọn lại image nếu muốn thay đổi
  }

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
                      widget.editingTask != null
                          ? 'Chỉnh sửa nhiệm vụ'
                          : 'Tạo nhiệm vụ mới',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    GlassIconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icons.close,
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

                          // Focus time field
                          _buildFocusTimeField(),
                          const SizedBox(height: 16),

                          // Tags section
                          _buildTagsSection(),
                          const SizedBox(height: 16),

                          // Image section - Thêm phần chọn ảnh
                          _buildImageSection(),
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
                    // Hai nút có kích thước bằng nhau và kéo dài vừa đủ khung
                    Expanded(
                      child: GlassOutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text(' Hủy nhiệm vụ '),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GlassElevatedButton(
                        onPressed: _isLoading ? null : _createTask,
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: LoadingStateWidget(size: 20),
                              )
                            : Text(
                                widget.editingTask != null
                                    ? ' Cập nhật tasks'
                                    : ' Tạo nhiệm vụ ',
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
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w500),
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
                color: Theme.of(
                  context,
                ).colorScheme.outline.withOpacity(0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withOpacity(0.3),
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
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<TaskCategory>(
          initialValue: _selectedCategory,
          isExpanded: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withOpacity(0.3),
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
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<TaskPriority>(
          initialValue: _selectedPriority,
          isExpanded: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withOpacity(0.3),
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
                      color: _getPriorityColor(context, priority),
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
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectDueDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withOpacity(0.3),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 20,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
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
                          : Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.6),
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
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.6),
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
          'Thời gian dự kiến',
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w500),
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
                color: Theme.of(
                  context,
                ).colorScheme.outline.withOpacity(0.3),
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
          'Thẻ tag',
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w500),
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
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withOpacity(0.3),
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

  Color _getPriorityColor(BuildContext context, TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return context.successColor;
      case TaskPriority.medium:
        return context.warningColor;
      case TaskPriority.high:
        return context.errorColor;
      case TaskPriority.urgent:
        return Theme.of(context).colorScheme.error;
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
      final taskModel = context.read<TaskModel>();
      final imageService = TaskImageStorageService();

      // Upload hình ảnh lên Supabase nếu có
      String? uploadedImageUrl;
      if (_selectedImage != null) {
        uploadedImageUrl = await imageService.uploadTaskImage(
          _selectedImage!,
        );
        if (uploadedImageUrl == null) {
          throw Exception('Không thể upload hình ảnh');
        }
      }

      if (widget.editingTask != null) {
        // Cập nhật task hiện có
        final updatedTask = widget.editingTask!.copyWith(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          category: _selectedCategory,
          priority: _selectedPriority,
          dueDate: _selectedDueDate,
          tags: _tags,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
          estimatedMinutes: int.tryParse(_estimatedMinutesController.text) ?? 0,
          focusTimeMinutes: _focusTimeMinutes, // Thêm focus time
          imageUrl: uploadedImageUrl ?? widget.editingTask!.imageUrl,
        );

        await taskModel.updateTask(updatedTask);

        if (mounted) {
          Navigator.of(context).pop(updatedTask);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Đã cập nhật nhiệm vụ "${updatedTask.title}" thành công!',
              ),
              backgroundColor: context.successColor,
            ),
          );
        }
      } else {
        // Tạo task mới
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
          focusTimeMinutes: _focusTimeMinutes, // Thêm focus time
          imageUrl: uploadedImageUrl,
        );

        await taskModel.addTask(task);

        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã tạo nhiệm vụ "${task.title}" thành công!'),
              backgroundColor: context.successColor,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Lỗi khi ${widget.editingTask != null ? "cập nhật" : "tạo"} nhiệm vụ: $e',
            ),
            backgroundColor: context.errorColor,
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

  /// Widget để chọn/chụp ảnh
  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hình ảnh',
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),

        // Hiển thị ảnh đã chọn hoặc nút chọn ảnh
        if (_selectedImage != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withOpacity(0.3),
                ),
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: Image.file(
                      _selectedImage!,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: double.infinity,
                          height: 200,
                          color: Theme.of(context).colorScheme.errorContainer,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 32,
                                color: Theme.of(context).colorScheme.error,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Không thể tải ảnh',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  // Overlay gradient để làm nổi bật nút
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(11),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.1),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Nút xóa ảnh
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GlassIconButton(
                      onPressed: () {
                        setState(() {
                          _selectedImage = null;
                        });
                      },
                      icon: Icons.close,
                    ),
                  ),
                  // Nút thay đổi ảnh
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: GlassElevatedButton.icon(
                      onPressed: _isPickingImage
                          ? null
                          : _showImageSourceDialog,
                      icon: const Icon(Icons.edit, size: 14),
                      label: const Text(
                        'Thay đổi',
                        style: TextStyle(fontSize: 11),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 140),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withOpacity(0.3),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isPickingImage) ...[
                    // Loading state
                    const CircularProgressIndicator(),
                    const SizedBox(height: 12),
                    Text(
                      'Đang xử lý ảnh...',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.outline,
                        fontSize: 14,
                      ),
                    ),
                  ] else ...[
                    // Normal state
                    Icon(
                      Icons.image,
                      size: 32,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Thêm hình ảnh',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.outline,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        GlassElevatedButton.icon(
                          onPressed: () => _pickImage(ImageSource.camera),
                          icon: const Icon(Icons.camera_alt, size: 14),
                          label: const Text(
                            'Chụp ảnh',
                            style: TextStyle(fontSize: 11),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                        ),
                        GlassElevatedButton.icon(
                          onPressed: () => _pickImage(ImageSource.gallery),
                          icon: const Icon(Icons.photo_library, size: 14),
                          label: const Text(
                            'Chọn ảnh',
                            style: TextStyle(fontSize: 11),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }

  /// Hiển thị dialog chọn nguồn ảnh
  void _showImageSourceDialog() {
    // Kiểm tra platform để hiển thị tùy chọn phù hợp
    final bool isDesktop =
        Theme.of(context).platform == TargetPlatform.windows ||
        Theme.of(context).platform == TargetPlatform.linux ||
        Theme.of(context).platform == TargetPlatform.macOS;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Chọn nguồn ảnh',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            if (isDesktop) ...[
              // Chỉ hiển thị gallery cho desktop
              SizedBox(
                width: double.infinity,
                child: GlassElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Chọn từ thư viện'),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Camera chưa được hỗ trợ trên Windows',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Hiển thị cả camera và gallery cho mobile
              Row(
                children: [
                  Expanded(
                    child: GlassElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.camera);
                      },
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Camera'),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GlassElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.gallery);
                      },
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Thư viện'),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// Chọn ảnh từ camera hoặc gallery
  Future<void> _pickImage(ImageSource source) async {
    setState(() {
      _isPickingImage = true;
    });

    try {
      // Debug: In thông tin về source
      if (kDebugMode) {
        debugPrint(
          '🔍 Đang chọn ảnh từ: ${source == ImageSource.camera ? "Camera" : "Gallery"}',
        );
      }

      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.rear, // Ưu tiên camera sau
      );

      if (pickedFile != null) {
        if (kDebugMode) {
          debugPrint('✅ Đã chọn ảnh: ${pickedFile.path}');
        }

        setState(() {
          _selectedImage = File(pickedFile.path);
        });

        // Hiển thị thông báo thành công với preview
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  // Mini preview của ảnh
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: FileImage(_selectedImage!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Đã chọn ảnh thành công!',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          'Kích thước: ${(File(pickedFile.path).lengthSync() / 1024).toStringAsFixed(1)} KB',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(
                              context,
                            ).colorScheme.onPrimary.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              backgroundColor: Theme.of(context).colorScheme.primary,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
              action: SnackBarAction(
                label: 'Xem',
                textColor: Theme.of(context).colorScheme.onPrimary,
                onPressed: () => _showImagePreview(),
              ),
            ),
          );
        }
      } else {
        if (kDebugMode) {
          debugPrint('❌ Người dùng hủy chọn ảnh');
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Đã hủy chọn ảnh'),
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('🚨 Lỗi khi chọn ảnh: $e');
      }

      if (mounted) {
        String errorMessage = 'Lỗi khi chọn ảnh';
        String suggestion = '';

        // Xử lý các loại lỗi cụ thể với gợi ý
        if (e.toString().contains('camera_access_denied') ||
            e.toString().contains('Permission denied')) {
          errorMessage = 'Không có quyền truy cập camera';
          suggestion = 'Vui lòng cấp quyền camera trong cài đặt Windows';
        } else if (e.toString().contains('photo_access_denied')) {
          errorMessage = 'Không có quyền truy cập thư viện ảnh';
          suggestion = 'Vui lòng cấp quyền truy cập file trong cài đặt';
        } else if (e.toString().contains('camera_unavailable') ||
            e.toString().contains('No camera available')) {
          errorMessage = 'Camera không khả dụng';
          suggestion = 'Thử chọn ảnh từ thư viện thay thế';
        } else if (e.toString().contains('PlatformException')) {
          errorMessage = 'Lỗi hệ thống khi truy cập camera';
          suggestion = 'Thử khởi động lại ứng dụng hoặc chọn từ thư viện';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Theme.of(context).colorScheme.onError,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(errorMessage)),
                  ],
                ),
                if (suggestion.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    suggestion,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(
                        context,
                      ).colorScheme.onError.withOpacity(0.8),
                    ),
                  ),
                ],
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: source == ImageSource.camera ? 'Thư viện' : 'Thử lại',
              textColor: Theme.of(context).colorScheme.onError,
              onPressed: () {
                if (source == ImageSource.camera) {
                  // Nếu camera lỗi, thử gallery
                  _pickImage(ImageSource.gallery);
                } else {
                  // Thử lại
                  _pickImage(source);
                }
              },
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPickingImage = false;
        });
      }
    }
  }

  /// Hiển thị preview ảnh đã chọn
  void _showImagePreview() {
    if (_selectedImage == null) return;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          borderRadius: 20,
          blur: 20,
          opacity: 0.15,
          padding: const EdgeInsets.all(24),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header với icon và tiêu đề
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text('🖼️', style: TextStyle(fontSize: 24)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Preview Ảnh',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            'Xem trước ảnh đã chọn cho task',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Image preview
                Flexible(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(_selectedImage!, fit: BoxFit.contain),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: Semantics(
                        label: 'Xóa ảnh đã chọn',
                        hint: 'Nhấn để xóa ảnh khỏi task',
                        child: GlassOutlinedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            setState(() {
                              _selectedImage = null;
                            });
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.delete_outline),
                              SizedBox(width: 8),
                              Text('Xóa ảnh'),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Semantics(
                        label: 'Chọn ảnh khác',
                        hint: 'Nhấn để chọn ảnh mới thay thế',
                        child: GlassElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _showImageSourceDialog();
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt),
                              SizedBox(width: 8),
                              Text('Chọn lại'),
                            ],
                          ),
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

  Widget _buildFocusTimeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Thời gian Focus (phút)',
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.outline.withOpacity(0.3),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _focusTimeMinutes,
              isExpanded: true,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              items: const [
                DropdownMenuItem(value: 5, child: Text('5 phút')),
                DropdownMenuItem(value: 15, child: Text('15 phút')),
                DropdownMenuItem(value: 25, child: Text('25 phút (Pomodoro)')),
                DropdownMenuItem(value: 30, child: Text('30 phút')),
                DropdownMenuItem(value: 45, child: Text('45 phút')),
                DropdownMenuItem(value: 60, child: Text('60 phút')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _focusTimeMinutes = value;
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}

