/*
 * Tên: main.dart
 * Tác dụng: Điểm vào ứng dụng; cấu hình System UI, tải biến môi trường, khởi tạo Supabase, và chạy ZendoApp.
 * Khi nào dùng: Luôn dùng khi khởi chạy ứng dụng, được IDE/Flutter gọi đầu tiên.
 */
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Import configurations
import 'config/app_config.dart';
import 'config/environment_config.dart';
import 'config/flutter_config.dart';
import 'config/supabase_config.dart';

// Import app
import 'app.dart';

/// Entry point của ZenDo App
/// Cấu hình system UI, khởi tạo Supabase và khởi chạy ứng dụng
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // In thông tin môi trường và cấu hình (chỉ trong development)
  if (EnvironmentConfig.isDevelopment) {
    AppConfig.printConfigInfo();
    FlutterConfig.printCurrentConfig();
  }

  // Load environment variables (chỉ trong development)
  if (EnvironmentConfig.isDevelopment) {
    try {
      await dotenv.load(fileName: ".env");
    } catch (e) {
      if (kDebugMode) {
        print('Warning: Could not load .env file: $e');
      }
    }
  }

  // Khởi tạo Supabase client với PKCE cho desktop OAuth
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce, // QUAN TRỌNG cho desktop OAuth
    ),
    debug: AppConfig.enableDebugMode,
  );

  // Cấu hình System UI Overlay (status bar, navigation bar)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Khóa orientation ở portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const ZendoApp());
}

