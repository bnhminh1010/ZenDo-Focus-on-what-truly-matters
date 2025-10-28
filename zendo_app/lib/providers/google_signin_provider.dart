import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/google_auth_service.dart';

/// Provider để quản lý state của Google Sign-In
/// Sử dụng ChangeNotifier để notify UI khi có thay đổi
class GoogleSignInProvider extends ChangeNotifier {
  final GoogleAuthService _googleAuthService = GoogleAuthService();

  // State variables
  /// Cờ loading cho các thao tác đăng nhập/đăng xuất.
  bool _isLoading = false;
  /// Trạng thái đã đăng nhập bằng Google hay chưa.
  bool _isSignedIn = false;
  /// Tài khoản Google hiện tại (API cũ - có thể null).
  GoogleSignInAccount? _googleUser;
  /// Supabase user sau khi liên kết Google thành công.
  User? _supabaseUser;
  /// Thông điệp lỗi gần nhất.
  String? _errorMessage;

  // Getters
  /// Cờ loading để UI phản hồi.
  bool get isLoading => _isLoading;
  /// Trạng thái đăng nhập hiện có.
  bool get isSignedIn => _isSignedIn;
  /// Tài khoản Google kèm thông tin profile (có thể null).
  GoogleSignInAccount? get googleUser => _googleUser;
  /// Supabase user tương ứng.
  User? get supabaseUser => _supabaseUser;
  /// Thông điệp lỗi để hiển thị.
  String? get errorMessage => _errorMessage;

  /// Khởi tạo provider và kiểm tra trạng thái đăng nhập
  GoogleSignInProvider() {
    _checkSignInStatus();
  }

  /// Kiểm tra trạng thái đăng nhập hiện tại
  Future<void> _checkSignInStatus() async {
    _setLoading(true);
    try {
      _isSignedIn = await _googleAuthService.isSignedIn();
      if (_isSignedIn) {
        _supabaseUser = _googleAuthService.currentUser;
        // Không còn currentGoogleUser trong API mới
        _googleUser = null;
      }
      _clearError();
    } catch (e) {
      _setError('Lỗi kiểm tra trạng thái đăng nhập: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Đăng nhập bằng Google
  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _clearError();

    try {
      final User? user = await _googleAuthService.signInWithGoogle();

      if (user != null) {
        _isSignedIn = true;
        _supabaseUser = user;
        // Không còn currentGoogleUser trong API mới
        _googleUser = null;
        _setLoading(false);
        return true;
      } else {
        _setError('Đăng nhập thất bại hoặc bị hủy');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Lỗi đăng nhập Google: $e');
      _setLoading(false);
      return false;
    }
  }

  /// Đăng xuất
  Future<void> signOut() async {
    _setLoading(true);
    _clearError();

    try {
      await _googleAuthService.signOut();
      _isSignedIn = false;
      _googleUser = null;
      _supabaseUser = null;
    } catch (e) {
      _setError('Lỗi đăng xuất: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Disconnect (revoke access)
  Future<void> disconnect() async {
    _setLoading(true);
    _clearError();

    try {
      await _googleAuthService.disconnect();
      _isSignedIn = false;
      _googleUser = null;
      _supabaseUser = null;
    } catch (e) {
      _setError('Lỗi ngắt kết nối: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Refresh thông tin user
  Future<void> refreshUserInfo() async {
    if (!_isSignedIn) return;

    _setLoading(true);
    try {
      _supabaseUser = _googleAuthService.currentUser;
      // Không còn currentGoogleUser trong API mới
      _googleUser = null;
      _clearError();
    } catch (e) {
      _setError('Lỗi làm mới thông tin: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Lấy display name của user
  String get displayName {
    if (_googleUser != null) {
      return _googleUser!.displayName ?? 'Người dùng Google';
    }
    if (_supabaseUser != null) {
      return _supabaseUser!.userMetadata?['full_name'] ??
          _supabaseUser!.email ??
          'Người dùng';
    }
    return 'Chưa đăng nhập';
  }

  /// Lấy email của user
  String get email {
    if (_googleUser != null) {
      return _googleUser!.email;
    }
    if (_supabaseUser != null) {
      return _supabaseUser!.email ?? '';
    }
    return '';
  }

  /// Lấy avatar URL của user
  String? get photoUrl {
    if (_googleUser != null) {
      return _googleUser!.photoUrl;
    }
    if (_supabaseUser != null) {
      return _supabaseUser!.userMetadata?['avatar_url'];
    }
    return null;
  }
}
