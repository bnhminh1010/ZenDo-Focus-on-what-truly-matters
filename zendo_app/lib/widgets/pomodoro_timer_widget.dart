/*
 * Tên: widgets/pomodoro_timer_widget.dart
 * Tác dụng: Quản lý và hiển thị Pomodoro timer, tích hợp focus session, animation và điều khiển.
 * Khi nào dùng: Sử dụng trong trang Focus để vận hành chu kỳ Pomodoro (work/short break/long break).
 */
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../providers/focus_session_model.dart';
import '../theme.dart';
import 'pyramid_timer_widget.dart';
import 'glass_dialog.dart';
import 'glass_button.dart';
import 'glass_container.dart';

/*
 * Widget: PomodoroTimerWidget
 * Tác dụng: Timer Pomodoro có thể tái sử dụng với đầy đủ tính năng (work/break), tích hợp FocusSession.
 * Khi nào dùng: Khi cần áp dụng kỹ thuật Pomodoro vào các phiên tập trung trong ứng dụng.
 */
class PomodoroTimerWidget extends StatefulWidget {
  /// ID task liên kết với phiên focus (nullable).
  final String? taskId;
  /// Tiêu đề task hiển thị trong session (nullable).
  final String? taskTitle;
  /// Thời lượng phiên làm việc ban đầu (phút).
  final int initialWorkDuration; // phút
  /// Thời lượng nghỉ ngắn (phút).
  final int initialShortBreakDuration; // phút
  /// Thời lượng nghỉ dài (phút).
  final int initialLongBreakDuration; // phút
  /// Số phiên làm việc trước khi đến nghỉ dài.
  final int sessionsBeforeLongBreak;
  /// Callback khi hoàn thành một session focus.
  final VoidCallback? onSessionComplete;
  /// Callback khi hoàn thành một phiên nghỉ.
  final VoidCallback? onBreakComplete;
  /// Tự động bắt đầu nghỉ sau khi kết thúc work session.
  final bool autoStartBreaks;
  /// Tự động bắt đầu work session sau khi kết thúc nghỉ.
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

/*
 * State: _PomodoroTimerWidgetState
 * Tác dụng: Quản lý logic timer, animations, chu kỳ Pomodoro và tương tác UI.
 * Khi nào dùng: Khi khởi tạo PomodoroTimerWidget để điều phối trạng thái và cập nhật màn hình.
 */
class _PomodoroTimerWidgetState extends State<PomodoroTimerWidget>
    with TickerProviderStateMixin {
  /// Timer cho việc đếm lùi.
  Timer? _timer;

  // Pomodoro settings
  /// Thời lượng work (giây).
  late int _workDuration;
  /// Thời lượng nghỉ ngắn (giây).
  late int _shortBreakDuration;
  /// Thời lượng nghỉ dài (giây).
  late int _longBreakDuration;

  // Current session state
  /// Phase hiện tại (work/shortBreak/longBreak).
  PomodoroPhase _currentPhase = PomodoroPhase.work;
  /// Số giây còn lại trong phase.
  int _currentSeconds = 0;
  /// Tổng số giây của phase hiện tại.
  int _totalSeconds = 0;
  /// Cờ timer đang chạy.
  bool _isRunning = false;
  /// Cờ đang tạm dừng.
  bool _isPaused = false;

  // Pomodoro cycle tracking
  /// Số pomodoro đã hoàn thành trong chu kỳ.
  int _completedPomodoros = 0;
  /// Số lần xao nhãng ghi nhận.
  int _distractionCount = 0;

  // Session tracking
  /// Thời điểm bắt đầu session hiện tại.
  DateTime? _sessionStartTime;
  /// ID session hiện tại trong database (nullable).
  String? _currentSessionId;

  // Animations
  /// Controller cho hiệu ứng pulse.
  late AnimationController _pulseController;
  /// Controller cho progress animation.
  late AnimationController _progressController;
  /// Animation cho progress.
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

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );
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
    final progress = _totalSeconds > 0
        ? (_totalSeconds - _currentSeconds) / _totalSeconds
        : 0.0;
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Header with icon
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      _getPhaseIcon(),
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Title
                Text(
                  _getPhaseCompleteTitle(),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                // Message
                Text(
                  _getPhaseCompleteMessage(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 24),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: Semantics(
                        label: 'Đóng thông báo',
                        hint: 'Nhấn để đóng dialog',
                        child: GlassOutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Đồng ý'),
                        ),
                      ),
                    ),
                    if (!_isAutoStartEnabled()) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: Semantics(
                          label: 'Bắt đầu phiên tiếp theo',
                          hint:
                              'Nhấn để bắt đầu phiên ${_getStartButtonText().toLowerCase()}',
                          child: GlassElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              _startTimer();
                            },
                            child: Text(_getStartButtonText()),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
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

