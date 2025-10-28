/*
 * Tên: widgets/enhanced_empty_state_widget.dart
 * Tác dụng: Widget trạng thái trống với illustration/animation và hành động gợi ý.
 * Khi nào dùng: Hiển thị khi danh sách rỗng (task, focus sessions, v.v.).
 */
import 'package:flutter/material.dart';
import 'haptic_feedback_widget.dart';
import 'glass_container.dart';
import 'glass_button.dart';

/// Enhanced empty state widget với illustrations và actions
class EnhancedEmptyStateWidget extends StatelessWidget {
  /// Tiêu đề trạng thái trống.
  final String title;
  /// Mô tả chi tiết.
  final String subtitle;
  /// Icon minh hoạ.
  final IconData icon;
  /// Text của action chính (optional).
  final String? actionText;
  /// Callback khi action chính được nhấn.
  final VoidCallback? onActionPressed;
  /// Màu icon.
  final Color? iconColor;
  /// Kích thước icon.
  final double iconSize;
  /// Illustration tuỳ chỉnh thay cho icon.
  final Widget? illustration;
  /// Danh sách action bổ sung (optional).
  final List<Widget>? additionalActions;

  const EnhancedEmptyStateWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.actionText,
    this.onActionPressed,
    this.iconColor,
    this.iconSize = 80,
    this.illustration,
    this.additionalActions,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Illustration hoặc icon
              if (illustration != null)
                illustration!
              else
                _buildAnimatedIcon(context),

              const SizedBox(height: 24),

              // Title
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // Subtitle
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Primary action
              if (actionText != null && onActionPressed != null)
                HapticButton(
                  onPressed: onActionPressed,
                  feedbackType: HapticFeedbackType.medium,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(actionText!),
                ),

              // Additional actions
              if (additionalActions != null) ...[
                const SizedBox(height: 16),
                ...additionalActions!,
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedIcon(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(seconds: 2),
      tween: Tween(begin: 0.8, end: 1.0),
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: (iconColor ?? Theme.of(context).colorScheme.primary)
                  .withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: iconSize,
              color: iconColor ?? Theme.of(context).colorScheme.primary,
            ),
          ),
        );
      },
    );
  }
}

/// Empty state cho task list
class TaskListEmptyState extends StatelessWidget {
  final VoidCallback? onAddTask;

  const TaskListEmptyState({super.key, this.onAddTask});

  @override
  Widget build(BuildContext context) {
    return EnhancedEmptyStateWidget(
      icon: Icons.task_alt_outlined,
      title: 'Chưa có task nào',
      subtitle: 'Hãy tạo task đầu tiên để bắt đầu quản lý công việc của bạn',
      actionText: 'Tạo Task Mới',
      onActionPressed: onAddTask,
      illustration: _buildTaskIllustration(context),
    );
  }

