/*
 * Tên: services/github_auth_service.dart
 * Tác dụng: Service xử lý GitHub authentication tích hợp với Supabase Auth
 * Khi nào dùng: Cần đăng nhập bằng GitHub và đồng bộ user data với backend
 * 
 * Tính năng:
 * - Đăng nhập/đăng xuất GitHub OAuth
 * - Quản lý session và token
 * - Lấy thông tin user từ GitHub
 * - Xử lý deep link cho mobile
 * - Refresh token tự động
 * - Error handling và logging
 */

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

/// Service để xử lý GitHub authentication
/// Tích hợp với Supabase Auth để đồng bộ user data
class GitHubAuthService {
  static final GitHubAuthService _instance = GitHubAuthService._internal();
  factory GitHubAuthService() => _instance;
  GitHubAuthService._internal() {
    _initializeAuthListener();
  }

  /// Supabase client dùng để thực hiện OAuth GitHub.
  final SupabaseClient _supabase = Supabase.instance.client;
  
  /// Trạng thái loading
  bool _isLoading = false;
  
  /// Trạng thái đăng nhập
  bool _isSignedIn = false;
  
  /// Thông báo lỗi
  String? _errorMessage;

  /// Cache thông tin user GitHub sau khi đăng nhập.
  Map<String, dynamic>? _userInfo;

  /// Stream subscription cho auth state changes
  StreamSubscription<AuthState>? _authSubscription;

  /// Completer để đợi OAuth flow hoàn thành
  Completer<User?>? _authCompleter;

