import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/pomodoro_timer_widget.dart';
import '../../providers/focus_session_model.dart';
import '../../providers/task_model.dart';
import '../../models/focus_session.dart';
import '../../services/focus_session_service.dart';
import '../../services/supabase_auth_service.dart';
import '../../theme.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/glass_button.dart';
import '../../widgets/loading_state_widget.dart';
import '../../widgets/error_state_widget.dart';
import '../../widgets/skeleton_loader.dart';
import 'package:go_router/go_router.dart';

/// FocusPage Class
/// Tác dụng: Màn hình focus với Pomodoro timer để tập trung làm việc
/// Sử dụng khi: Người dùng muốn bắt đầu phiên làm việc tập trung với timer
class FocusPage extends StatefulWidget {
  const FocusPage({super.key});

  @override
  State<FocusPage> createState() => _FocusPageState();
}

/// _FocusPageState Class
/// Tác dụng: State class quản lý trạng thái timer, task selection và focus session
/// Sử dụng khi: Cần quản lý logic timer, tracking focus sessions và task selection
class _FocusPageState extends State<FocusPage> {
  String? _selectedTaskId;
  String? _selectedTaskTitle;
  int? _selectedTaskFocusTime; // Thời gian focus từ task được chọn

  // Thêm các biến cần thiết cho focus session
  String? _currentTaskId;
  int _workDuration = 25 * 60; // 25 phút tính bằng giây
  DateTime? _sessionStartTime;
  int _distractionCount = 0;

