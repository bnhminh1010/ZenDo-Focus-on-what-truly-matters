import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';
import 'config/supabase_config.dart';

/// Entry point của ZenDo App
/// Cấu hình system UI, khởi tạo Supabase và khởi chạy ứng dụng
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Khởi tạo Supabase client với timeout configuration
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
    // Sử dụng cách cấu hình timeout đơn giản hơn
    debug: kDebugMode,
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
