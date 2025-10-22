image.png# 🖥️ Cấu hình OAuth cho Desktop với PKCE

## 🎯 Vấn đề
Khi chạy Flutter Desktop (Windows/macOS/Linux), OAuth vẫn redirect về `localhost:3000` thay vì sử dụng PKCE flow.

## ✅ Giải pháp: Cấu hình Desktop OAuth

### 1. 🔧 Cấu hình Supabase Dashboard

Truy cập: https://supabase.com/dashboard/project/ewfjqvatkzeyccilxzne/auth/url-configuration

#### Site URL (thêm custom scheme)
```
http://localhost:3000
com.zendo.app://auth/callback
```

#### Redirect URLs (thêm desktop schemes)
```
http://localhost:3000
http://localhost:3000/auth/callback
http://localhost:3000/#/auth/callback
com.zendo.app://auth/callback
com.zendo.app://login-callback
```

### 2. 🔧 Cấu hình Google OAuth Console

Truy cập: https://console.developers.google.com/

#### Authorized redirect URIs (thêm desktop)
```
https://ewfjqvatkzeyccilxzne.supabase.co/auth/v1/callback
http://localhost:3000
com.zendo.app://auth/callback
```

### 3. 📱 Cấu hình trong Flutter Code

#### File: `lib/services/google_auth_service.dart`
```dart
Future<User?> _signInWithSupabaseOAuth() async {
  try {
    String? redirect;
    if (kIsWeb) {
      redirect = Uri.base.origin; // Web: localhost:3000
    } else {
      // Desktop: sử dụng custom scheme hoặc null cho PKCE
      redirect = 'com.zendo.app://auth/callback'; // hoặc null
    }

    final started = await _supabase.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: redirect,
      authScreenLaunchMode: LaunchMode.externalApplication,
    );
    // ...
  }
}
```

### 4. 🔄 Alternative: Pure PKCE (Recommended)

#### Sử dụng `redirectTo: null` cho Desktop
```dart
Future<User?> _signInWithSupabaseOAuth() async {
  try {
    String? redirect;
    if (kIsWeb) {
      redirect = Uri.base.origin; // Web cần redirect URL
    } else {
      redirect = null; // Desktop: PKCE không cần redirect
    }

    final started = await _supabase.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: redirect,
      authScreenLaunchMode: LaunchMode.externalApplication,
    );
    // ...
  }
}
```

### 5. 🧪 Test Flow

1. **Web**: `flutter run -d web-server --web-port 3000`
   - Redirect: `http://localhost:3000`
   
2. **Desktop**: `flutter run -d windows`
   - Redirect: `null` (PKCE flow)
   - Hoặc: `com.zendo.app://auth/callback`

### 6. 📝 Lưu ý quan trọng

- **PKCE Flow**: Không cần redirect URL cụ thể cho desktop
- **Custom Scheme**: Cần đăng ký trong OS (Windows Registry, macOS Info.plist)
- **Supabase**: Hỗ trợ cả redirect URL và PKCE flow
- **Google OAuth**: Cần cấu hình cả hai loại redirect URIs

### 7. 🔍 Debug

Kiểm tra logs để xem redirect URL nào được sử dụng:
```dart
debugPrint('Platform: ${kIsWeb ? "Web" : "Desktop"}');
debugPrint('Redirect URL: $redirect');
```