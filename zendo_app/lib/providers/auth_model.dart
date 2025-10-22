import 'package:flutter/foundation.dart';
import '../services/supabase_auth_service.dart';

/// AuthModel Class
/// Tác dụng: Provider quản lý trạng thái xác thực người dùng và tương tác với Supabase Auth
/// Sử dụng khi: Cần xử lý đăng nhập, đăng xuất, đăng ký và quản lý session người dùng
class AuthModel extends ChangeNotifier {
  final SupabaseAuthService _authService = SupabaseAuthService();

  bool _isAuthenticated = false;
  String? _userEmail;
  String? _userName;
  bool _isLoading = false;

  // Getters
  bool get isAuthenticated => _isAuthenticated;
  String? get userEmail => _userEmail;
  String? get userName => _userName;
  bool get isLoading => _isLoading;

  /// initialize method
  /// Tác dụng: Khởi tạo AuthModel và kiểm tra trạng thái đăng nhập hiện tại từ Supabase
  /// Sử dụng khi: Khởi động ứng dụng để xác định user đã đăng nhập hay chưa
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Kiểm tra session hiện tại từ Supabase
      final user = _authService.currentUser;
      if (user != null) {
        _isAuthenticated = true;
        _userEmail = user.email ?? '';
        _userName =
            user.userMetadata?['full_name'] ??
            user.email?.split('@')[0] ??
            'User';
      } else {
        _isAuthenticated = false;
        _userEmail = null;
        _userName = null;
      }
    } catch (e) {
      debugPrint('Error initializing auth: $e');
      _isAuthenticated = false;
      _userEmail = null;
      _userName = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Đăng nhập với email và password
  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _authService.signIn(email, password);
      if (success) {
        _isAuthenticated = true;
        final user = _authService.currentUser;
        _userEmail = user?.email ?? '';
        _userName =
            user?.userMetadata?['full_name'] ??
            user?.email?.split('@')[0] ??
            'User';

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('Error signing in: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Đăng ký tài khoản mới
  Future<bool> signUp(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _authService.signUp(name, email, password);
      if (success) {
        _isAuthenticated = true;
        final user = _authService.currentUser;
        _userEmail = user?.email ?? '';
        _userName = name;

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('Error signing up: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Đăng xuất
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signOut();

      // Reset state
      _isAuthenticated = false;
      _userEmail = null;
      _userName = null;
    } catch (e) {
      debugPrint('Error signing out: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Cập nhật thông tin profile
  Future<bool> updateProfile(String name, String email) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _authService.updateProfile(name, email);
      if (success) {
        _userName = name;
        _userEmail = email;

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('Error updating profile: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Reset password
  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _authService.resetPassword(email);
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      debugPrint('Error resetting password: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Cập nhật mật khẩu
  Future<bool> updatePassword(
    String currentPassword,
    String newPassword,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _authService.updatePassword(
        currentPassword,
        newPassword,
      );
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      debugPrint('Error updating password: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Cập nhật trạng thái authentication từ Google Sign-In
  void updateFromGoogleAuth(bool isAuthenticated, String? email, String? name) {
    _isAuthenticated = isAuthenticated;
    _userEmail = email;
    _userName = name;
    notifyListeners();
  }
}

