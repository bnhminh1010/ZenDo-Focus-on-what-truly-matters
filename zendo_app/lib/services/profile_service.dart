/*
 * Tên: services/profile_service.dart
 * Tác dụng: Service quản lý thông tin profile người dùng từ bảng profiles trong Supabase
 * Khi nào dùng: Khi cần load hoặc cập nhật thông tin profile từ database
 */

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Model cho thông tin profile từ database
class UserProfile {
  final String id;
  final String? email;
  final String? fullName;
  final String? name;
  final String? avatarUrl;
  final String? phone;
  final String? bio;
  final String? timezone;
  final String? language;
  final bool isPremium;
  final int totalTasksCompleted;
  final int totalFocusMinutes;
  final int currentStreakDays;
  final int longestStreakDays;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserProfile({
    required this.id,
    this.email,
    this.fullName,
    this.name,
    this.avatarUrl,
    this.phone,
    this.bio,
    this.timezone,
    this.language,
    this.isPremium = false,
    this.totalTasksCompleted = 0,
    this.totalFocusMinutes = 0,
    this.currentStreakDays = 0,
    this.longestStreakDays = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as String,
      email: map['email'] as String?,
      fullName: map['full_name'] as String?,
      name: map['name'] as String?,
      avatarUrl: map['avatar_url'] as String?,
      phone: map['phone'] as String?,
      bio: map['bio'] as String?,
      timezone: map['timezone'] as String?,
      language: map['language'] as String?,
      isPremium: map['is_premium'] as bool? ?? false,
      totalTasksCompleted: map['total_tasks_completed'] as int? ?? 0,
      totalFocusMinutes: map['total_focus_minutes'] as int? ?? 0,
      currentStreakDays: map['current_streak_days'] as int? ?? 0,
      longestStreakDays: map['longest_streak_days'] as int? ?? 0,
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at'] as String) 
          : null,
      updatedAt: map['updated_at'] != null 
          ? DateTime.parse(map['updated_at'] as String) 
          : null,
    );
  }
}

/// Service quản lý thông tin profile người dùng
class ProfileService {
  static final ProfileService _instance = ProfileService._internal();
  factory ProfileService() => _instance;
  ProfileService._internal();

  /// Supabase client dùng để truy cập bảng profiles.
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Lấy thông tin profile của user hiện tại từ database
  Future<UserProfile?> getCurrentUserProfile() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        debugPrint('User not authenticated');
        return null;
      }

      final response = await _supabase
          .from('profiles')
          .select('*')
          .eq('id', user.id)
          .single();

      debugPrint('Profile loaded successfully: ${response['avatar_url']}');
      return UserProfile.fromMap(response);

    } catch (e) {
      debugPrint('Error loading user profile: $e');
      return null;
    }
  }

  /// Lấy avatar URL của user hiện tại
  Future<String?> getCurrentUserAvatarUrl() async {
    try {
      final profile = await getCurrentUserProfile();
      return profile?.avatarUrl;
    } catch (e) {
      debugPrint('Error getting avatar URL: $e');
      return null;
    }
  }

  /// Cập nhật avatar URL trong database
  Future<bool> updateAvatarUrl(String avatarUrl) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        debugPrint('User not authenticated');
        return false;
      }

      await _supabase
          .from('profiles')
          .update({
            'avatar_url': avatarUrl,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', user.id);

      debugPrint('Avatar URL updated successfully: $avatarUrl');
      return true;

    } catch (e) {
      debugPrint('Error updating avatar URL: $e');
      return false;
    }
  }

  /// Xóa avatar URL khỏi database
  Future<bool> removeAvatarUrl() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        debugPrint('User not authenticated');
        return false;
      }

      await _supabase
          .from('profiles')
          .update({
            'avatar_url': null,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', user.id);

      debugPrint('Avatar URL removed successfully');
      return true;

    } catch (e) {
      debugPrint('Error removing avatar URL: $e');
      return false;
    }
  }
}