  Widget _buildTaskIllustration(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(60),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circles
          Positioned(
            top: 20,
            left: 20,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: 25,
            right: 25,
            child: Container(
              width: 15,
              height: 15,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Main icon
          Icon(
            Icons.assignment_outlined,
            size: 50,
            color: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }
}

/// Empty state cho focus sessions
class FocusSessionEmptyState extends StatelessWidget {
  final VoidCallback? onStartFocus;

  const FocusSessionEmptyState({super.key, this.onStartFocus});

  @override
  Widget build(BuildContext context) {
    return EnhancedEmptyStateWidget(
      icon: Icons.psychology_outlined,
      title: 'Sẵn sàng tập trung?',
      subtitle:
          'Chọn một task và bắt đầu phiên tập trung để nâng cao hiệu suất làm việc',
      actionText: 'Bắt Đầu Focus',
      onActionPressed: onStartFocus,
      illustration: _buildFocusIllustration(context),
    );
  }

  Widget _buildFocusIllustration(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(seconds: 3),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, progress, child) {
        return Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                Theme.of(context).colorScheme.primary.withOpacity(0.2),
                Theme.of(context).colorScheme.primary.withOpacity(0.05),
              ],
            ),
            shape: BoxShape.circle,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Animated rings
              for (int i = 0; i < 3; i++)
                AnimatedContainer(
                  duration: Duration(milliseconds: 1000 + (i * 200)),
                  width: 60 + (i * 20) * progress,
                  height: 60 + (i * 20) * progress,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.3 - (i * 0.1)),
                      width: 2,
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
              // Center icon
              Icon(
                Icons.center_focus_strong,
                size: 40,
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Empty state cho categories
class CategoryEmptyState extends StatelessWidget {
  final VoidCallback? onAddCategory;

  const CategoryEmptyState({super.key, this.onAddCategory});

  @override
  Widget build(BuildContext context) {
    return EnhancedEmptyStateWidget(
      icon: Icons.folder_outlined,
      title: 'Chưa có danh mục nào',
      subtitle: 'Tạo danh mục để tổ chức các task của bạn một cách hiệu quả',
      actionText: 'Tạo Danh Mục',
      onActionPressed: onAddCategory,
      additionalActions: [
        TextButton.icon(
          onPressed: () {
            // Show tips dialog
            _showCategoryTips(context);
          },
          icon: const Icon(Icons.lightbulb_outline),
          label: const Text('Xem gợi ý'),
        ),
      ],
    );
  }

  void _showCategoryTips(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          borderRadius: 24,
          blur: 20,
          opacity: 0.15,
          padding: const EdgeInsets.all(32),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            constraints: const BoxConstraints(maxWidth: 400),
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
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text('💡', style: TextStyle(fontSize: 24)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Gợi ý danh mục',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Một số danh mục phổ biến để bạn tham khảo',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.7),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Category suggestions
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainer.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCategoryItem(
                        context,
                        '🏢',
                        'Công việc',
                        'Các task liên quan đến công việc',
                      ),
                      const SizedBox(height: 8),
                      _buildCategoryItem(
                        context,
                        '🏠',
                        'Cá nhân',
                        'Việc cá nhân và gia đình',
                      ),
                      const SizedBox(height: 8),
                      _buildCategoryItem(
                        context,
                        '📚',
                        'Học tập',
                        'Học tập và phát triển bản thân',
                      ),
                      const SizedBox(height: 8),
                      _buildCategoryItem(
                        context,
                        '💪',
                        'Sức khỏe',
                        'Tập luyện và chăm sóc sức khỏe',
                      ),
                      const SizedBox(height: 8),
                      _buildCategoryItem(
                        context,
                        '🎯',
                        'Dự án',
                        'Các dự án và mục tiêu dài hạn',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Action button
                SizedBox(
                  width: double.infinity,
                  child: Semantics(
                    label: 'Đóng gợi ý danh mục',
                    hint: 'Nhấn để đóng dialog',
                    child: GlassElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Đã hiểu'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryItem(
    BuildContext context,
    String icon,
    String title,
    String description,
  ) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Empty state cho search results
class SearchEmptyState extends StatelessWidget {
  final String searchQuery;
  final VoidCallback? onClearSearch;

  const SearchEmptyState({
    super.key,
    required this.searchQuery,
    this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    return EnhancedEmptyStateWidget(
      icon: Icons.search_off_outlined,
      title: 'Không tìm thấy kết quả',
      subtitle: 'Không có task nào phù hợp với từ khóa "$searchQuery"',
      actionText: 'Xóa tìm kiếm',
      onActionPressed: onClearSearch,
      additionalActions: [
        TextButton.icon(
          onPressed: () {
            // Show search tips
            _showSearchTips(context);
          },
          icon: const Icon(Icons.help_outline),
          label: const Text('Mẹo tìm kiếm'),
        ),
      ],
    );
  }

  void _showSearchTips(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          borderRadius: 24,
          blur: 20,
          opacity: 0.15,
          padding: const EdgeInsets.all(32),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            constraints: const BoxConstraints(maxWidth: 400),
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
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text('🔍', style: TextStyle(fontSize: 24)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mẹo tìm kiếm',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Cách tìm kiếm hiệu quả hơn',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.7),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Search tips
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainer.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSearchTip(
                        '💡',
                        'Thử từ khóa ngắn gọn hơn',
                        'Sử dụng 1-2 từ chính',
                        context,
                      ),
                      const SizedBox(height: 8),
                      _buildSearchTip(
                        '✏️',
                        'Kiểm tra chính tả',
                        'Đảm bảo từ khóa được viết đúng',
                        context,
                      ),
                      const SizedBox(height: 8),
                      _buildSearchTip(
                        '🔄',
                        'Sử dụng từ đồng nghĩa',
                        'Thử các từ có nghĩa tương tự',
                        context,
                      ),
                      const SizedBox(height: 8),
                      _buildSearchTip(
                        '📂',
                        'Tìm theo danh mục',
                        'Lọc theo danh mục cụ thể',
                        context,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Action button
                SizedBox(
                  width: double.infinity,
                  child: Semantics(
                    label: 'Đóng mẹo tìm kiếm',
                    hint: 'Nhấn để đóng dialog',
                    child: GlassElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Đã hiểu'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchTip(
    String icon,
    String title,
    String description,
    BuildContext context,
  ) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
