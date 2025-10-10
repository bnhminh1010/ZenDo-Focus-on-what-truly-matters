import 'package:flutter_test/flutter_test.dart';
import 'package:zendo_app/models/focus_session.dart';

/// Test case để verify việc lưu focus session
void main() {
  group('Focus Session Tests', () {
    test('FocusSession model should create correctly', () {
      final now = DateTime.now();
      final session = FocusSession(
        userId: 'test-user-id',
        plannedDurationMinutes: 25,
        actualDurationMinutes: 25,
        startedAt: now,
        endedAt: now.add(const Duration(minutes: 25)),
        status: FocusSessionStatus.completed,
        distractionCount: 2,
        createdAt: now,
        updatedAt: now,
      );

      expect(session.userId, 'test-user-id');
      expect(session.plannedDurationMinutes, 25);
      expect(session.actualDurationMinutes, 25);
      expect(session.status, FocusSessionStatus.completed);
      expect(session.distractionCount, 2);
    });

    test('FocusSession should convert to Supabase map correctly', () {
      final now = DateTime.now();
      final session = FocusSession(
        id: 'test-id',
        userId: 'test-user-id',
        taskId: 'test-task-id',
        title: 'Test Focus Session',
        plannedDurationMinutes: 25,
        actualDurationMinutes: 23,
        startedAt: now,
        endedAt: now.add(const Duration(minutes: 23)),
        status: FocusSessionStatus.completed,
        distractionCount: 1,
        notes: 'Test notes',
        createdAt: now,
        updatedAt: now,
      );

      final map = session.toSupabaseMap();

      expect(map['id'], 'test-id');
      expect(map['user_id'], 'test-user-id');
      expect(map['task_id'], 'test-task-id');
      expect(map['title'], 'Test Focus Session');
      expect(map['planned_duration_minutes'], 25);
      expect(map['actual_duration_minutes'], 23);
      expect(map['status'], 'completed');
      expect(map['distraction_count'], 1);
      expect(map['notes'], 'Test notes');
    });

    test('FocusSession should create from Supabase map correctly', () {
      final now = DateTime.now();
      final map = {
        'id': 'test-id',
        'user_id': 'test-user-id',
        'task_id': 'test-task-id',
        'title': 'Test Session',
        'planned_duration_minutes': 25,
        'actual_duration_minutes': 24,
        'break_duration_minutes': 5,
        'started_at': now.toIso8601String(),
        'ended_at': now.add(const Duration(minutes: 24)).toIso8601String(),
        'paused_at': null,
        'total_pause_duration_minutes': 0,
        'status': 'completed',
        'session_type': 'pomodoro',
        'productivity_rating': 4,
        'distraction_count': 1,
        'notes': 'Good session',
        'background_sound': null,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };

      final session = FocusSession.fromSupabaseMap(map);

      expect(session.id, 'test-id');
      expect(session.userId, 'test-user-id');
      expect(session.taskId, 'test-task-id');
      expect(session.title, 'Test Session');
      expect(session.plannedDurationMinutes, 25);
      expect(session.actualDurationMinutes, 24);
      expect(session.status, FocusSessionStatus.completed);
      expect(session.productivityRating, 4);
      expect(session.distractionCount, 1);
      expect(session.notes, 'Good session');
    });
  });
}