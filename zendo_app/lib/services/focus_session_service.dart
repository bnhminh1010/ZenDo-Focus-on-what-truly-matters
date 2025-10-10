import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/focus_session.dart';

/// Service để quản lý Focus Sessions với Supabase
class FocusSessionService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Tạo focus session mới
  Future<FocusSession> createFocusSession(FocusSession session) async {
    try {
      final response = await _supabase
          .from('focus_sessions')
          .insert(session.toSupabaseMap())
          .select()
          .single();

      return FocusSession.fromSupabaseMap(response);
    } catch (e) {
      throw Exception('Không thể tạo focus session: $e');
    }
  }

  /// Cập nhật focus session
  Future<FocusSession> updateFocusSession(FocusSession session) async {
    try {
      final response = await _supabase
          .from('focus_sessions')
          .update(session.toSupabaseMap())
          .eq('id', session.id!)
          .select()
          .single();

      return FocusSession.fromSupabaseMap(response);
    } catch (e) {
      throw Exception('Không thể cập nhật focus session: $e');
    }
  }

  /// Lấy focus sessions của user
  Future<List<FocusSession>> getUserFocusSessions(String userId, {
    int? limit,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = _supabase
          .from('focus_sessions')
          .select()
          .eq('user_id', userId)
          .order('started_at', ascending: false);

      // Tạm thời bỏ date filtering để tránh lỗi gte/lte
      // if (startDate != null && endDate != null) {
      //   final startDateStr = startDate.toIso8601String();
      //   final endDateStr = endDate.toIso8601String();
      //   query = query.gte('started_at', startDateStr).lte('started_at', endDateStr);
      // } else if (startDate != null) {
      //   query = query.gte('started_at', startDate.toIso8601String());
      // } else if (endDate != null) {
      //   query = query.lte('started_at', endDate.toIso8601String());
      // }

      if (limit != null) {
        query = query.limit(limit);
      }

      final response = await query;
      return response.map((data) => FocusSession.fromSupabaseMap(data)).toList();
    } catch (e) {
      throw Exception('Không thể lấy focus sessions: $e');
    }
  }

  /// Lấy focus session theo ID
  Future<FocusSession?> getFocusSessionById(String sessionId) async {
    try {
      final response = await _supabase
          .from('focus_sessions')
          .select()
          .eq('id', sessionId)
          .maybeSingle();

      if (response == null) return null;
      return FocusSession.fromSupabaseMap(response);
    } catch (e) {
      throw Exception('Không thể lấy focus session: $e');
    }
  }

  /// Xóa focus session
  Future<void> deleteFocusSession(String sessionId) async {
    try {
      await _supabase
          .from('focus_sessions')
          .delete()
          .eq('id', sessionId);
    } catch (e) {
      throw Exception('Không thể xóa focus session: $e');
    }
  }

  /// Lấy thống kê focus sessions của user
  Future<Map<String, dynamic>> getFocusSessionStats(String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = _supabase
          .from('focus_sessions')
          .select('actual_duration_minutes, distraction_count, status, started_at')
          .eq('user_id', userId);

      if (startDate != null) {
        query = query.gte('started_at', startDate.toIso8601String());
      }

      if (endDate != null) {
        query = query.lte('started_at', endDate.toIso8601String());
      }

      final response = await query;
      
      int totalSessions = response.length;
      int completedSessions = response.where((s) => s['status'] == 'completed').length;
      int totalMinutes = response.fold(0, (sum, s) => sum + (s['actual_duration_minutes'] as int? ?? 0));
      int totalDistractions = response.fold(0, (sum, s) => sum + (s['distraction_count'] as int? ?? 0));
      
      double averageSessionLength = totalSessions > 0 ? totalMinutes / totalSessions : 0;
      double completionRate = totalSessions > 0 ? completedSessions / totalSessions : 0;
      double averageDistractions = totalSessions > 0 ? totalDistractions / totalSessions : 0;

      return {
        'totalSessions': totalSessions,
        'completedSessions': completedSessions,
        'totalMinutes': totalMinutes,
        'totalDistractions': totalDistractions,
        'averageSessionLength': averageSessionLength,
        'completionRate': completionRate,
        'averageDistractions': averageDistractions,
      };
    } catch (e) {
      throw Exception('Không thể lấy thống kê focus sessions: $e');
    }
  }

  /// Lấy focus sessions theo task ID
  Future<List<FocusSession>> getFocusSessionsByTask(String taskId) async {
    try {
      final response = await _supabase
          .from('focus_sessions')
          .select()
          .eq('task_id', taskId)
          .order('started_at', ascending: false);

      return response.map((data) => FocusSession.fromSupabaseMap(data)).toList();
    } catch (e) {
      throw Exception('Không thể lấy focus sessions theo task: $e');
    }
  }

  /// Lấy focus sessions đang active
  Future<List<FocusSession>> getActiveFocusSessions(String userId) async {
    try {
      final response = await _supabase
          .from('focus_sessions')
          .select()
          .eq('user_id', userId)
          .inFilter('status', ['active', 'paused'])
          .order('started_at', ascending: false);

      return response.map((data) => FocusSession.fromSupabaseMap(data)).toList();
    } catch (e) {
      throw Exception('Không thể lấy active focus sessions: $e');
    }
  }

  /// Lấy focus sessions theo ngày
  Future<List<FocusSession>> getFocusSessionsByDate(String userId, DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final response = await _supabase
          .from('focus_sessions')
          .select()
          .eq('user_id', userId)
          .gte('started_at', startOfDay.toIso8601String())
          .lt('started_at', endOfDay.toIso8601String())
          .order('started_at', ascending: false);

      return response.map((data) => FocusSession.fromSupabaseMap(data)).toList();
    } catch (e) {
      throw Exception('Không thể lấy focus sessions theo ngày: $e');
    }
  }

  /// Lấy focus sessions theo tuần
  Future<List<FocusSession>> getFocusSessionsByWeek(String userId, DateTime weekStart) async {
    try {
      final weekEnd = weekStart.add(const Duration(days: 7));

      final response = await _supabase
          .from('focus_sessions')
          .select()
          .eq('user_id', userId)
          .gte('started_at', weekStart.toIso8601String())
          .lt('started_at', weekEnd.toIso8601String())
          .order('started_at', ascending: false);

      return response.map((data) => FocusSession.fromSupabaseMap(data)).toList();
    } catch (e) {
      throw Exception('Không thể lấy focus sessions theo tuần: $e');
    }
  }

  /// Lấy focus sessions theo tháng
  Future<List<FocusSession>> getFocusSessionsByMonth(String userId, DateTime month) async {
    try {
      final startOfMonth = DateTime(month.year, month.month, 1);
      final endOfMonth = DateTime(month.year, month.month + 1, 1);

      final response = await _supabase
          .from('focus_sessions')
          .select()
          .eq('user_id', userId)
          .gte('started_at', startOfMonth.toIso8601String())
          .lt('started_at', endOfMonth.toIso8601String())
          .order('started_at', ascending: false);

      return response.map((data) => FocusSession.fromSupabaseMap(data)).toList();
    } catch (e) {
      throw Exception('Không thể lấy focus sessions theo tháng: $e');
    }
  }

  /// Tính tổng thời gian focus trong khoảng thời gian
  Future<int> getTotalFocusTime(String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = _supabase
          .from('focus_sessions')
          .select('actual_duration_minutes')
          .eq('user_id', userId)
          .eq('status', 'completed');

      if (startDate != null) {
        query = query.gte('started_at', startDate.toIso8601String());
      }

      if (endDate != null) {
        query = query.lte('started_at', endDate.toIso8601String());
      }

      final response = await query;
      int totalMinutes = 0;
      for (final session in response) {
        totalMinutes += (session['actual_duration_minutes'] as int? ?? 0);
      }
      return totalMinutes;
    } catch (e) {
      throw Exception('Không thể tính tổng thời gian focus: $e');
    }
  }

  /// Lấy streak (chuỗi ngày liên tiếp có focus session)
  Future<int> getFocusStreak(String userId) async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      int streak = 0;
      DateTime checkDate = today;

      while (true) {
        final sessions = await getFocusSessionsByDate(userId, checkDate);
        final completedSessions = sessions.where((s) => s.status == FocusSessionStatus.completed).toList();
        
        if (completedSessions.isEmpty) {
          // Nếu hôm nay chưa có session nào, kiểm tra hôm qua
          if (checkDate.isAtSameMomentAs(today)) {
            checkDate = checkDate.subtract(const Duration(days: 1));
            continue;
          }
          break;
        }
        
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      }

      return streak;
    } catch (e) {
      throw Exception('Không thể tính focus streak: $e');
    }
  }
}