import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

/// Service để xử lý Google Sign-In authentication
/// Tích hợp với Supabase Auth để đồng bộ user data
/// Lưu ý: Google Sign-In chỉ hỗ trợ Android, iOS, macOS và Web
class GoogleAuthService {
  static final GoogleAuthService _instance = GoogleAuthService._internal();
  factory GoogleAuthService() => _instance;
  GoogleAuthService._internal();

  // Google Sign-In instance với clientId từ environment
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: dotenv.env['GOOGLE_CLIENT_ID'],
    scopes: [
      'email',
      'profile',
    ],
  );

  // Supabase client
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Đăng nhập bằng Google
  /// Returns: User nếu thành công, null nếu thất bại hoặc user hủy
  Future<User?> signInWithGoogle() async {
    try {
      // Kiểm tra platform support
      if (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux) {
        print('Google Sign-In không được hỗ trợ trên ${defaultTargetPlatform.name}');
        return null;
      }

      // Bước 1: Đăng nhập Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User hủy đăng nhập
        return null;
      }

      // Bước 2: Lấy Google authentication credentials
      final GoogleSignInAuthentication googleAuth = 
          await googleUser.authentication;

      final String? accessToken = googleAuth.accessToken;
      final String? idToken = googleAuth.idToken;

      if (accessToken == null || idToken == null) {
        throw Exception('Failed to get Google authentication tokens');
      }

      // Bước 3: Đăng nhập vào Supabase với Google credentials
      final AuthResponse response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      return response.user;
    } catch (e) {
      print('Google Sign-In Error: $e');
      return null;
    }
  }

  /// Đăng xuất khỏi Google và Supabase
  Future<void> signOut() async {
    try {
      // Đăng xuất khỏi Google (chỉ trên platform được hỗ trợ)
      if (defaultTargetPlatform != TargetPlatform.windows &&
          defaultTargetPlatform != TargetPlatform.linux) {
        await _googleSignIn.signOut();
      }
      
      // Đăng xuất khỏi Supabase
      await _supabase.auth.signOut();
    } catch (e) {
      print('Sign Out Error: $e');
    }
  }

  /// Kiểm tra xem user có đang đăng nhập Google không
  Future<bool> isSignedIn() async {
    try {
      // Kiểm tra platform support
      if (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux) {
        // Trên Windows/Linux, chỉ kiểm tra Supabase user
        final User? supabaseUser = _supabase.auth.currentUser;
        return supabaseUser != null;
      }

      final GoogleSignInAccount? account = await _googleSignIn.isSignedIn()
          ? _googleSignIn.currentUser
          : null;
      
      final User? supabaseUser = _supabase.auth.currentUser;
      
      return account != null && supabaseUser != null;
    } catch (e) {
      print('Check Sign-In Status Error: $e');
      return false;
    }
  }

  /// Lấy thông tin user hiện tại từ Google
  GoogleSignInAccount? get currentGoogleUser => _googleSignIn.currentUser;

  /// Lấy thông tin user hiện tại từ Supabase
  User? get currentSupabaseUser => _supabase.auth.currentUser;

  /// Ngắt kết nối hoàn toàn khỏi Google account
  Future<void> disconnect() async {
    try {
      // Ngắt kết nối Google (chỉ trên platform được hỗ trợ)
      if (defaultTargetPlatform != TargetPlatform.windows &&
          defaultTargetPlatform != TargetPlatform.linux) {
        await _googleSignIn.disconnect();
      }
      
      // Đăng xuất khỏi Supabase
      await _supabase.auth.signOut();
    } catch (e) {
      print('Disconnect Error: $e');
    }
  }
}