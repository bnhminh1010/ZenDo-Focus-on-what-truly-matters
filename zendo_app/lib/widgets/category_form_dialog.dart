import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/category_service.dart';
import '../theme.dart';
import 'loading_state_widget.dart';
import 'glass_container.dart';
import 'glass_button.dart';

/// Dialog form để tạo mới hoặc chỉnh sửa Category
class CategoryFormDialog extends StatefulWidget {
  final Category? category;

  const CategoryFormDialog({super.key, this.category});

  @override
  State<CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends State<CategoryFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedIcon = '📝';
  late Color _selectedColor;
  bool _isLoading = false;

  // Danh sách icons phổ biến cho categories
  final List<String> _availableIcons = [
    '📝',
    '💼',
    '🎯',
    '💡',
    '📚',
    '🏃‍♂️',
    '💰',
    '👥',
    '🏠',
    '🛒',
    '🎨',
    '🎵',
    '🍳',
    '🧘‍♀️',
    '✈️',
    '🎮',
    '📱',
    '💻',
    '🚗',
    '🌱',
    '❤️',
    '⭐',
    '🔥',
    '🎉',
    '📊',
    '🔧',
    '🎓',
    '🏆',
    '💊',
    '🛏️',
    '☕',
    '🌟',
  ];

  // Danh sách màu sắc phổ biến
  List<Color> get _availableColors => [
    Theme.of(context).colorScheme.primary,
    context.errorColor,
    context.successColor,
    context.warningColor,
    Theme.of(context).colorScheme.secondary,
    context.workColor,
    Theme.of(context).colorScheme.tertiary,
    Theme.of(context).colorScheme.primaryContainer,
    context.personalColor,
    context.healthColor,
    Theme.of(context).colorScheme.surfaceContainer,
    Theme.of(context).colorScheme.outline,
    context.grey600,
    context.grey400,
    Theme.of(context).colorScheme.error,
    context.grey500,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _nameController.text = widget.category!.name;
      _selectedIcon = widget.category!.icon;
      _selectedColor = _parseColor(widget.category!.color);
    } else {
      // Khởi tạo màu mặc định khi tạo category mới
      _selectedColor = Colors.blue;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.category != null;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassContainer(
        borderRadius: 24,
        blur: 20,
        opacity: 0.15,
        padding: const EdgeInsets.all(32),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: const BoxConstraints(maxWidth: 500),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _selectedColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          _selectedIcon,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEditing
                                ? 'Chỉnh sửa danh mục'
                                : 'Tạo danh mục mới',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            isEditing
                                ? 'Cập nhật thông tin danh mục'
                                : 'Thêm danh mục để tổ chức task',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: context.grey600),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Tên danh mục
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Tên danh mục *',
                    hintText: 'Ví dụ: Công việc, Học tập...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surfaceContainer,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập tên danh mục';
                    }
                    if (value.trim().length < 2) {
                      return 'Tên danh mục phải có ít nhất 2 ký tự';
                    }
                    if (value.trim().length > 50) {
                      return 'Tên danh mục không được quá 50 ký tự';
                    }
                    return null;
                  },
                  textCapitalization: TextCapitalization.words,
                ),

                const SizedBox(height: 16),

                // Mô tả (tùy chọn)
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Mô tả (tùy chọn)',
                    hintText: 'Mô tả ngắn về danh mục này...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surfaceContainer,
                  ),
                  maxLines: 2,
                  validator: (value) {
                    if (value != null && value.trim().length > 200) {
                      return 'Mô tả không được quá 200 ký tự';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // Icon selection
                Text(
                  'Chọn biểu tượng',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Semantics(
                  label: 'Chọn biểu tượng cho danh mục',
                  hint: 'Vuốt để xem thêm biểu tượng và nhấn để chọn',
                  child: SizedBox(
                    height: 60,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _availableIcons.length,
                      itemBuilder: (context, index) {
                        final icon = _availableIcons[index];
                        final isSelected = _selectedIcon == icon;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedIcon = icon;
                              });
                            },
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? _selectedColor.withOpacity(0.2)
                                    : Theme.of(
                                        context,
                                      ).colorScheme.surfaceContainer,
                                borderRadius: BorderRadius.circular(12),
                                border: isSelected
                                    ? Border.all(
                                        color: _selectedColor,
                                        width: 2,
                                      )
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  icon,
                                  style: const TextStyle(fontSize: 24),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Color selection
                Text(
                  'Chọn màu sắc',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Semantics(
                  label: 'Chọn màu sắc cho danh mục',
                  hint: 'Nhấn vào màu để chọn',
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _availableColors.map((color) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedColor = color;
                          });
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: _selectedColor == color
                                ? Border.all(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                    width: 3,
                                  )
                                : null,
                            boxShadow: _selectedColor == color
                                ? [
                                    BoxShadow(
                                      color: color.withOpacity(0.5),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ]
                                : null,
                          ),
                          child: _selectedColor == color
                              ? Icon(
                                  Icons.check,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                  size: 20,
                                )
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 32),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: GlassOutlinedButton(
                        onPressed: _isLoading
                            ? null
                            : () => Navigator.of(context).pop(),
                        child: const Text('Hủy'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GlassElevatedButton(
                        onPressed: _isLoading ? null : _saveCategory,
                        child: _isLoading
                            ? const LoadingStateWidget(size: 20)
                            : Text(isEditing ? 'Cập nhật' : 'Tạo mới'),
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

  void _saveCategory() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Vui lòng nhập tên danh mục'),
          backgroundColor: context.errorColor,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final name = _nameController.text.trim();
      final colorString = _selectedColor
          .toARGB32()
          .toRadixString(16)
          .substring(2);

      if (widget.category != null) {
        // Cập nhật danh mục
        final categoryService = CategoryService();
        await categoryService.updateCategory(
          widget.category!.id,
          name: name,
          icon: _selectedIcon,
          color: colorString,
        );

        if (mounted) {
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã cập nhật danh mục "$name"'),
              backgroundColor: context.successColor,
            ),
          );
        }
      } else {
        final categoryService = CategoryService();
        await categoryService.createCategory(
          name: name,
          icon: _selectedIcon,
          color: colorString,
        );

        if (mounted) {
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã tạo danh mục "$name"'),
              backgroundColor: context.successColor,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Có lỗi xảy ra: $e'),
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

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Theme.of(context).colorScheme.primary;
    }
  }
}

