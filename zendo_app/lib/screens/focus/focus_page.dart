import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/pomodoro_timer_widget.dart';
import '../../providers/focus_session_model.dart';
import '../../providers/task_model.dart';
import '../../models/focus_session.dart';
import '../../services/focus_session_service.dart';
import '../../services/supabase_auth_service.dart';
import '../../theme.dart';

class FocusPage extends StatefulWidget {
  const FocusPage({super.key});

  @override
  State<FocusPage> createState() => _FocusPageState();
}

class _FocusPageState extends State<FocusPage> {
  String? _selectedTaskId;
  String? _selectedTaskTitle;
  
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
                    color: Colors.grey[300],
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
                        return const Center(child: CircularProgressIndicator());
                      }
                      
                      final tasks = taskModel.tasks.where((task) => !task.isCompleted).toList();
                      
                      if (tasks.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.task_alt,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Không có nhiệm vụ nào',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tạo nhiệm vụ mới để bắt đầu tập trung',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[500],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      }
                      
                      return ListView.builder(
                        controller: scrollController,
                        itemCount: tasks.length + 1, // +1 for "No specific task" option
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            // "No specific task" option
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.grey[200],
                                  child: const Icon(Icons.timer, color: Colors.grey),
                                ),
                                title: const Text('Tập trung tự do'),
                                subtitle: const Text('Không liên kết với nhiệm vụ cụ thể'),
                                onTap: () {
                                  setState(() {
                                    _selectedTaskId = null;
                                    _selectedTaskTitle = null;
                                  });
                                  Navigator.pop(context);
                                },
                              ),
                            );
                          }
                          
                          final task = tasks[index - 1];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
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
                                        task.priority!.displayName,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      backgroundColor: task.priority!.color.withValues(alpha: 0.1),
                                      side: BorderSide(color: task.priority!.color),
                                    )
                                  : null,
                              onTap: () {
                                setState(() {
                                  _selectedTaskId = task.id;
                                  _selectedTaskTitle = task.title;
                                });
                                Navigator.pop(context);
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
          padding: const EdgeInsets.all(20),
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
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      Text(
                        'Pomodoro Timer',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: _showTaskSelector,
                    icon: const Icon(Icons.task_alt),
                    tooltip: 'Chọn nhiệm vụ',
                    style: IconButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                      foregroundColor: AppTheme.primaryColor,
                    ),
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
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.primaryColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.task_alt,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Nhiệm vụ hiện tại',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.primaryColor.withValues(alpha: 0.8),
                              ),
                            ),
                            Text(
                              _selectedTaskTitle!,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _selectedTaskId = null;
                            _selectedTaskTitle = null;
                          });
                        },
                        icon: const Icon(Icons.close),
                        iconSize: 20,
                        color: AppTheme.primaryColor,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Pomodoro Timer Widget
              PomodoroTimerWidget(
                taskId: _selectedTaskId,
                taskTitle: _selectedTaskTitle,
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
                    const SnackBar(
                      content: Text('⏰ Hết giờ nghỉ ngơi!'),
                      backgroundColor: Colors.blue,
                    ),
                  );
                },
              ),

              const SizedBox(height: 30),

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
                      const SizedBox(height: 16),
                      
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
                              Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 12),
                      
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
                              Colors.purple,
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

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
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

  PyramidPainter({
    required this.currentLevel,
    required this.isRunning,
    required this.phaseColor,
    this.animationValue = 1.0,
    this.fallAnimationValue = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final fillPaint = Paint()
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final pyramidHeight = size.height * 0.6;
    final pyramidWidth = size.width * 0.7;

    // Vẽ kim tự tháp với 4 bậc (hiệu ứng rơi từ trên xuống)
    for (int level = 4; level >= 1; level--) {
      final levelHeight = pyramidHeight / 4;
      final levelWidth = pyramidWidth * (5 - level) / 4; // Giảm dần từ dưới lên trên
      
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
        fillPaint.color = const Color(0xFF6366F1).withValues(alpha: opacity);
        paint.color = const Color(0xFF6366F1);
      } else {
        // Bậc chưa rơi - màu xám nhạt
        fillPaint.color = const Color(0xFFE5E7EB).withValues(alpha: 0.3);
        paint.color = const Color(0xFFE5E7EB).withValues(alpha: 0.5);
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
      ..color = const Color(0xFF6366F1);

    final outerPath = Path();
    outerPath.moveTo(center.dx, center.dy - pyramidHeight / 2);
    outerPath.lineTo(center.dx - pyramidWidth / 2, center.dy + pyramidHeight / 2);
    outerPath.lineTo(center.dx + pyramidWidth / 2, center.dy + pyramidHeight / 2);
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

// Extension method for FocusPage to save focus session
extension FocusPageExtension on _FocusPageState {
  /// Lưu focus session vào database khi hoàn thành work session
  Future<void> _saveFocusSession() async {
    if (_sessionStartTime == null) return;
    
    try {
      final endTime = DateTime.now();
      final duration = endTime.difference(_sessionStartTime!).inMinutes;
      
      // Chỉ lưu session nếu thời gian >= 1 phút
      if (duration < 1) return;
      
      final authService = SupabaseAuthService();
      final user = authService.currentUser;
      
      if (user == null) {
        print('User not authenticated, cannot save focus session');
        return;
      }
      
      final focusSession = FocusSession(
        id: null, // Supabase sẽ tự generate
        userId: user.id,
        taskId: _currentTaskId, // Có thể null nếu không có task cụ thể
        plannedDurationMinutes: _workDuration ~/ 60,
        actualDurationMinutes: duration,
        startedAt: _sessionStartTime!,
        endedAt: endTime,
        status: FocusSessionStatus.completed,
        distractionCount: _distractionCount,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      final databaseService = FocusSessionService();
      await databaseService.createFocusSession(focusSession);
      
      print('Focus session saved successfully: ${duration} minutes');
    } catch (e) {
      print('Error saving focus session: $e');
    }
  }
}