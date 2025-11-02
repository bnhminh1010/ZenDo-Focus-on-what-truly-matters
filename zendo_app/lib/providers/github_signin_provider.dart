import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/github_auth_service.dart';
import 'dart:async';

/// Provider để quản lý trạng thái GitHub authentication
/// Sử dụng ChangeNotifier để thông báo UI về thay đổi state
class GitHubSignInProvider with ChangeNotifier {
  final GitHubAuthService _authService = GitHubAuthService();
  StreamSubscription? _authSubscription;

  // State variables
  /// Cờ loading cho các thao tác đăng nhập/đăng xuất.
  bool _isLoading = false;
  /// Trạng thái đã đăng nhập bằng GitHub chưa.
  bool _isSignedIn = false;
  /// Thông điệp lỗi gần nhất.
  String? _errorMessage;
  /// Cache thông tin user GitHub hiện tại.
  Map<String, dynamic>? _userInfo;

  // Getters
  /// Cờ loading cho UI.
  bool get isLoading => _isLoading;
  /// Trạng thái đăng nhập hiện tại.
  bool get isSignedIn => _isSignedIn;
  /// Thông điệp lỗi để hiển thị.
  String? get errorMessage => _errorMessage;
  /// Thông tin user GitHub (login, email, avatar...).
  Map<String, dynamic>? get userInfo => _userInfo;

  // User info getters
  String? get userName => _userInfo?['name'] ?? _userInfo?['login'];
  String? get userEmail => _userInfo?['email'];
  String? get userAvatarUrl => _userInfo?['avatar_url'];
  String? get userLogin => _userInfo?['login'];
  int? get userId => _userInfo?['id'];

  GitHubSignInProvider() {
    _initializeState();
    _setupAuthListener();
  }

  /// Khởi tạo state từ service
  void _initializeState() {
    _isSignedIn = _authService.isSignedIn;
    _userInfo = _authService.currentGitHubUser;
    notifyListeners();
  }

  /// Lắng nghe auth state changes từ Supabase
  void _setupAuthListener() {
    _authSubscription = _authService.supabase.auth.onAuthStateChange.listen((data) {
      debugPrint('🔔 Auth state changed: ${data.event}');
      
      final session = data.session;
      if (session != null && data.event == AuthChangeEvent.signedIn) {
        // User đã đăng nhập thành công
        final user = session.user;
        _userInfo = {
          'id': user.id,
          'login': user.userMetadata?['user_name'] ?? 
                   user.userMetadata?['preferred_username'] ??
                   user.userMetadata?['login'],
          'name': user.userMetadata?['full_name'] ?? 
                  user.userMetadata?['name'],
          'email': user.email,
          'avatar_url': user.userMetadata?['avatar_url'],
        };
        _isSignedIn = true;
        _isLoading = false;
        debugPrint('✅ Provider: User signed in - ${_userInfo?['login']}');
        notifyListeners();
      } else if (data.event == AuthChangeEvent.signedOut) {
        // User đã đăng xuất
        _userInfo = null;
        _isSignedIn = false;
        _isLoading = false;
        debugPrint('🚪 Provider: User signed out');
        notifyListeners();
      }
    });
  }

  /// Đăng nhập bằng GitHub
  Future<bool> signIn() async {
    if (_isLoading) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint('🔐 [GitHubProvider] Starting GitHub sign in...');
      
      final user = await _authService.signInWithGitHub();

      if (user != null) {
        // Auth state listener sẽ tự động cập nhật _userInfo và _isSignedIn
        debugPrint('✅ [GitHubProvider] GitHub sign in successful');
        _isSignedIn = true;
        _userInfo = _authService.userInfo;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Đăng nhập GitHub thất bại. Vui lòng thử lại.';
        _isLoading = false;
        _isSignedIn = false;
        _userInfo = null;
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('❌ [GitHubProvider] Sign in error: $e');
      _errorMessage = 'Lỗi đăng nhập: ${e.toString()}';
      _isLoading = false;
      _isSignedIn = false;
      _userInfo = null;
      notifyListeners();
      return false;
    }
  }

  /// Đăng xuất
  Future<void> signOut() async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint('🚪 [GitHubProvider] Signing out from GitHub...');
      await _authService.signOut();
      debugPrint('✅ [GitHubProvider] Signed out from GitHub');
    } catch (e) {
      debugPrint('❌ [GitHubProvider] Error signing out from GitHub: $e');
      _errorMessage = 'Lỗi khi đăng xuất: ${e.toString()}';
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      _isSignedIn = false;
      _userInfo = null;
      notifyListeners();
    }
  }

  /// Ngắt kết nối GitHub account
  Future<void> disconnect() async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint('🔌 [GitHubProvider] Disconnecting GitHub account...');
      await _authService.disconnectGitHub();
      debugPrint('✅ [GitHubProvider] GitHub account disconnected');
      
      // Cập nhật state local
      _isSignedIn = false;
      _userInfo = null;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ [GitHubProvider] Error disconnecting GitHub account: $e');
      _errorMessage = 'Lỗi khi ngắt kết nối tài khoản GitHub: ${e.toString()}';
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Làm mới thông tin user
  Future<void> refreshUserInfo() async {
    if (!_isSignedIn) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint('🔄 [GitHubProvider] Refreshing GitHub user info...');
      final success = await _authService.refreshUserInfo();
      
      if (success) {
        _userInfo = _authService.userInfo;
        _isSignedIn = _userInfo != null;
        notifyListeners();
        debugPrint('✅ [GitHubProvider] GitHub user info refreshed');
      } else {
        _errorMessage = 'Không thể làm mới thông tin người dùng';
        notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ [GitHubProvider] Error refreshing GitHub user info: $e');
      _errorMessage = 'Không thể làm mới thông tin người dùng: ${e.toString()}';
      _isSignedIn = false;
      _userInfo = null;
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Kiểm tra trạng thái đăng nhập
  Future<void> checkSignInStatus() async {
    _isSignedIn = _authService.isSignedIn;
    _userInfo = _authService.currentGitHubUser;
    notifyListeners();
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Set error message
  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  /// Clear error message
  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear error manually (for UI)
  void clearError() {
    _clearError();
  }

  /// Get display name for user
  String get displayName {
    if (_userInfo == null) return '';
    return userName ?? userLogin ?? userEmail ?? 'GitHub User';
  }

  /// Get user profile URL
  String? get profileUrl {
    if (userLogin == null) return null;
    return 'https://github.com/$userLogin';
  }

  /// Check if user has specific GitHub permissions
  bool hasPermission(String permission) {
    // TODO: Implement permission checking based on GitHub scopes
    return true;
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}