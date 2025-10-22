import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/task_model.dart';
import '../../providers/auth_model.dart';
import '../../models/task.dart';
import '../../theme.dart';
import '../../widgets/add_task_dialog.dart';
import '../../widgets/task_card.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/glass_button.dart';

/// HomePage Class
/// Tác dụng: Màn hình chính của ứng dụng hiển thị dashboard với tasks, thống kê và navigation
/// Sử dụng khi: Người dùng mở ứng dụng và cần xem tổng quan về tasks và hoạt động
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

/// _HomePageState Class
/// Tác dụng: State class quản lý trạng thái và logic của HomePage
/// Sử dụng khi: Cần quản lý search functionality và lifecycle của HomePage
class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Khởi tạo TaskModel để load tasks từ database
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskModel>().initialize();
    });

    // Lắng nghe thay đổi trong search controller
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final isDesktop = screenSize.width > 1200;

    // Responsive padding
    final horizontalPadding = isDesktop ? 40.0 : (isTablet ? 30.0 : 20.0);
    final bottomPadding = isDesktop ? 80.0 : (isTablet ? 100.0 : 140.0);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Semantics(
          label: 'Tiêu đề trang chủ ZenDo',
          child: Text(
            'ZenDo - Trang chủ',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        centerTitle: false,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              // Responsive padding
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                20,
                horizontalPadding,
                bottomPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search bar dùng Liquid Glass
                  Semantics(
                    label: 'Thanh tìm kiếm nhiệm vụ',
                    hint: 'Nhập từ khóa để tìm kiếm nhiệm vụ',
                    child: GlassContainer(
                      borderRadius: 16,
                      blur: 16,
                      opacity: 0.14, // đồng nhất mức trong suốt
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Semantics(
                            label: 'Biểu tượng tìm kiếm',
                            child: Icon(
                              Icons.search,
                              color: Theme.of(context).colorScheme.onSurface
                                  .withValues(
                                    alpha: 0.7,
                                  ), // Tăng contrast từ 0.6 lên 0.7
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Tìm kiếm nhiệm vụ...',
                                hintStyle: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(
                                            alpha: 0.6,
                                          ), // Tăng contrast từ 0.5 lên 0.6
                                    ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                              onSubmitted: (value) {
                                if (value.trim().isNotEmpty) {
                                  // Navigate to tasks page with search query
                                  context.push(
                                    '/tasks?search=${Uri.encodeComponent(value.trim())}',
                                  );
                                }
                              },
                            ),
                          ),
                          if (_searchQuery.isNotEmpty)
                            GlassIconButton(
                              icon: Icons.clear,
                              onPressed: () {
                                _searchController.clear();
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Create buttons section (moved to top for better UX)
                  _buildCreateButtons(isTablet, isDesktop),
                  const SizedBox(height: 32),

                  // Categories Grid
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Danh mục nhiệm vụ',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      GlassTextButton(
                        onPressed: () {
                          // Navigate to all categories page
                          context.push('/categories');
                        },
                        child: const Text('Xem tất cả'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildCategoriesGrid(isTablet, isDesktop),
                  const SizedBox(height: 32),

                  // Recent Tasks Section
                  _buildRecentTasksSection(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCategoriesGrid(bool isTablet, bool isDesktop) {
    return Consumer<TaskModel>(
      builder: (context, taskModel, child) {
        final categories = [
          {
            'name': 'Work',
            'icon': Icons.work_outline,
            'color': AppTheme.workColor,
            'category': TaskCategory.work,
            'taskCount': taskModel.getTasksByCategory(TaskCategory.work).length,
          },
          {
            'name': 'Learning',
            'icon': Icons.school_outlined,
            'color': AppTheme.familyColor,
            'category': TaskCategory.learning,
            'taskCount': taskModel
                .getTasksByCategory(TaskCategory.learning)
                .length,
          },
          {
            'name': 'Health',
            'icon': Icons.favorite_outline,
            'color': AppTheme.healthColor,
            'category': TaskCategory.health,
            'taskCount': taskModel
                .getTasksByCategory(TaskCategory.health)
                .length,
          },
          {
            'name': 'Personal',
            'icon': Icons.person_outline,
            'color': AppTheme.personalColor,
            'category': TaskCategory.personal,
            'taskCount': taskModel
                .getTasksByCategory(TaskCategory.personal)
                .length,
          },
          {
            'name': 'Finance',
            'icon': Icons.account_balance_wallet_outlined,
            'color': context.warningColor,
            'category': TaskCategory.finance,
            'taskCount': taskModel
                .getTasksByCategory(TaskCategory.finance)
                .length,
          },
          {
            'name': 'Social',
            'icon': Icons.people_outline,
            'color': Theme.of(context).colorScheme.tertiary,
            'category': TaskCategory.social,
            'taskCount': taskModel
                .getTasksByCategory(TaskCategory.social)
                .length,
          },
        ];

        // Layout danh mục đồng bộ với statistics cards
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: categories.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isDesktop
                ? 4
                : (isTablet ? 3 : 2), // Responsive columns
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            // Responsive height
            mainAxisExtent: isDesktop ? 120 : (isTablet ? 115 : 110),
          ),
          itemBuilder: (context, idx) {
            final category = categories[idx];
            return GestureDetector(
              onTap: () {
                context.pushNamed(
                  'categoryDetail',
                  pathParameters: {'categoryName': category['name'] as String},
                  extra: {
                    'icon': category['icon'] as IconData,
                    'color': category['color'] as Color,
                    'category': category['category'] as TaskCategory,
                  },
                );
              },
              child: GlassContainer(
                // Layout đồng bộ với statistics cards
                borderRadius: 16,
                blur: 12,
                opacity: 0.14,
                padding: const EdgeInsets.all(
                  12,
                ), // giảm padding để card nhỏ gọn hơn
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          category['icon'] as IconData,
                          color: category['color'] as Color,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            category['name'] as String,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: (category['color'] as Color)
                                      .withOpacity(0.8),
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${category['taskCount']} nhiệm vụ',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: category['color'] as Color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRecentTasksSection() {
    return Consumer<TaskModel>(
      builder: (context, taskModel, child) {
        // Tách task hoàn thành và chưa hoàn thành
        final incompleteTasks = taskModel.tasks
            .where((task) => !task.isCompleted)
            .toList();
        final completedTasks = taskModel.tasks
            .where((task) => task.isCompleted)
            .toList();

        // Sắp xếp theo thời gian tạo (mới nhất trước)
        incompleteTasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        completedTasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        // Kết hợp: task chưa hoàn thành trước, task hoàn thành sau
        final recentTasks = [
          ...incompleteTasks,
          ...completedTasks,
        ].take(3).toList(); // Lấy 3 task gần đây nhất

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
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'Chưa có nhiệm vụ nào',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tạo nhiệm vụ đầu tiên của bạn!',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.5),
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
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                GlassTextButton(
                  onPressed: () {
                    context.push('/tasks');
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
                return TaskCard(
                  task: task,
                  onTap: () {
                    context.pushNamed(
                      'taskDetail',
                      pathParameters: {'taskId': task.id},
                      extra: task,
                    );
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildCreateButtons(bool isTablet, bool isDesktop) {
    return Flex(
      direction: isTablet ? Axis.horizontal : Axis.horizontal,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Create Task Button
        Flexible(
          child: GlassElevatedButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const AddTaskDialog(),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Tạo Task'),
          ),
        ),
        SizedBox(width: isDesktop ? 24 : 16),
        // Ask AI Button
        Flexible(
          child: GlassElevatedButton.icon(
            onPressed: () {
              context.push('/ai-chat');
            },
            icon: Image.asset(
              'assets/icons/bot.png',
              width: 18,
              height: 18,
              color: Theme.of(context).colorScheme.onSecondary,
            ),
            label: const Text('BilyBily'),
          ),
        ),
      ],
    );
  }

  Widget _buildTaskCard(Task task) {
    Color priorityColor;
    switch (task.priority) {
      case TaskPriority.high:
        priorityColor = context.errorColor;
        break;
      case TaskPriority.medium:
        priorityColor = context.warningColor;
        break;
      case TaskPriority.low:
        priorityColor = context.successColor;
        break;
      case TaskPriority.urgent:
        priorityColor = Theme.of(context).colorScheme.error;
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
                    decoration: task.isCompleted
                        ? TextDecoration.lineThrough
                        : null,
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
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withOpacity(0.7),
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
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

