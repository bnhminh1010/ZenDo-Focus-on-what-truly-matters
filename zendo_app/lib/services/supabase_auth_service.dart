/*
 * Tên: services/supabase_auth_service.dart
 * Tác dụng: Service quản lý authentication với Supabase backend
 * Khi nào dùng: Cần xử lý đăng nhập, đăng ký, đăng xuất và quản lý session người dùng
 */

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// SupabaseAuthService Class
/// Tác dụng: Service quản lý authentication với Supabase backend
/// Sử dụng khi: Cần xử lý đăng nhập, đăng ký, đăng xuất và quản lý session người dùng
class SupabaseAuthService extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  bool _isLoading = false;

  // Getters
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _supabase.auth.currentUser != null;
  User? get currentUser => _supabase.auth.currentUser;
  String? get userEmail => currentUser?.email;
  String? get userName =>
      currentUser?.userMetadata?['full_name'] ??
      currentUser?.email?.split('@')[0];
  String? get userId => currentUser?.id;

  /// initialize Method
  /// Tác dụng: Khởi tạo service và lắng nghe thay đổi trạng thái authentication
  /// Sử dụng khi: App khởi động để setup auth state listener
  void initialize() {
    // Lắng nghe thay đổi auth state
    _supabase.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      debugPrint('Auth state changed: $event');
      notifyListeners();

      if (event == AuthChangeEvent.signedIn) {
        debugPrint('User signed in: ${session?.user.email}');
      } else if (event == AuthChangeEvent.signedOut) {
        debugPrint('User signed out');
      }
    });
  }

  /// signIn Method
  /// Tác dụng: Xử lý đăng nhập người dùng với email và password
  /// Sử dụng khi: Người dùng submit form đăng nhập
  Future<bool> signIn(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Trim và validate email trước khi gửi
      final trimmedEmail = email.trim().toLowerCase();

      // Basic email validation
      if (!RegExp(
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
      ).hasMatch(trimmedEmail)) {
        debugPrint('Auth error: Invalid email format: $trimmedEmail');
        return false;
      }

      debugPrint('Attempting sign in with email: $trimmedEmail');

      final AuthResponse response = await _supabase.auth.signInWithPassword(
        email: trimmedEmail,
        password: password,
      );

      if (response.user != null) {
        debugPrint('Sign in successful: ${response.user!.email}');
        return true;
      } else {
        debugPrint('Sign in failed: No user returned');
        return false;
      }
    } on AuthException catch (e) {
      debugPrint('Auth error: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('Error signing in with email: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Đăng ký tài khoản mới
  Future<bool> signUp(String name, String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Trim và validate email trước khi gửi
      final trimmedEmail = email.trim().toLowerCase();

      // Basic email validation
      if (!RegExp(
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
      ).hasMatch(trimmedEmail)) {
        debugPrint('Auth error: Invalid email format: $trimmedEmail');
        return false;
      }

      debugPrint('Attempting sign up with email: $trimmedEmail');

      final AuthResponse response = await _supabase.auth.signUp(
        email: trimmedEmail,
        password: password,
        data: {'full_name': name},
      );

      if (response.user != null) {
        debugPrint('Sign up successful: ${response.user!.email}');

        // Profile sẽ được tự động tạo bởi trigger handle_new_user
        // Không cần gọi _createUserProfile nữa

        return true;
      } else {
        debugPrint('Sign up failed: No user returned');
        return false;
      }
    } on AuthException catch (e) {
      debugPrint('Auth error: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('Error signing up with email: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Đăng xuất
  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _supabase.auth.signOut();
      debugPrint('Sign out successful');
    } catch (e) {
      debugPrint('Error signing out: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Cập nhật thông tin profile
  Future<bool> updateProfile(String name, String email) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Cập nhật auth metadata
      final UserResponse response = await _supabase.auth.updateUser(
        UserAttributes(email: email, data: {'full_name': name}),
      );

      if (response.user != null) {
        // Profile sẽ được tự động cập nhật bởi trigger hoặc RLS policy
        // Chỉ cần cập nhật auth metadata
        debugPrint('Profile updated successfully');
        return true;
      } else {
        debugPrint('Profile update failed');
        return false;
      }
    } on AuthException catch (e) {
      debugPrint('Auth error: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('Unexpected error during profile update: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Reset password
  Future<bool> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
      return true;
    } catch (e) {
      debugPrint('Error resetting password: $e');
      rethrow;
    }
  }

  /// Cập nhật mật khẩu
  Future<bool> updatePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      // Supabase không yêu cầu mật khẩu hiện tại để cập nhật
      // Chỉ cần cập nhật mật khẩu mới
      await _supabase.auth.updateUser(UserAttributes(password: newPassword));
      return true;
    } catch (e) {
      debugPrint('Error updating password: $e');
      return false;
    }
  }
}