  /// Khởi tạo listener cho auth state changes
  void _initializeAuthListener() {
    _authSubscription = _supabase.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      final session = data.session;

      debugPrint('🔔 [GitHubAuth] Auth state changed: $event');

      if (event == AuthChangeEvent.signedIn && session != null) {
        final user = session.user;
        debugPrint('✅ [GitHubAuth] User signed in: ${user.id}');
        _updateUserInfo(user);

        // Complete OAuth flow nếu đang đợi
        if (_authCompleter != null && !_authCompleter!.isCompleted) {
          _authCompleter!.complete(user);
          _authCompleter = null;
        }
      } else if (event == AuthChangeEvent.signedOut) {
        debugPrint('🚪 [GitHubAuth] User signed out');
        _userInfo = null;

        // Complete với null nếu đang đợi
        if (_authCompleter != null && !_authCompleter!.isCompleted) {
          _authCompleter!.complete(null);
          _authCompleter = null;
        }
      } else if (event == AuthChangeEvent.tokenRefreshed) {
        debugPrint('🔄 [GitHubAuth] Token refreshed');
        if (session?.user != null) {
          _updateUserInfo(session!.user);
        }
      }
    });
  }

  /// Cập nhật thông tin user từ Supabase User object
  void _updateUserInfo(User user) {
    try {
      final metadata = user.userMetadata ?? {};
      
      _userInfo = {
        'id': user.id,
        'login': metadata['user_name'] ?? 
                 metadata['preferred_username'] ??
                 metadata['login'] ??
                 user.email?.split('@').first,
        'name': metadata['full_name'] ?? 
                metadata['name'] ??
                metadata['user_name'],
        'email': user.email,
        'avatar_url': metadata['avatar_url'] ?? metadata['picture'],
        'bio': metadata['bio'],
        'company': metadata['company'],
        'location': metadata['location'],
        'blog': metadata['blog'],
        'public_repos': metadata['public_repos'],
        'followers': metadata['followers'],
        'following': metadata['following'],
        'created_at': metadata['created_at'],
        'updated_at': metadata['updated_at'],
      };

      debugPrint('📝 [GitHubAuth] User info updated: ${_userInfo?['login']}');
    } catch (e) {
      debugPrint('❌ [GitHubAuth] Error updating user info: $e');
    }
  }

  /// Đăng nhập GitHub sử dụng Supabase OAuth
  Future<User?> signInWithGitHub() async {
    if (_isLoading) return null;
    
    _setLoading(true);
    _clearError();
    
    if (_authCompleter != null && !_authCompleter!.isCompleted) {
      _authCompleter!.complete(null);
    }
    
    _authCompleter = Completer<User?>();
    
    try {
      debugPrint('🔐 [GitHubAuth] Starting GitHub OAuth flow...');
      
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.github,
        redirectTo: kIsWeb 
            ? null // Sử dụng callback mặc định cho web
            : 'io.supabase.zendo://login-callback', // Deep link cho mobile
      );

      // Đợi tối đa 2 phút cho quá trình xác thực hoàn tất
      final user = await _authCompleter!.future.timeout(
        const Duration(minutes: 2),
        onTimeout: () {
          debugPrint('⏰ [GitHubAuth] OAuth flow timed out');
          _setError('Quá thời gian chờ xác thực');
          _authCompleter = null;
          return null;
        },
      );
      
      _isSignedIn = user != null;
      _setLoading(false);
      return user;
    } catch (e, stackTrace) {
      _setError('Lỗi đăng nhập: ${e.toString()}');
      debugPrint('Stack trace: $stackTrace');
      
      if (_authCompleter != null && !_authCompleter!.isCompleted) {
        _authCompleter!.complete(null);
      }
      _authCompleter = null;
      _setLoading(false);
      return null;
    }
  }

  /// Kiểm tra xem đang trong quá trình đăng nhập hay không
  bool get isLoading => _authCompleter != null && !_authCompleter!.isCompleted;

  /// Lấy thông tin user GitHub hiện tại
  Map<String, dynamic>? get userInfo => _userInfo;
  
  /// Kiểm tra xem user đã đăng nhập chưa
  bool get isSignedIn => _isSignedIn;

  /// Đăng xuất khỏi GitHub và Supabase
  Future<void> signOut() async {
    try {
      debugPrint('🚪 [GitHubAuth] Signing out...');
      _setLoading(true);
      _clearError();
      
      // Clear user info
      _userInfo = null;
      _isSignedIn = false;

      // Đăng xuất khỏi Supabase
      await _supabase.auth.signOut();
      
      debugPrint('✅ [GitHubAuth] Signed out successfully');
      _setLoading(false);
    } catch (e, stackTrace) {
      _setError('Lỗi khi đăng xuất: ${e.toString()}');
      debugPrint('Stack trace: $stackTrace');
      _setLoading(false);
    }
  }

  /// Ngắt kết nối GitHub account (alias của signOut)
  Future<void> disconnect() async {
    debugPrint('🔌 [GitHubAuth] Disconnecting GitHub account...');
    await signOut();
  }

  /// Refresh thông tin user từ Supabase
  Future<bool> refreshUserInfo() async {
    try {
      debugPrint('🔄 [GitHubAuth] Refreshing user info...');

      final user = _supabase.auth.currentUser;
      if (user == null) {
        debugPrint('❌ [GitHubAuth] No user to refresh');
        return false;
      }

      // Refresh session để lấy metadata mới nhất
      final response = await _supabase.auth.refreshSession();
      
      if (response.session?.user != null) {
        _updateUserInfo(response.session!.user);
        debugPrint('✅ [GitHubAuth] User info refreshed');
        return true;
      } else {
        debugPrint('❌ [GitHubAuth] Failed to refresh user info');
        return false;
      }
    } catch (e) {
      debugPrint('❌ [GitHubAuth] Refresh error: $e');
      return false;
    }
  }

  /// Cập nhật trạng thái đăng nhập
  void _updateSignInStatus() {
    _isSignedIn = _supabase.auth.currentUser != null;
    debugPrint('🔍 [GitHubAuth] Sign in status updated: $_isSignedIn');
  }

  /// Cập nhật trạng thái loading
  void _setLoading(bool loading) {
    _isLoading = loading;
    debugPrint(loading ? '⏳ [GitHubAuth] Loading...' : '✅ [GitHubAuth] Loading completed');
  }

  /// Xóa thông báo lỗi
  void _clearError() {
    _errorMessage = null;
  }

  /// Đặt thông báo lỗi
  void _setError(String message) {
    _errorMessage = message;
    debugPrint('❌ [GitHubAuth] Error: $message');
  }

  /// Ngắt kết nối GitHub (alias của signOut)
  Future<void> disconnectGitHub() async {
    debugPrint('🔌 [GitHubAuth] Disconnecting GitHub account...');
    await signOut();
  }

  /// Lấy thông tin user hiện tại
  Future<Map<String, dynamic>?> getCurrentUserInfo() async {
    try {
      _setLoading(true);
      _clearError();
      
      final user = _supabase.auth.currentUser;
      if (user == null) {
        debugPrint('❌ [GitHubAuth] No user is currently signed in');
        return null;
      }
      
      // Nếu đã có thông tin user trong cache
      if (_userInfo != null) {
        debugPrint('📦 [GitHubAuth] Returning cached user info');
        return _userInfo;
      }
      
      // Nếu chưa có, cập nhật thông tin user
      await refreshUserInfo();
      return _userInfo;
    } catch (e) {
      _setError('Lỗi khi lấy thông tin người dùng: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Lấy thông tin user hiện tại từ GitHub (cached)
  Map<String, dynamic>? get currentGitHubUser {
    final user = _supabase.auth.currentUser;
    
    // Nếu có user nhưng chưa có cache, cập nhật cache
    if (user != null && _userInfo == null) {
      _updateUserInfo(user);
    }
    
    return _userInfo;
  }

  /// Lấy thông tin user hiện tại từ Supabase
  User? get currentSupabaseUser {
    return _supabase.auth.currentUser;
  }

  /// Lấy access token hiện tại
  String? get accessToken {
    return _supabase.auth.currentSession?.accessToken;
  }

  /// Lấy refresh token hiện tại
  String? get refreshToken {
    return _supabase.auth.currentSession?.refreshToken;
  }

  /// Kiểm tra xem session có hợp lệ không
  bool get hasValidSession {
    final session = _supabase.auth.currentSession;
    if (session == null) return false;

    // Kiểm tra xem token có hết hạn không
    final expiresAt = session.expiresAt;
    if (expiresAt == null) return false;

    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return expiresAt > now;
  }

  /// Lấy thời gian hết hạn của session
  DateTime? get sessionExpiresAt {
    final expiresAt = _supabase.auth.currentSession?.expiresAt;
    if (expiresAt == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(expiresAt * 1000);
  }

  /// Kiểm tra quyền GitHub dựa trên scopes
  /// Mặc định GitHub OAuth có quyền: read:user, user:email
  bool hasScope(String scope) {
    // TODO: Implement scope checking từ token metadata
    // Hiện tại return true vì Supabase GitHub provider mặc định có basic scopes
    return true;
  }

  /// Expose Supabase client để provider có thể lắng nghe auth state
  SupabaseClient get supabase => _supabase;

  /// In thông tin debug về auth state
  void printDebugInfo() {
    if (kDebugMode) {
      debugPrint('=== [GitHubAuth] DEBUG INFO ===');
      debugPrint('Is Signed In: $isSignedIn');
      debugPrint('Has Valid Session: $hasValidSession');
      debugPrint('Session Expires At: $sessionExpiresAt');
      debugPrint('User ID: ${currentSupabaseUser?.id}');
      debugPrint('User Email: ${currentSupabaseUser?.email}');
      debugPrint('GitHub Login: ${_userInfo?['login']}');
      debugPrint('Cached User Info: ${_userInfo != null}');
      debugPrint('==============================');
    }
  }

  /// Dispose service và clean up resources
  void dispose() {
    debugPrint('🧹 [GitHubAuth] Disposing service...');
    _authSubscription?.cancel();
    _authSubscription = null;
    
    // Complete pending completer
    if (_authCompleter != null && !_authCompleter!.isCompleted) {
      _authCompleter!.complete(null);
      _authCompleter = null;
    }
    
    _userInfo = null;
  }
}