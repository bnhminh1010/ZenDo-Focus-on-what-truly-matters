import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../models/task.dart';
import '../../providers/task_model.dart';
import '../../theme.dart';

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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
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
              'taskCount': taskModel.getTasksByCategory(TaskCategory.work).length,
            },
            {
              'name': 'Family',
              'icon': Icons.family_restroom,
              'color': AppTheme.familyColor,
              'category': TaskCategory.learning,
              'taskCount': taskModel.getTasksByCategory(TaskCategory.learning).length,
            },
            {
              'name': 'Healthy',
              'icon': Icons.favorite_outline,
              'color': AppTheme.healthColor,
              'category': TaskCategory.health,
              'taskCount': taskModel.getTasksByCategory(TaskCategory.health).length,
            },
            {
              'name': 'Personal',
              'icon': Icons.person_outline,
              'color': AppTheme.personalColor,
              'category': TaskCategory.personal,
              'taskCount': taskModel.getTasksByCategory(TaskCategory.personal).length,
            },
            {
              'name': 'Learning',
              'icon': Icons.school_outlined,
              'color': Colors.orange,
              'category': TaskCategory.learning,
              'taskCount': taskModel.getTasksByCategory(TaskCategory.learning).length,
            },
            {
              'name': 'Other',
              'icon': Icons.more_horiz,
              'color': Colors.grey,
              'category': TaskCategory.other,
              'taskCount': taskModel.getTasksByCategory(TaskCategory.other).length,
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
                      pathParameters: {'categoryName': category['name'] as String},
                      extra: {
                        'icon': category['icon'] as IconData,
                        'color': category['color'] as Color,
                        'category': category['category'] as TaskCategory,
                      },
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
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
                              color: (category['color'] as Color).withValues(alpha: 0.1),
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
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
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
            ),
          );
        },
      ),
    );
  }
}