  @override
  void initState() {
    super.initState();
    // Load focus sessions when page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FocusSessionModel>().loadFocusSessions();
    });
  }

  /// _showTaskSelector Method
  /// Tác dụng: Hiển thị modal bottom sheet để chọn task cho phiên focus
  /// Sử dụng khi: Người dùng muốn chọn task cụ thể để focus
  void _showTaskSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  'Chọn nhiệm vụ để tập trung',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                // Task list
                Expanded(
                  child: Consumer<TaskModel>(
                    builder: (context, taskModel, child) {
                      if (taskModel.isLoading) {
                        return const FocusSessionSkeleton();
                      }

                      final tasks = taskModel.tasks
                          .where((task) => !task.isCompleted)
                          .toList();

                      if (tasks.isEmpty) {
                        return ErrorStateWidget.empty(
                          title: 'Không có nhiệm vụ nào',
                          message: 'Tạo nhiệm vụ mới để bắt đầu tập trung',
                          icon: Icons.task_alt,
                          useGlassEffect: true,
                          customAction: Semantics(
                            label: 'Tạo nhiệm vụ mới',
                            hint: 'Nhấn để tạo nhiệm vụ mới',
                            child: FilledButton.icon(
                              onPressed: () {
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
                                        width:
                                            MediaQuery.of(context).size.width *
                                            0.9,
                                        constraints: const BoxConstraints(
                                          maxWidth: 400,
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            // Header with icon
                                            Container(
                                              width: 64,
                                              height: 64,
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                              child: const Center(
                                                child: Text(
                                                  '📝',
                                                  style: TextStyle(
                                                    fontSize: 32,
                                                  ),
                                                ),
                                              ),
                                            ),

                                            const SizedBox(height: 20),

                                            // Title
                                            Text(
                                              'Tạo nhiệm vụ mới',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headlineSmall
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                              textAlign: TextAlign.center,
                                            ),

                                            const SizedBox(height: 12),

                                            // Message
                                            Text(
                                              'Chức năng tạo nhiệm vụ sẽ được bổ sung trong phiên bản tiếp theo.',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSurface
                                                        .withOpacity(0.7),
                                                  ),
                                              textAlign: TextAlign.center,
                                            ),

                                            const SizedBox(height: 24),

                                            // Action button
                                            SizedBox(
                                              width: double.infinity,
                                              child: Semantics(
                                                label: 'Đóng dialog',
                                                hint: 'Nhấn để đóng thông báo',
                                                child: GlassElevatedButton(
                                                  onPressed: () => Navigator.of(
                                                    context,
                                                  ).pop(),
                                                  child: const Text('Đóng'),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('Tạo nhiệm vụ'),
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        controller: scrollController,
                        itemCount:
                            tasks.length +
                            1, // +1 for "No specific task" option
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            // "No specific task" option
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.08),
                                  child: Icon(
                                    Icons.timer,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.7),
                                  ),
                                ),
                                title: const Text('Tập trung tự do'),
                                subtitle: const Text(
                                  'Không liên kết với nhiệm vụ cụ thể',
                                ),
                                onTap: () {
                                  setState(() {
                                    _selectedTaskId = null;
                                    _selectedTaskTitle = null;
                                    _selectedTaskFocusTime =
                                        null; // Reset thời gian focus
                                  });
                                  context.pop();
                                },
                              ),
                            );
                          }

                          final task = tasks[index - 1];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppTheme.primaryColor
                                    .withOpacity(0.1),
                                child: Icon(
                                  Icons.task_alt,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                              title: Text(task.title),
                              subtitle: task.description?.isNotEmpty == true
                                  ? Text(task.description!)
                                  : null,
                              trailing: task.priority != null
                                  ? Chip(
                                      label: Text(
                                        task.priority.displayName,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      backgroundColor: task.priority.color
                                          .withOpacity(0.1),
                                      side: BorderSide(
                                        color: task.priority.color,
                                      ),
                                    )
                                  : null,
                              onTap: () {
                                setState(() {
                                  _selectedTaskId = task.id;
                                  _selectedTaskTitle = task.title;
                                  _selectedTaskFocusTime = task
                                      .focusTimeMinutes; // Lấy thời gian focus từ task
                                });
                                context.pop();
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          // Thêm bottom padding để tránh chồng lấp với nav bar nổi
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 140),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tập trung',
                        style: Theme.of(context).textTheme.headlineLarge
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                      ),
                      Text(
                        'Pomodoro Timer',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                  GlassIconButton(
                    onPressed: _showTaskSelector,
                    icon: Icons.task_alt,
                    tooltip: 'Chọn nhiệm vụ',
                    iconColor: AppTheme.primaryColor,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Selected task info
              if (_selectedTaskTitle != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.task_alt, color: AppTheme.primaryColor),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Nhiệm vụ hiện tại',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: AppTheme.primaryColor.withValues(
                                      alpha: 0.8,
                                    ),
                                  ),
                            ),
                            Text(
                              _selectedTaskTitle!,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      GlassIconButton(
                        onPressed: () => context.pop(),
                        icon: Icons.close,
                        size: 20,
                        iconColor: AppTheme.primaryColor,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Pomodoro Timer với hiệu ứng Liquid Glass
              GlassContainer(
                borderRadius: 24,
                blur: 24,
                opacity: 0.14, // đồng nhất mức trong suốt
                padding: const EdgeInsets.all(20),
                child: PomodoroTimerWidget(
                  taskId: _selectedTaskId,
                  taskTitle: _selectedTaskTitle,
                  initialWorkDuration:
                      _selectedTaskFocusTime ??
                      25, // Sử dụng thời gian focus từ task hoặc mặc định 25 phút
                  onSessionComplete: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('🎉 Hoàn thành phiên tập trung!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  onBreakComplete: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('⏰ Hết giờ nghỉ ngơi!'),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Focus Session Statistics
              Consumer<FocusSessionModel>(
                builder: (context, focusModel, child) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Thống kê hôm nay',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              'Phiên hoàn thành',
                              '${focusModel.focusSessions.length}',
                              Icons.check_circle,
                              Colors.green,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              'Tổng thời gian',
                              '120p',
                              Icons.timer,
                              Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              'Streak hiện tại',
                              '${focusModel.focusSessions.length} phiên',
                              Icons.local_fire_department,
                              Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              'Hiệu suất',
                              '4.2/5',
                              Icons.trending_up,
                              Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    // Cố định chiều cao để đồng bộ "kích thước nguyên khung"
    return SizedBox(
      height: 110,
      child: GlassContainer(
        borderRadius: 16,
        blur: 12,
        opacity: 0.14, // thống nhất mức trong suốt
        padding: const EdgeInsets.all(12), // giảm padding để card nhỏ gọn hơn
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: color.withOpacity(0.8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PyramidPainter extends CustomPainter {
  final int currentLevel;
  final bool isRunning;
  final double animationValue;
  final double fallAnimationValue;
  final Color phaseColor;
  final Color primaryColor;
  final Color onSurfaceColor;

  PyramidPainter({
    required this.currentLevel,
    required this.isRunning,
    required this.phaseColor,
    required this.primaryColor,
    required this.onSurfaceColor,
    this.animationValue = 1.0,
    this.fallAnimationValue = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final fillPaint = Paint()..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final pyramidHeight = size.height * 0.6;
    final pyramidWidth = size.width * 0.7;

    // Vẽ kim tự tháp với 4 bậc (hiệu ứng rơi từ trên xuống)
    for (int level = 4; level >= 1; level--) {
      final levelHeight = pyramidHeight / 4;
      final levelWidth =
          pyramidWidth * (5 - level) / 4; // Giảm dần từ dưới lên trên

      final bottom = center.dy + pyramidHeight / 2 - (level - 1) * levelHeight;
      final top = bottom - levelHeight;
      final left = center.dx - levelWidth / 2;
      final right = center.dx + levelWidth / 2;

      // Hiệu ứng rơi: tầng sẽ rơi từ trên xuống khi đến lượt nó
      double fallOffset = 0.0;
      if (level <= currentLevel) {
        // Tính toán độ rơi dựa trên fallAnimationValue
        final fallDistance = pyramidHeight * 0.3; // Khoảng cách rơi
        fallOffset = fallDistance * (1.0 - fallAnimationValue);
      }

      // Màu sắc dựa trên level hiện tại
      if (level <= currentLevel) {
        // Bậc đã rơi - màu chính với hiệu ứng pulse khi đang chạy
        final opacity = isRunning ? 0.6 + (0.4 * animationValue) : 0.8;
        fillPaint.color = primaryColor.withOpacity(opacity);
        paint.color = primaryColor;
      } else {
        // Bậc chưa rơi - màu xám nhạt
        fillPaint.color = onSurfaceColor.withOpacity(0.3);
        paint.color = onSurfaceColor.withOpacity(0.5);
      }

      // Vẽ hình thang cho mỗi bậc với hiệu ứng rơi
      final path = Path();

      if (level == 4) {
        // Bậc trên cùng - tam giác
        path.moveTo(center.dx, top - fallOffset);
        path.lineTo(left, bottom - fallOffset);
        path.lineTo(right, bottom - fallOffset);
        path.close();
      } else {
        // Các bậc khác - hình thang
        final nextLevelWidth = pyramidWidth * (4 - level) / 4;
        final nextLeft = center.dx - nextLevelWidth / 2;
        final nextRight = center.dx + nextLevelWidth / 2;

        path.moveTo(nextLeft, top - fallOffset);
        path.lineTo(nextRight, top - fallOffset);
        path.lineTo(right, bottom - fallOffset);
        path.lineTo(left, bottom - fallOffset);
        path.close();
      }

      canvas.drawPath(path, fillPaint);
      canvas.drawPath(path, paint);
    }

    // Vẽ viền ngoài của toàn bộ kim tự tháp
    final outerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = primaryColor;

    final outerPath = Path();
    outerPath.moveTo(center.dx, center.dy - pyramidHeight / 2);
    outerPath.lineTo(
      center.dx - pyramidWidth / 2,
      center.dy + pyramidHeight / 2,
    );
    outerPath.lineTo(
      center.dx + pyramidWidth / 2,
      center.dy + pyramidHeight / 2,
    );
    outerPath.close();

    canvas.drawPath(outerPath, outerPaint);
  }

  @override
  bool shouldRepaint(covariant PyramidPainter oldDelegate) {
    return oldDelegate.currentLevel != currentLevel ||
        oldDelegate.isRunning != isRunning ||
        oldDelegate.animationValue != animationValue ||
        oldDelegate.fallAnimationValue != fallAnimationValue;
  }
}

