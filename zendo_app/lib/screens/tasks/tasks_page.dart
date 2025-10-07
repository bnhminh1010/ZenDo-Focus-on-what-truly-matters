import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/task_model.dart';
import '../../theme.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        title: Text(
          'Tasks',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Search bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm nhiệm vụ...',
                        hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Categories Grid
            Expanded(
              child: Consumer<TaskModel>(
                builder: (context, taskModel, child) {
                  return GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.0,
                    children: [
                      _buildCategoryCard(context, 'Work', AppTheme.workColor, Icons.work_outline, 12),
                      _buildCategoryCard(context, 'Family', AppTheme.familyColor, Icons.family_restroom, 8),
                      _buildCategoryCard(context, 'Healthy', AppTheme.healthColor, Icons.favorite_outline, 6),
                      _buildCategoryCard(context, 'Personal', AppTheme.personalColor, Icons.person_outline, 5),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, String category, Color categoryColor, IconData icon, int taskCount) {
    return GestureDetector(
      onTap: () {
        // TODO: Navigate to category detail page
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: categoryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: categoryColor,
                size: 24,
              ),
            ),
            const Spacer(),
            
            // Category name
            Text(
              category,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            
            // Task count
            Text(
              '$taskCount Tasks',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}