  String _getPhaseIcon() {
    switch (_currentPhase) {
      case PomodoroPhase.work:
        return '🎯';
      case PomodoroPhase.shortBreak:
        return '☕';
      case PomodoroPhase.longBreak:
        return '🌟';
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
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
            ],

            // Pyramid Timer thay vì Timer circle
            PyramidTimerWidget(
              progress: _progressAnimation.value,
              activeColor: Colors.purple, // Màu tím cho phần active
              inactiveColor: Colors.grey[400]!, // Màu xám cho phần inactive
              size: 260, // tăng kích thước vùng kim tự tháp & thời gian
              timeText: _formatTime(_currentSeconds),
              subText: '$_completedPomodoros phiên hoàn thành',
              onTimeTap: _showTimePicker, // Thêm callback để chọn thời gian
            ),

            const SizedBox(height: 24),

            // Control buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Start/Pause button
                SizedBox(
                  width: 130,
                  child: GlassElevatedButton.icon(
                    onPressed: _isRunning
                        ? _pauseTimer
                        : (_isPaused ? _resumeTimer : _startTimer),
                    icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                    label: Text(
                      _isRunning
                          ? 'Tạm dừng'
                          : (_isPaused ? 'Tiếp tục' : 'Bắt đầu'),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ),

                // Stop button
                SizedBox(
                  width: 100,
                  child: GlassOutlinedButton(
                    onPressed: (_isRunning || _isPaused) ? _stopTimer : null,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.stop),
                        SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            'Dừng',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
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
                GlassTextButton(
                  onPressed: _addDistraction,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.warning_amber, color: Colors.orange),
                      const SizedBox(width: 8),
                      Text('Nhiễu: $_distractionCount'),
                    ],
                  ),
                ),

                // Skip phase
                GlassTextButton(
                  onPressed: (_isRunning || _isPaused) ? _skipPhase : null,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.skip_next),
                      SizedBox(width: 8),
                      Text('Bỏ qua'),
                    ],
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
        return GlassDialog(
          title: const Text('Chọn thời gian Focus'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('5 phút'),
                subtitle: const Text('Tập trung ngắn hạn'),
                leading: const Icon(Icons.flash_on, color: Colors.orange),
                onTap: () => Navigator.of(context).pop(5),
              ),
              ListTile(
                title: const Text('15 phút'),
                subtitle: const Text('Tập trung vừa phải'),
                leading: const Icon(Icons.timer, color: Colors.blue),
                onTap: () => Navigator.of(context).pop(15),
              ),
              ListTile(
                title: const Text('25 phút (Pomodoro)'),
                subtitle: const Text('Kỹ thuật Pomodoro chuẩn'),
                leading: const Icon(
                  Icons.local_fire_department,
                  color: Colors.red,
                ),
                onTap: () => Navigator.of(context).pop(25),
              ),
              ListTile(
                title: const Text('30 phút'),
                subtitle: const Text('Tập trung mở rộng'),
                leading: const Icon(Icons.schedule, color: Colors.green),
                onTap: () => Navigator.of(context).pop(30),
              ),
              ListTile(
                title: const Text('45 phút'),
                subtitle: const Text('Tập trung sâu'),
                leading: const Icon(Icons.psychology, color: Colors.purple),
                onTap: () => Navigator.of(context).pop(45),
              ),
              ListTile(
                title: const Text('60 phút'),
                subtitle: const Text('Tập trung tối đa'),
                leading: const Icon(Icons.trending_up, color: Colors.indigo),
                onTap: () => Navigator.of(context).pop(60),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: 80,
              child: GlassTextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Hủy'),
              ),
            ),
          ],
        );
      },
    );

    if (result != null) {
      setState(() {
        _workDuration = result * 60; // Chuyển từ phút sang giây
        if (_currentPhase == PomodoroPhase.work) {
          _resetTimer();
        }
      });
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
enum PomodoroPhase { work, shortBreak, longBreak }

