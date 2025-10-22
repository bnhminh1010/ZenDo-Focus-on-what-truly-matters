# ZenDo Configuration Guide

## Cấu hình mặc định trong code

Ứng dụng ZenDo đã được cấu hình với các giá trị mặc định để bạn không cần phải chạy lệnh với tham số mỗi lần.

### 🔧 Các file cấu hình

#### 1. `lib/config/environment_config.dart`
- Quản lý các môi trường: Development, Staging, Production
- Tự động chọn môi trường dựa trên `kDebugMode`
- Cấu hình URL, API keys, feature flags cho từng môi trường

#### 2. `lib/config/app_config.dart`
- Cấu hình ứng dụng chung
- Sử dụng `EnvironmentConfig` để lấy giá trị phù hợp
- Quản lý OAuth redirect URIs, timeouts, retry attempts

#### 3. `lib/config/flutter_config.dart`
- Cấu hình Flutter cho các platform
- Tạo launch configurations và run scripts
- Quản lý arguments cho `flutter run`

### 🚀 Cách chạy ứng dụng

#### Phương pháp 1: Sử dụng batch script (Khuyến nghị)
```bash
# Chạy file batch đã được cấu hình sẵn
run_dev.bat
```

#### Phương pháp 2: VS Code Launch Configuration
1. Mở VS Code
2. Nhấn `F5` hoặc `Ctrl+F5`
3. Chọn configuration phù hợp:
   - **ZenDo Web (Development)**: Chạy web server trên localhost:3000
   - **ZenDo Web (Chrome)**: Mở trực tiếp trong Chrome
   - **ZenDo Mobile (Development)**: Chạy trên mobile device/emulator
   - **ZenDo Desktop (Windows)**: Chạy desktop app

#### Phương pháp 3: Flutter CLI (vẫn hoạt động như cũ)
```bash
# Vẫn có thể chạy lệnh truyền thống
flutter run -d web-server --web-port 3000 --web-hostname localhost
```

### 📋 Cấu hình mặc định

#### Web Development
- **Port**: 3000
- **Hostname**: localhost
- **Renderer**: html
- **Hot Reload**: Enabled
- **Source Maps**: Enabled

#### OAuth Configuration
- **Web Redirect**: `http://localhost:3000`
- **Supabase Callback**: `https://ewfjqvatkzeyccilxzne.supabase.co/auth/v1/callback`

#### Environment-specific Settings

**Development:**
- Debug Mode: ✅ Enabled
- Logging: ✅ Enabled
- Analytics: ❌ Disabled
- Performance Monitoring: ✅ Enabled
- Network Timeout: 60 seconds
- Max Retry: 5 attempts

**Production:**
- Debug Mode: ❌ Disabled
- Logging: ❌ Disabled
- Analytics: ✅ Enabled
- Performance Monitoring: ❌ Disabled
- Network Timeout: 30 seconds
- Max Retry: 2 attempts

### 🛠️ Tùy chỉnh cấu hình

#### Thay đổi port mặc định
Sửa trong `lib/config/flutter_config.dart`:
```dart
static const Map<String, dynamic> webConfig = {
  'port': 8080, // Thay đổi port ở đây
  'hostname': 'localhost',
  // ...
};
```

#### Thêm môi trường mới
Sửa trong `lib/config/environment_config.dart`:
```dart
enum Environment {
  development,
  staging,
  production,
  testing, // Thêm môi trường mới
}
```

#### Thay đổi feature flags
Sửa trong `lib/config/environment_config.dart`:
```dart
static const Map<Environment, Map<String, bool>> _featureFlags = {
  Environment.development: {
    'enableNewFeature': true, // Thêm feature flag mới
    // ...
  },
};
```

### 🔍 Debug và Monitoring

Trong development mode, ứng dụng sẽ tự động in thông tin cấu hình:

```
=== ENVIRONMENT INFO ===
Environment: Environment.development
Base URL: http://localhost:3000
Supabase URL: https://ewfjqvatkzeyccilxzne.supabase.co
Feature Flags: {enableLogging: true, enableDebugMode: true, ...}
========================

=== APP CONFIG INFO ===
Google Auth: true
GitHub Auth: true
Gemini AI: true
Analytics: false
=======================
```

### 📝 Lưu ý quan trọng

1. **Environment Variables**: Vẫn cần file `.env` cho các API keys thực tế
2. **OAuth Setup**: Cần cấu hình OAuth providers trong Supabase Dashboard
3. **Production**: Nhớ thay đổi API keys và URLs khi deploy production
4. **Security**: Không commit API keys thực tế vào repository

### 🔗 Liên kết hữu ích

- [Flutter Configuration](https://docs.flutter.dev/development/tools/vs-code#launch-configuration)
- [Supabase Auth](https://supabase.com/docs/guides/auth)
- [Environment Variables](https://pub.dev/packages/flutter_dotenv)