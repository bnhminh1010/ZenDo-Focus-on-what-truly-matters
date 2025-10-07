import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import '../../theme.dart';
import '../../widgets/circular_time_picker.dart';
import '../../models/focus_session.dart';
import '../../services/supabase_database_service.dart';
import '../../services/supabase_auth_service.dart';

enum PomodoroPhase { work, shortBreak, longBreak }

class FocusPage extends StatefulWidget {
  const FocusPage({super.key});

  @override
  State<FocusPage> createState() => _FocusPageState();
}

class _FocusPageState extends State<FocusPage>
    with TickerProviderStateMixin {
  Timer? _timer;
  
  // Pomodoro settings
  int _workDuration = 25 * 60; // 25 minutes
  int _shortBreakDuration = 5 * 60; // 5 minutes
  int _longBreakDuration = 15 * 60; // 15 minutes
  
  // Current session state
  PomodoroPhase _currentPhase = PomodoroPhase.work;
  int _currentSeconds = 25 * 60;
  int _totalSeconds = 25 * 60;
  bool _isRunning = false;
  bool _isPaused = false;
  
  // Pomodoro cycle tracking
  int _completedPomodoros = 0;
  int _distractionCount = 0;
  
  // Session tracking
  DateTime? _sessionStartTime;
  String? _currentTaskId;
  
  // Pyramid levels (4 levels total)
  int _currentLevel = 0;
  
  late AnimationController _pulseController;
  late AnimationController _levelController;
  late AnimationController _fallController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _levelAnimation;
  late Animation<double> _fallAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _pulseController.repeat(reverse: true);
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _levelController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _levelAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _levelController,
      curve: Curves.elasticOut,
    ));
    
    _fallController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fallAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fallController,
      curve: Curves.bounceOut,
    ));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _levelController.dispose();
    _fallController.dispose();
    super.dispose();
  }

  void _startTimer() {
    if (_currentSeconds <= 0) return;
    
    setState(() {
      _isRunning = true;
      _isPaused = false;
      // Track session start time when starting a work session
      if (_currentPhase == PomodoroPhase.work && _sessionStartTime == null) {
        _sessionStartTime = DateTime.now();
      }
    });
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_currentSeconds > 0) {
          _currentSeconds--;
          
          // Calculate pyramid level based on elapsed time
          final quarterTime = _totalSeconds / 4;
          final timeElapsed = _totalSeconds - _currentSeconds;
          final newLevel = (timeElapsed / quarterTime).floor();
          
          if (newLevel != _currentLevel && newLevel <= 4) {
            _currentLevel = newLevel;
            _fallController.reset();
            _fallController.forward();
          }
        } else {
          _timer?.cancel();
          _isRunning = false;
          _onTimerComplete();
        }
      });
    });
  }

  void _pauseTimer() {
    setState(() {
      _isPaused = true;
      _isRunning = false;
    });
    _timer?.cancel();
    _pulseController.stop();
  }

  void _stopTimer() {
    setState(() {
      _isRunning = false;
      _isPaused = false;
      _currentSeconds = _totalSeconds;
      _currentLevel = 0;
    });
    _timer?.cancel();
    _pulseController.stop();
    _pulseController.reset();
  }

  void _onTimerComplete() {
    if (_currentPhase == PomodoroPhase.work) {
      _completedPomodoros++;
      // Save focus session when work session completes
      _saveFocusSession();
      
      // After 4 pomodoros, take a long break
      if (_completedPomodoros % 4 == 0) {
        _startBreak(isLong: true);
      } else {
        _startBreak(isLong: false);
      }
      _showProductivityRatingDialog();
    } else {
      // Break completed, start work session
      _startWorkSession();
    }
  }

  void _startWorkSession() {
    setState(() {
      _currentPhase = PomodoroPhase.work;
      _totalSeconds = _workDuration;
      _currentSeconds = _workDuration;
      _currentLevel = 0;
      // Reset session tracking for new work session
      _sessionStartTime = null;
    });
  }

  void _startBreak({required bool isLong}) {
    setState(() {
      _currentPhase = isLong ? PomodoroPhase.longBreak : PomodoroPhase.shortBreak;
      _totalSeconds = isLong ? _longBreakDuration : _shortBreakDuration;
      _currentSeconds = _totalSeconds;
      _currentLevel = 0;
    });
    _showBreakDialog(isLong: isLong);
  }

  void _showBreakDialog({required bool isLong}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(isLong ? '🎉 Nghỉ dài!' : '☕ Nghỉ ngắn!'),
        content: Text(
          isLong 
            ? 'Bạn đã hoàn thành 4 pomodoro! Hãy nghỉ ngơi ${_longBreakDuration ~/ 60} phút.'
            : 'Hãy nghỉ ngơi ${_shortBreakDuration ~/ 60} phút trước khi tiếp tục.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _startTimer();
            },
            child: const Text('Bắt đầu nghỉ'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _startWorkSession();
            },
            child: const Text('Bỏ qua nghỉ'),
          ),
        ],
      ),
    );
  }

  void _showProductivityRatingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('🎯 Đánh giá năng suất'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Bạn cảm thấy phiên làm việc này như thế nào?'),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                    _saveProductivityRating(index + 1);
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 10),
            const Text(
              '1 = Kém, 5 = Xuất sắc',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  void _saveProductivityRating(int rating) {
    // TODO: Save to database
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã lưu đánh giá: $rating/5 ⭐'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _addDistraction() {
    setState(() {
      _distractionCount++;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã ghi nhận phâm tâm 📱'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String _getPhaseTitle() {
    switch (_currentPhase) {
      case PomodoroPhase.work:
        return 'Làm việc';
      case PomodoroPhase.shortBreak:
        return 'Nghỉ ngắn';
      case PomodoroPhase.longBreak:
        return 'Nghỉ dài';
    }
  }

  Color _getPhaseColor() {
    switch (_currentPhase) {
      case PomodoroPhase.work:
        return const Color(0xFF6366F1);
      case PomodoroPhase.shortBreak:
        return const Color(0xFF10B981);
      case PomodoroPhase.longBreak:
        return const Color(0xFF8B5CF6);
    }
  }

  void _showTimePicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Chọn thời gian Focus',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                CircularTimePicker(
                  initialDuration: Duration(seconds: _workDuration),
                  minDuration: const Duration(minutes: 5),
                  maxDuration: const Duration(hours: 3),
                  primaryColor: _getPhaseColor(),
                  onDurationChanged: (Duration duration) {
                    setState(() {
                      _workDuration = duration.inSeconds;
                      if (_currentPhase == PomodoroPhase.work && !_isRunning) {
                        _currentSeconds = _workDuration;
                        _totalSeconds = _workDuration;
                      }
                    });
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Hủy'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Xác nhận'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = 1.0 - (_currentSeconds / _totalSeconds);
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header with Pomodoro info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getPhaseTitle(),
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: _getPhaseColor(),
                        ),
                      ),
                      Text(
                        'Pomodoro ${_completedPomodoros + 1}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_horiz, 
                      color: Theme.of(context).colorScheme.onSurface, 
                      size: 24
                    ),
                    onSelected: (value) {
                      if (value == 'settings') {
                        _showPomodoroSettings();
                      } else if (value == 'reset') {
                        _resetPomodoro();
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'settings', child: Text('Cài đặt Pomodoro')),
                      const PopupMenuItem(value: 'reset', child: Text('Đặt lại chu kỳ')),
                    ],
                  ),
                ],
              ),
            ),
            
            // Stats row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatCard('Hoàn thành', '$_completedPomodoros', Icons.check_circle),
                  _buildStatCard('Phâm tâm', '$_distractionCount', Icons.phone_android),
                  _buildStatCard('Chu kỳ', '${(_completedPomodoros / 4).floor() + 1}', Icons.refresh),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Main content - centered pyramid
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Triangle Timer
                    SizedBox(
                      width: 300,
                      height: 300,
                      child: AnimatedBuilder(
                        animation: Listenable.merge([_levelAnimation, _fallAnimation]),
                        builder: (context, child) {
                          return CustomPaint(
                            painter: PyramidPainter(
                              currentLevel: _currentLevel,
                              isRunning: _isRunning,
                              animationValue: _levelAnimation.value,
                              fallAnimationValue: _fallAnimation.value,
                              phaseColor: _getPhaseColor(),
                            ),
                          );
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Timer display - clickable to open time picker
                    GestureDetector(
                      onTap: !_isRunning && !_isPaused ? _showTimePicker : null,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: !_isRunning && !_isPaused 
                              ? _getPhaseColor().withOpacity(0.1)
                              : Colors.transparent,
                          border: !_isRunning && !_isPaused 
                              ? Border.all(color: _getPhaseColor().withOpacity(0.3))
                              : null,
                        ),
                        child: Column(
                          children: [
                            Text(
                              _formatTime(_currentSeconds),
                              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                fontWeight: FontWeight.w300,
                                color: _getPhaseColor(),
                                letterSpacing: 2,
                              ),
                            ),
                            if (!_isRunning && !_isPaused)
                              Text(
                                'Chạm để chọn thời gian',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: _getPhaseColor().withOpacity(0.7),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Control buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Distraction button (only during work phase)
                        if (_currentPhase == PomodoroPhase.work && _isRunning) ...[
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.orange),
                            ),
                            child: IconButton(
                              onPressed: _addDistraction,
                              icon: const Icon(
                                Icons.phone_android,
                                color: Colors.orange,
                                size: 24,
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                        ],
                        
                        // Main play/pause button
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: _getPhaseColor(),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            onPressed: () {
                              if (_isRunning) {
                                _pauseTimer();
                              } else if (_isPaused) {
                                _startTimer();
                              } else {
                                _startTimer();
                              }
                            },
                            icon: Icon(
                              _isRunning ? Icons.pause : Icons.play_arrow,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        ),
                        
                        // Stop button
                        if (_isRunning || _isPaused) ...[
                          const SizedBox(width: 20),
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.red),
                            ),
                            child: IconButton(
                              onPressed: _stopTimer,
                              icon: const Icon(
                                Icons.stop,
                                color: Colors.red,
                                size: 24,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Status text
                    Text(
                      _isRunning
                          ? (_currentPhase == PomodoroPhase.work ? 'Đang tập trung...' : 'Đang nghỉ ngơi...')
                          : _isPaused
                              ? 'Tạm dừng'
                              : 'Sẵn sàng để bắt đầu',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  void _showPomodoroSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cài đặt Pomodoro'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Thời gian làm việc'),
              subtitle: Text('${_workDuration ~/ 60} phút'),
              trailing: const Icon(Icons.edit),
              onTap: () => _showDurationPicker('work'),
            ),
            ListTile(
              title: const Text('Nghỉ ngắn'),
              subtitle: Text('${_shortBreakDuration ~/ 60} phút'),
              trailing: const Icon(Icons.edit),
              onTap: () => _showDurationPicker('short'),
            ),
            ListTile(
              title: const Text('Nghỉ dài'),
              subtitle: Text('${_longBreakDuration ~/ 60} phút'),
              trailing: const Icon(Icons.edit),
              onTap: () => _showDurationPicker('long'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showDurationPicker(String type) {
    // Simple duration picker implementation
    Navigator.pop(context); // Close settings dialog first
    
    final durations = [5, 10, 15, 20, 25, 30, 45, 60];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Chọn thời gian ${type == 'work' ? 'làm việc' : type == 'short' ? 'nghỉ ngắn' : 'nghỉ dài'}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: durations.map((duration) => ListTile(
            title: Text('$duration phút'),
            onTap: () {
              setState(() {
                if (type == 'work') {
                  _workDuration = duration * 60;
                  if (_currentPhase == PomodoroPhase.work && !_isRunning && !_isPaused) {
                    _currentSeconds = _workDuration;
                    _totalSeconds = _workDuration;
                  }
                } else if (type == 'short') {
                  _shortBreakDuration = duration * 60;
                } else {
                  _longBreakDuration = duration * 60;
                }
              });
              Navigator.pop(context);
            },
          )).toList(),
        ),
      ),
    );
  }

  void _resetPomodoro() {
    setState(() {
      _completedPomodoros = 0;
      _distractionCount = 0;
      _currentPhase = PomodoroPhase.work;
      _totalSeconds = _workDuration;
      _currentSeconds = _workDuration;
      _currentLevel = 0;
      _isRunning = false;
      _isPaused = false;
    });
    _timer?.cancel();
    _pulseController.stop();
    _pulseController.reset();
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
        fillPaint.color = const Color(0xFF6366F1).withOpacity(opacity);
        paint.color = const Color(0xFF6366F1);
      } else {
        // Bậc chưa rơi - màu xám nhạt
        fillPaint.color = const Color(0xFFE5E7EB).withOpacity(0.3);
        paint.color = const Color(0xFFE5E7EB).withOpacity(0.5);
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
      
      final databaseService = SupabaseDatabaseService();
      await databaseService.createFocusSession(focusSession);
      
      print('Focus session saved successfully: ${duration} minutes');
    } catch (e) {
      print('Error saving focus session: $e');
    }
  }
}