# TÀI LIỆU CHI TIẾT: CONFIG CLASSES

## 📁 Thư mục: `lib/config/`

### Tổng quan
Thư mục config chứa các file cấu hình cho ứng dụng, quản lý môi trường (development/production), API keys, và các thiết lập hệ thống.

---

## 1️⃣ EnvironmentConfig (`environment_config.dart`)

### 🎯 Mục đích
- Quản lý cấu hình cho các môi trường khác nhau (Development, Staging, Production)
- Cung cấp feature flags để bật/tắt tính năng theo môi trường
- Quản lý timeout và retry settings

### 📊 Enum: Environment
```dart
enum Environment { 
  development,  // Môi trường phát triển
  staging,      // Môi trường test
  production    // Môi trường thực tế
}
```

### 🔑 Properties Chính

#### currentEnvironment
- **Type**: `Environment`
- **Mô tả**: Môi trường hiện tại được xác định bởi `kDebugMode`
- **Logic**: `kDebugMode ? development : production`

#### baseUrl
- **Type**: `String`
- **Development**: `''` (empty - không cần base URL cố định)
- **Staging**: `'https://staging.zendo.app'`
- **Production**: `'https://zendo.app'`

#### supabaseUrl
- **Type**: `String`
- **Development**: `'https://ewfjqvatkzeyccilxzne.supabase.co'`
- **Mô tả**: URL của Supabase project

### 🚩 Feature Flags

```dart
Map<Environment, Map<String, bool>> _featureFlags = {
  development: {
    'enableLogging': true,              // Bật logging
    'enableDebugMode': true,            // Bật debug mode
    'enableAnalytics': false,           // Tắt analytics
    'enableCrashReporting': false,      // Tắt crash report
    'enablePerformanceMonitoring': true // Bật performance monitor
  },
  production: {
    'enableLogging': false,
    'enableDebugMode': false,
    'enableAnalytics': true,
    'enableCrashReporting': true,
    'enablePerformanceMonitoring': false
  }
}
```

### 📡 Methods

#### `isFeatureEnabled(String feature)`
**Mục đích**: Kiểm tra xem một feature có được bật không
```dart
if (EnvironmentConfig.isFeatureEnabled('enableLogging')) {
  debugPrint('Logging is enabled');
}
```

#### `getOAuthRedirectUri(bool isWeb)`
**Mục đích**: Lấy redirect URI phù hợp cho OAuth
**Returns**: 
- Web: `baseUrl`
- Mobile: `supabaseCallbackUrl`

#### `networkTimeout`
**Returns**: `Duration`
- Development: 60 seconds
- Staging: 45 seconds  
- Production: 30 seconds

#### `maxRetryAttempts`
**Returns**: `int`
- Development: 5 lần
- Staging: 3 lần
- Production: 2 lần

---

## 2️⃣ AppConfig (`app_config.dart`)

### 🎯 Mục đích
Cấu hình mặc định cho toàn bộ ứng dụng, bao gồm thông tin app, database, session, UI, animation.

### 📦 Constants

#### App Information
```dart
static const String appName = 'ZenDo';
static const String appVersion = '1.0.0';
static const String appDescription = 'Focus on what truly matters';
```

#### Database Configuration
```dart
static const String databaseName = 'zendo_database.db';
static const int databaseVersion = 1;
```

#### Session Configuration (Pomodoro)
```dart
static const int defaultFocusSessionDuration = 25;    // phút
static const int defaultShortBreakDuration = 5;       // phút
static const int defaultLongBreakDuration = 15;       // phút
```

#### UI Configuration
```dart
static const double defaultBorderRadius = 12.0;
static const double defaultPadding = 16.0;
static const double defaultMargin = 8.0;
```

#### Animation Configuration
```dart
static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
static const Duration shortAnimationDuration = Duration(milliseconds: 150);
static const Duration longAnimationDuration = Duration(milliseconds: 500);
```

### 🚩 Feature Flags (Getters)

```dart
static bool get enableGoogleAuth
static bool get enableGitHubAuth  
static bool get enableGeminiAI
static bool get enableOfflineMode
static bool get enableAnalytics
static bool get enableDebugMode
```

**Tất cả đều delegate sang `EnvironmentConfig.isFeatureEnabled()`**

---

## 3️⃣ SupabaseConfig (`supabase_config.dart`)

### 🎯 Mục đích
Chứa credentials để kết nối với Supabase backend.

### 🔑 Constants

```dart
class SupabaseConfig {
  // Supabase project URL
  static const String url = 'https://ewfjqvatkzeyccilxzne.supabase.co';
  
  // Supabase anon public key (safe for client-side)
  static const String anonKey = 'eyJhbGc...';
}
```

### ⚠️ Lưu ý bảo mật
- ✅ `anonKey`: An toàn để expose trong client-side code
- ❌ `service_role_key`: **KHÔNG BAO GIỜ** expose trong Flutter app
- Chỉ sử dụng `anonKey` cho Flutter applications
- Row Level Security (RLS) của Supabase sẽ bảo vệ data

---

## 🔗 Mối quan hệ giữa các Config classes

```
AppConfig
  │
  ├─→ EnvironmentConfig.isDevelopment
  ├─→ EnvironmentConfig.baseUrl
  ├─→ EnvironmentConfig.isFeatureEnabled()
  └─→ EnvironmentConfig.networkTimeout

SupabaseConfig
  │
  └─→ Được sử dụng bởi main.dart để initialize Supabase

main.dart
  │
  ├─→ EnvironmentConfig.printEnvironmentInfo()
  ├─→ AppConfig.printConfigInfo()
  └─→ SupabaseConfig.url & anonKey
```

---

## 🎓 Khi nào sử dụng từng Config?

### EnvironmentConfig
**Sử dụng khi:**
- Cần kiểm tra môi trường hiện tại
- Cần bật/tắt feature theo môi trường
- Cần URL cho API calls
- Cần timeout/retry settings

**Example:**
```dart
if (EnvironmentConfig.isDevelopment) {
  debugPrint('Running in development mode');
}
```

### AppConfig
**Sử dụng khi:**
- Cần constants cho UI (padding, radius, etc.)
- Cần animation durations
- Cần session configurations

**Example:**
```dart
Container(
  padding: EdgeInsets.all(AppConfig.defaultPadding),
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(AppConfig.defaultBorderRadius),
  ),
)
```

### SupabaseConfig
**Sử dụng khi:**
- Initialize Supabase client (trong main.dart)

**Example:**
```dart
await Supabase.initialize(
  url: SupabaseConfig.url,
  anonKey: SupabaseConfig.anonKey,
);
```

---

✅ **Hoàn thành tài liệu Config Classes!**
