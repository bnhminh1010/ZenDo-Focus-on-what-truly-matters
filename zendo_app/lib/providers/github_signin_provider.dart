import 'package:flutter/foundation.dart';
import '../services/github_auth_service.dart';

/// Provider để quản lý trạng thái GitHub authentication
/// Sử dụng ChangeNotifier để thông báo UI về thay đổi state
class GitHubSignInProvider with ChangeNotifier {
  final GitHubAuthService _authService = GitHubAuthService();

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
  }

  /// Khởi tạo state từ service
  void _initializeState() {
    _isSignedIn = _authService.isSignedIn;
    _userInfo = _authService.currentGitHubUser;
    notifyListeners();
  }

  /// Đăng nhập bằng GitHub
  Future<bool> signIn() async {
    if (_isLoading) return false;

    _setLoading(true);
    _clearError();

    try {
      final user = await _authService.signInWithGitHub();

      if (user != null) {
        // Chuyển đổi User object thành Map để tương thích
        _userInfo = {
          'id': user.id,
          'login':
              user.userMetadata?['user_name'] ??
              user.userMetadata?['preferred_username'],
          'name': user.userMetadata?['full_name'] ?? user.userMetadata?['name'],
          'email': user.email,
          'avatar_url': user.userMetadata?['avatar_url'],
        };
        _isSignedIn = true;
        _setLoading(false);
        return true;
      } else {
        _setError('Đăng nhập GitHub thất bại. Vui lòng thử lại.');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Lỗi đăng nhập: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  /// Đăng xuất
  Future<void> signOut() async {
    if (_isLoading) return;

    _setLoading(true);
    _clearError();

    try {
      await _authService.signOut();
      _userInfo = null;
      _isSignedIn = false;
    } catch (e) {
      _setError('Lỗi đăng xuất: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Ngắt kết nối GitHub account
  Future<void> disconnect() async {
    if (_isLoading) return;

    _setLoading(true);
    _clearError();

    try {
      await _authService.disconnect();
      _userInfo = null;
      _isSignedIn = false;
    } catch (e) {
      _setError('Lỗi ngắt kết nối: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Làm mới thông tin user
  Future<void> refreshUserInfo() async {
    if (!_isSignedIn) return;

    _setLoading(true);
    _clearError();

    try {
      // Lấy lại thông tin user từ service
      _userInfo = _authService.currentGitHubUser;
      if (_userInfo == null) {
        _setError('Không thể lấy thông tin người dùng');
      }
    } catch (e) {
      _setError('Lỗi làm mới thông tin: ${e.toString()}');
    } finally {
      _setLoading(false);
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
    super.dispose();
  }
}

