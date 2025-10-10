import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../models/focus_session.dart';
import '../providers/focus_session_model.dart';
import '../theme.dart';
import 'pyramid_timer_widget.dart';

/// Widget Pomodoro Timer có thể tái sử dụng
class PomodoroTimerWidget extends StatefulWidget {
  final String? taskId;
  final String? taskTitle;
  final int initialWorkDuration; // phút
  final int initialShortBreakDuration; // phút
  final int initialLongBreakDuration; // phút
  final int sessionsBeforeLongBreak;
  final VoidCallback? onSessionComplete;
  final VoidCallback? onBreakComplete;
  final bool autoStartBreaks;
  final bool autoStartWork;

  const PomodoroTimerWidget({
    super.key,
    this.taskId,
    this.taskTitle,
    this.initialWorkDuration = 25,
    this.initialShortBreakDuration = 5,
    this.initialLongBreakDuration = 15,
    this.sessionsBeforeLongBreak = 4,
    this.onSessionComplete,
    this.onBreakComplete,
    this.autoStartBreaks = false,
    this.autoStartWork = false,
  });

  @override
  State<PomodoroTimerWidget> createState() => _PomodoroTimerWidgetState();
}

class _PomodoroTimerWidgetState extends State<PomodoroTimerWidget>
    with TickerProviderStateMixin {
  Timer? _timer;
  
  // Pomodoro settings
  late int _workDuration;
  late int _shortBreakDuration;
  late int _longBreakDuration;
  
  // Current session state
  PomodoroPhase _currentPhase = PomodoroPhase.work;
  int _currentSeconds = 0;
  int _totalSeconds = 0;
  bool _isRunning = false;
  bool _isPaused = false;
  
  // Pomodoro cycle tracking
  int _completedPomodoros = 0;
  int _distractionCount = 0;
  
  // Session tracking
  DateTime? _sessionStartTime;
  String? _currentSessionId;
  
  // Animations
  late AnimationController _pulseController;
  late AnimationController _progressController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _initializeSettings();
    _initializeAnimations();
    _resetTimer();
  }

  void _initializeSettings() {
    _workDuration = widget.initialWorkDuration * 60;
    _shortBreakDuration = widget.initialShortBreakDuration * 60;
    _longBreakDuration = widget.initialLongBreakDuration * 60;
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
    
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));
  }

  void _resetTimer() {
    switch (_currentPhase) {
      case PomodoroPhase.work:
        _currentSeconds = _workDuration;
        _totalSeconds = _workDuration;
        break;
      case PomodoroPhase.shortBreak:
        _currentSeconds = _shortBreakDuration;
        _totalSeconds = _shortBreakDuration;
        break;
      case PomodoroPhase.longBreak:
        _currentSeconds = _longBreakDuration;
        _totalSeconds = _longBreakDuration;
        break;
    }
    _updateProgress();
  }

  void _updateProgress() {
    final progress = _totalSeconds > 0 ? (_totalSeconds - _currentSeconds) / _totalSeconds : 0.0;
    _progressController.animateTo(progress);
  }

  void _startTimer() async {
    if (_isRunning) return;

    setState(() {
      _isRunning = true;
      _isPaused = false;
    });

    // Tạo focus session nếu là work phase
    if (_currentPhase == PomodoroPhase.work && _sessionStartTime == null) {
      _sessionStartTime = DateTime.now();
      final focusModel = context.read<FocusSessionModel>();
      final session = await focusModel.createFocusSession(
        taskId: widget.taskId,
        title: widget.taskTitle ?? _getPhaseTitle(),
        plannedDurationMinutes: widget.initialWorkDuration,
      );
      _currentSessionId = session?.id;
    }

    _pulseController.repeat(reverse: true);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_currentSeconds > 0) {
          _currentSeconds--;
          _updateProgress();
        } else {
          _onTimerComplete();
        }
      });
    });
  }

  void _pauseTimer() {
    if (!_isRunning) return;

    setState(() {
      _isRunning = false;
      _isPaused = true;
    });

    _timer?.cancel();
    _pulseController.stop();

    // Pause focus session nếu có
    if (_currentSessionId != null && _currentPhase == PomodoroPhase.work) {
      context.read<FocusSessionModel>().pauseFocusSession(_currentSessionId!);
    }
  }

  void _resumeTimer() {
    if (_isRunning || !_isPaused) return;

    // Resume focus session nếu có
    if (_currentSessionId != null && _currentPhase == PomodoroPhase.work) {
      context.read<FocusSessionModel>().resumeFocusSession(_currentSessionId!);
    }

    _startTimer();
  }

  void _stopTimer() {
    setState(() {
      _isRunning = false;
      _isPaused = false;
    });

    _timer?.cancel();
    _pulseController.stop();

    // Cancel focus session nếu có
    if (_currentSessionId != null && _currentPhase == PomodoroPhase.work) {
      context.read<FocusSessionModel>().cancelFocusSession(_currentSessionId!);
      _currentSessionId = null;
      _sessionStartTime = null;
    }

    _resetTimer();
  }

  void _onTimerComplete() {
    _timer?.cancel();
    _pulseController.stop();
    
    setState(() {
      _isRunning = false;
      _isPaused = false;
    });

    if (_currentPhase == PomodoroPhase.work) {
      _completedPomodoros++;
      
      // Complete focus session
      if (_currentSessionId != null) {
        final actualDuration = _sessionStartTime != null 
            ? DateTime.now().difference(_sessionStartTime!).inMinutes
            : widget.initialWorkDuration;
            
        context.read<FocusSessionModel>().completeFocusSession(
          _currentSessionId!,
          actualDurationMinutes: actualDuration,
          distractionCount: _distractionCount,
        );
        
        _currentSessionId = null;
        _sessionStartTime = null;
      }

      widget.onSessionComplete?.call();
      
      // Chuyển sang break
      if (_completedPomodoros % widget.sessionsBeforeLongBreak == 0) {
        _currentPhase = PomodoroPhase.longBreak;
      } else {
        _currentPhase = PomodoroPhase.shortBreak;
      }
    } else {
      widget.onBreakComplete?.call();
      _currentPhase = PomodoroPhase.work;
    }

    _resetTimer();

    // Auto start nếu được bật
    if ((_currentPhase != PomodoroPhase.work && widget.autoStartBreaks) ||
        (_currentPhase == PomodoroPhase.work && widget.autoStartWork)) {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) _startTimer();
      });
    }

    // Hiển thị notification
    _showPhaseCompleteDialog();
  }

  void _showPhaseCompleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_getPhaseCompleteTitle()),
        content: Text(_getPhaseCompleteMessage()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
          if (!_isAutoStartEnabled())
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _startTimer();
              },
              child: Text(_getStartButtonText()),
            ),
        ],
      ),
    );
  }

  void _addDistraction() {
    setState(() {
      _distractionCount++;
    });
  }

  void _skipPhase() {
    _onTimerComplete();
  }

  // Helper methods
  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String _getPhaseTitle() {
    switch (_currentPhase) {
      case PomodoroPhase.work:
        return 'Tập trung';
      case PomodoroPhase.shortBreak:
        return 'Nghỉ ngắn';
      case PomodoroPhase.longBreak:
        return 'Nghỉ dài';
    }
  }

  String _getPhaseCompleteTitle() {
    switch (_currentPhase) {
      case PomodoroPhase.work:
        return 'Hoàn thành phiên nghỉ!';
      case PomodoroPhase.shortBreak:
      case PomodoroPhase.longBreak:
        return 'Hoàn thành phiên tập trung!';
    }
  }

  String _getPhaseCompleteMessage() {
    switch (_currentPhase) {
      case PomodoroPhase.work:
        return 'Bạn đã hoàn thành phiên nghỉ. Sẵn sàng tập trung tiếp?';
      case PomodoroPhase.shortBreak:
        return 'Bạn đã hoàn thành phiên tập trung! Hãy nghỉ ngắn.';
      case PomodoroPhase.longBreak:
        return 'Bạn đã hoàn thành ${widget.sessionsBeforeLongBreak} phiên! Hãy nghỉ dài.';
    }
  }

  String _getStartButtonText() {
    switch (_currentPhase) {
      case PomodoroPhase.work:
        return 'Bắt đầu tập trung';
      case PomodoroPhase.shortBreak:
        return 'Bắt đầu nghỉ ngắn';
      case PomodoroPhase.longBreak:
        return 'Bắt đầu nghỉ dài';
    }
  }

  bool _isAutoStartEnabled() {
    return (_currentPhase != PomodoroPhase.work && widget.autoStartBreaks) ||
           (_currentPhase == PomodoroPhase.work && widget.autoStartWork);
  }

  Color _getPhaseColor() {
    switch (_currentPhase) {
      case PomodoroPhase.work:
        return AppTheme.primaryColor;
      case PomodoroPhase.shortBreak:
        return Colors.green;
      case PomodoroPhase.longBreak:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Phase title
            Text(
              _getPhaseTitle(),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: _getPhaseColor(),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            // Task title (if provided)
            if (widget.taskTitle != null) ...[
              Text(
                widget.taskTitle!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
            ],

            // Pyramid Timer thay vì Timer circle
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _isRunning ? _pulseAnimation.value : 1.0,
                  child: PyramidTimerWidget(
                    progress: _progressAnimation.value,
                    activeColor: Colors.purple, // Màu tím cho phần active
                    inactiveColor: Colors.grey[400]!, // Màu xám cho phần inactive
                    size: 200,
                    timeText: _formatTime(_currentSeconds),
                    subText: '$_completedPomodoros phiên hoàn thành',
                    onTimeTap: _showTimePicker, // Thêm callback để chọn thời gian
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Control buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Start/Pause button
                ElevatedButton.icon(
                  onPressed: _isRunning ? _pauseTimer : (_isPaused ? _resumeTimer : _startTimer),
                  icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                  label: Text(_isRunning ? 'Tạm dừng' : (_isPaused ? 'Tiếp tục' : 'Bắt đầu')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getPhaseColor(),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
                
                // Stop button
                OutlinedButton.icon(
                  onPressed: (_isRunning || _isPaused) ? _stopTimer : null,
                  icon: const Icon(Icons.stop),
                  label: const Text('Dừng'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Additional controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Distraction counter
                TextButton.icon(
                  onPressed: _addDistraction,
                  icon: const Icon(Icons.warning_amber, color: Colors.orange),
                  label: Text('Nhiễu: $_distractionCount'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.orange,
                  ),
                ),
                
                // Skip phase
                TextButton.icon(
                  onPressed: (_isRunning || _isPaused) ? _skipPhase : null,
                  icon: const Icon(Icons.skip_next),
                  label: const Text('Bỏ qua'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Hiển thị dialog để chọn thời gian focus
  void _showTimePicker() async {
    if (_isRunning) return; // Không cho phép thay đổi khi đang chạy

    final result = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Chọn thời gian Focus'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('15 phút'),
                onTap: () => Navigator.of(context).pop(15),
              ),
              ListTile(
                title: const Text('25 phút (Pomodoro)'),
                onTap: () => Navigator.of(context).pop(25),
              ),
              ListTile(
                title: const Text('30 phút'),
                onTap: () => Navigator.of(context).pop(30),
              ),
              ListTile(
                title: const Text('45 phút'),
                onTap: () => Navigator.of(context).pop(45),
              ),
              ListTile(
                title: const Text('60 phút'),
                onTap: () => Navigator.of(context).pop(60),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy'),
            ),
          ],
        );
      },
    );

    if (result != null) {
      setState(() {
        _workDuration = result * 60; // Chuyển đổi phút sang giây
        _currentSeconds = _workDuration;
        _totalSeconds = _workDuration;
      });
      _resetTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _progressController.dispose();
    super.dispose();
  }
}

/// Enum cho các phase của Pomodoro
enum PomodoroPhase {
  work,
  shortBreak,
  longBreak,
}