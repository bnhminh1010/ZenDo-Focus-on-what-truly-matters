import 'package:flutter/foundation.dart';
import '../models/focus_session.dart';
import '../services/focus_session_service.dart';
import '../services/supabase_auth_service.dart';

/// Provider model để quản lý state của Focus Sessions
class FocusSessionModel extends ChangeNotifier {
  final FocusSessionService _focusSessionService = FocusSessionService();
  final SupabaseAuthService _authService = SupabaseAuthService();

  // State variables
  List<FocusSession> _focusSessions = [];
  FocusSession? _currentSession;
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _stats;

  // Getters
  List<FocusSession> get focusSessions => _focusSessions;
  FocusSession? get currentSession => _currentSession;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get stats => _stats;

  /// Lấy user ID hiện tại
  String? get _currentUserId => _authService.currentUser?.id;

  /// Load focus sessions của user
  Future<void> loadFocusSessions({
    int? limit,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (_currentUserId == null) return;

    _setLoading(true);
    try {
      _focusSessions = await _focusSessionService.getUserFocusSessions(
        _currentUserId!,
        limit: limit,
        startDate: startDate,
        endDate: endDate,
      );
      _clearError();
    } catch (e) {
      _setError('Không thể tải focus sessions: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Tạo focus session mới
  Future<FocusSession?> createFocusSession({
    String? taskId,
    String? title,
    required int plannedDurationMinutes,
    String sessionType = 'pomodoro',
  }) async {
    if (_currentUserId == null) return null;

    _setLoading(true);
    try {
      final now = DateTime.now();
      final session = FocusSession(
        userId: _currentUserId!,
        taskId: taskId,
        title: title,
        plannedDurationMinutes: plannedDurationMinutes,
        startedAt: now,
        status: FocusSessionStatus.active,
        sessionType: sessionType,
        createdAt: now,
        updatedAt: now,
      );

      final createdSession = await _focusSessionService.createFocusSession(session);
      _currentSession = createdSession;
      _focusSessions.insert(0, createdSession);
      _clearError();
      return createdSession;
    } catch (e) {
      _setError('Không thể tạo focus session: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Cập nhật focus session
  Future<bool> updateFocusSession(FocusSession session) async {
    _setLoading(true);
    try {
      final updatedSession = await _focusSessionService.updateFocusSession(
        session.copyWith(updatedAt: DateTime.now()),
      );
      
      // Cập nhật trong danh sách
      final index = _focusSessions.indexWhere((s) => s.id == session.id);
      if (index != -1) {
        _focusSessions[index] = updatedSession;
      }
      
      // Cập nhật current session nếu cần
      if (_currentSession?.id == session.id) {
        _currentSession = updatedSession;
      }
      
      _clearError();
      return true;
    } catch (e) {
      _setError('Không thể cập nhật focus session: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Hoàn thành focus session
  Future<bool> completeFocusSession(String sessionId, {
    int? actualDurationMinutes,
    int? distractionCount,
    int? productivityRating,
    String? notes,
  }) async {
    final session = _focusSessions.firstWhere((s) => s.id == sessionId);
    
    return await updateFocusSession(
      session.copyWith(
        status: FocusSessionStatus.completed,
        endedAt: DateTime.now(),
        actualDurationMinutes: actualDurationMinutes ?? session.actualDurationMinutes,
        distractionCount: distractionCount ?? session.distractionCount,
        productivityRating: productivityRating,
        notes: notes,
      ),
    );
  }

  /// Tạm dừng focus session
  Future<bool> pauseFocusSession(String sessionId) async {
    final session = _focusSessions.firstWhere((s) => s.id == sessionId);
    
    return await updateFocusSession(
      session.copyWith(
        status: FocusSessionStatus.paused,
        pausedAt: DateTime.now(),
      ),
    );
  }

  /// Tiếp tục focus session
  Future<bool> resumeFocusSession(String sessionId) async {
    final session = _focusSessions.firstWhere((s) => s.id == sessionId);
    
    // Tính thời gian pause
    final pauseDuration = session.pausedAt != null 
        ? DateTime.now().difference(session.pausedAt!).inMinutes
        : 0;
    
    return await updateFocusSession(
      session.copyWith(
        status: FocusSessionStatus.active,
        pausedAt: null,
        totalPauseDurationMinutes: session.totalPauseDurationMinutes + pauseDuration,
      ),
    );
  }

  /// Hủy focus session
  Future<bool> cancelFocusSession(String sessionId) async {
    final session = _focusSessions.firstWhere((s) => s.id == sessionId);
    
    return await updateFocusSession(
      session.copyWith(
        status: FocusSessionStatus.cancelled,
        endedAt: DateTime.now(),
      ),
    );
  }

  /// Xóa focus session
  Future<bool> deleteFocusSession(String sessionId) async {
    _setLoading(true);
    try {
      await _focusSessionService.deleteFocusSession(sessionId);
      _focusSessions.removeWhere((s) => s.id == sessionId);
      
      if (_currentSession?.id == sessionId) {
        _currentSession = null;
      }
      
      _clearError();
      return true;
    } catch (e) {
      _setError('Không thể xóa focus session: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Load thống kê focus sessions
  Future<void> loadStats({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (_currentUserId == null) return;

    _setLoading(true);
    try {
      _stats = await _focusSessionService.getFocusSessionStats(
        _currentUserId!,
        startDate: startDate,
        endDate: endDate,
      );
      _clearError();
    } catch (e) {
      _setError('Không thể tải thống kê: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Lấy focus sessions theo ngày
  Future<List<FocusSession>> getFocusSessionsByDate(DateTime date) async {
    if (_currentUserId == null) return [];

    try {
      return await _focusSessionService.getFocusSessionsByDate(_currentUserId!, date);
    } catch (e) {
      _setError('Không thể lấy focus sessions theo ngày: $e');
      return [];
    }
  }

  /// Lấy focus sessions theo tuần
  Future<List<FocusSession>> getFocusSessionsByWeek(DateTime weekStart) async {
    if (_currentUserId == null) return [];

    try {
      return await _focusSessionService.getFocusSessionsByWeek(_currentUserId!, weekStart);
    } catch (e) {
      _setError('Không thể lấy focus sessions theo tuần: $e');
      return [];
    }
  }

  /// Lấy focus sessions theo tháng
  Future<List<FocusSession>> getFocusSessionsByMonth(DateTime month) async {
    if (_currentUserId == null) return [];

    try {
      return await _focusSessionService.getFocusSessionsByMonth(_currentUserId!, month);
    } catch (e) {
      _setError('Không thể lấy focus sessions theo tháng: $e');
      return [];
    }
  }

  /// Lấy tổng thời gian focus
  Future<int> getTotalFocusTime({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (_currentUserId == null) return 0;

    try {
      return await _focusSessionService.getTotalFocusTime(
        _currentUserId!,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      _setError('Không thể tính tổng thời gian focus: $e');
      return 0;
    }
  }

  /// Lấy focus streak
  Future<int> getFocusStreak() async {
    if (_currentUserId == null) return 0;

    try {
      return await _focusSessionService.getFocusStreak(_currentUserId!);
    } catch (e) {
      _setError('Không thể tính focus streak: $e');
      return 0;
    }
  }

  /// Lấy focus sessions đang active
  Future<void> loadActiveFocusSessions() async {
    if (_currentUserId == null) return;

    try {
      final activeSessions = await _focusSessionService.getActiveFocusSessions(_currentUserId!);
      if (activeSessions.isNotEmpty) {
        _currentSession = activeSessions.first;
      }
      _clearError();
    } catch (e) {
      _setError('Không thể lấy active focus sessions: $e');
    }
  }

  /// Lấy focus sessions theo task
  Future<List<FocusSession>> getFocusSessionsByTask(String taskId) async {
    try {
      return await _focusSessionService.getFocusSessionsByTask(taskId);
    } catch (e) {
      _setError('Không thể lấy focus sessions theo task: $e');
      return [];
    }
  }

  /// Clear current session
  void clearCurrentSession() {
    _currentSession = null;
    notifyListeners();
  }

  /// Refresh data
  Future<void> refresh() async {
    await loadFocusSessions();
    await loadStats();
    await loadActiveFocusSessions();
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}