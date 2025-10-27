/*
 * Tên: screens/categories/categories_list_page.dart
 * Tác dụng: Màn hình hiển thị danh sách tất cả categories với navigation đến chi tiết
 * Khi nào dùng: Người dùng muốn xem tổng quan các categories và truy cập vào từng category
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../models/task.dart';
import '../../providers/task_model.dart';
import '../../theme.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/glass_button.dart';

/// Trang hiển thị tất cả categories
class CategoriesListPage extends StatelessWidget {
  const CategoriesListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tất cả danh mục'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GlassIconButton(
          icon: Icons.arrow_back_ios,
          onPressed: () => context.pop(),
        ),
      ),
      body: Consumer<TaskModel>(
        builder: (context, taskModel, child) {
          final categories = [
            {
              'name': 'Work',
              'icon': Icons.work_outline,
              'color': AppTheme.workColor,
              'category': TaskCategory.work,
              'taskCount': taskModel
                  .getTasksByCategory(TaskCategory.work)
                  .length,
            },
            {
              'name': 'Family',
              'icon': Icons.family_restroom,
              'color': AppTheme.familyColor,
              'category': TaskCategory.social,
              'taskCount': taskModel
                  .getTasksByCategory(TaskCategory.social)
                  .length,
            },
            {
              'name': 'Healthy',
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
              'name': 'Learning',
              'icon': Icons.school_outlined,
              'color': Colors.orange,
              'category': TaskCategory.learning,
              'taskCount': taskModel
                  .getTasksByCategory(TaskCategory.learning)
                  .length,
            },
            {
              'name': 'Finance',
              'icon': Icons.account_balance_wallet_outlined,
              'color': Colors.orange,
              'category': TaskCategory.finance,
              'taskCount': taskModel
                  .getTasksByCategory(TaskCategory.finance)
                  .length,
            },
            {
              'name': 'Other',
              'icon': Icons.more_horiz,
              'color': Colors.grey,
              'category': TaskCategory.other,
              'taskCount': taskModel
                  .getTasksByCategory(TaskCategory.other)
                  .length,
            },
          ];

          return Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: categories.map((category) {
                return GestureDetector(
                  onTap: () {
                    // Navigate to category detail page
                    context.pushNamed(
                      'categoryDetail',
                      pathParameters: {
                        'categoryName': category['name'] as String,
                      },
                      extra: {
                        'icon': category['icon'] as IconData,
                        'color': category['color'] as Color,
                        'category': category['category'] as TaskCategory,
                      },
                    );
                  },
                  child: GlassContainer(
                    borderRadius: 16,
                    blur: 12,
                    opacity: 0.14,
                    padding: const EdgeInsets.all(12),
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
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: category['color'] as Color,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}

