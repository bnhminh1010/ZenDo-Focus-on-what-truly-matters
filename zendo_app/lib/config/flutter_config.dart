import 'dart:io';
import 'package:flutter/foundation.dart';
import 'environment_config.dart';

/// Cấu hình Flutter cho các platform khác nhau
class FlutterConfig {
  /// Cấu hình mặc định cho Flutter Web
  static const Map<String, dynamic> webConfig = {
    'port': 3000,
    'hostname': 'localhost',
    'sourceMaps': true,
    'pwaStrategy': 'offline-first',
  };

  /// Cấu hình mặc định cho Flutter Desktop
  static const Map<String, dynamic> desktopConfig = {
    'windowWidth': 1200.0,
    'windowHeight': 800.0,
    'windowTitle': 'ZenDo - Focus on what truly matters',
    'resizable': true,
  };

  /// Cấu hình mặc định cho Flutter Mobile
  static const Map<String, dynamic> mobileConfig = {
    'orientation': 'portrait',
    'statusBarColor': '#1976D2',
    'navigationBarColor': '#1976D2',
  };

  /// Lấy cấu hình dựa trên platform hiện tại
  static Map<String, dynamic> getCurrentPlatformConfig() {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      return desktopConfig;
    } else if (Platform.isAndroid || Platform.isIOS) {
      return mobileConfig;
    } else {
      return webConfig;
    }
  }

  /// Tạo command line arguments cho Flutter run
  static List<String> getFlutterRunArgs({
    String? device,
    String? flavor,
    bool? debug,
    bool? release,
    bool? profile,
  }) {
    List<String> args = [];

    // Device target
    if (device != null) {
      args.addAll(['-d', device]);
    }

    // Build mode
    if (debug == true) {
      args.add('--debug');
    } else if (release == true) {
      args.add('--release');
    } else if (profile == true) {
      args.add('--profile');
    }

    // Flavor
    if (flavor != null) {
      args.addAll(['--flavor', flavor]);
    }

    // Web specific arguments
    if (device == 'web-server' || device == 'chrome') {
      args.addAll([
        '--web-port',
        webConfig['port'].toString(),
        '--web-hostname',
        webConfig['hostname'],
      ]);

      if (EnvironmentConfig.isDevelopment) {
        args.add('--dart-define=FLUTTER_WEB_USE_SKIA=true');
      }
    }

    // Development specific arguments
    if (EnvironmentConfig.isDevelopment) {
      args.addAll([
        '--hot',
        '--enable-software-rendering',
        '--dart-define=ENVIRONMENT=development',
      ]);
    }

    return args;
  }

  /// Tạo script chạy ứng dụng cho platform hiện tại
  static String generateRunScript({
    String device = 'web-server',
    bool debug = true,
  }) {
    final args = getFlutterRunArgs(device: device, debug: debug);

    return 'flutter run ${args.join(' ')}';
  }

  /// Tạo file batch script cho Windows
  static void createWindowsBatchFile() {
    final script =
        '''@echo off
echo Starting ZenDo Flutter App...
echo Environment: ${EnvironmentConfig.currentEnvironment}
echo Base URL: ${EnvironmentConfig.baseUrl}

REM Web Development
flutter run -d web-server --web-port ${webConfig['port']} --web-hostname ${webConfig['hostname']} --web-renderer ${webConfig['renderer']} --hot

pause
''';

    final file = File('run_web_dev.bat');
    file.writeAsStringSync(script);
    if (kDebugMode) {
      debugPrint('Created run_web_dev.bat');
    }
  }

  /// Tạo file shell script cho Linux/Mac
  static void createShellScript() {
    final script =
        '''#!/bin/bash
echo "Starting ZenDo Flutter App..."
echo "Environment: ${EnvironmentConfig.currentEnvironment}"
echo "Base URL: ${EnvironmentConfig.baseUrl}"

# Web Development
flutter run -d web-server --web-port ${webConfig['port']} --web-hostname ${webConfig['hostname']} --web-renderer ${webConfig['renderer']} --hot
''';

    final file = File('run_web_dev.sh');
    file.writeAsStringSync(script);

    // Make executable
    Process.run('chmod', ['+x', 'run_web_dev.sh']);
    if (kDebugMode) {
      debugPrint('Created run_web_dev.sh');
    }
  }

  /// Tạo launch configuration cho VS Code
  static void createVSCodeLaunchConfig() {
    final config = {
      "version": "0.2.0",
      "configurations": [
        {
          "name": "ZenDo Web (Development)",
          "request": "launch",
          "type": "dart",
          "program": "lib/main.dart",
          "args": [
            "--web-port",
            webConfig['port'],
            "--web-hostname",
            webConfig['hostname'],
            "--web-renderer",
            webConfig['renderer'],
          ],
          "env": {"ENVIRONMENT": "development"},
        },
        {
          "name": "ZenDo Mobile (Development)",
          "request": "launch",
          "type": "dart",
          "program": "lib/main.dart",
          "env": {"ENVIRONMENT": "development"},
        },
        {
          "name": "ZenDo Desktop (Development)",
          "request": "launch",
          "type": "dart",
          "program": "lib/main.dart",
          "args": ["-d", "windows"],
          "env": {"ENVIRONMENT": "development"},
        },
      ],
    };

    // Tạo thư mục .vscode nếu chưa có
    final vsCodeDir = Directory('.vscode');
    if (!vsCodeDir.existsSync()) {
      vsCodeDir.createSync();
    }

    final file = File('.vscode/launch.json');
    file.writeAsStringSync(
      '''${config.toString().replaceAll('{', '{\n  ').replaceAll('}', '\n}')}''',
    );
    if (kDebugMode) {
      debugPrint('Created .vscode/launch.json');
    }
  }

  /// In thông tin cấu hình hiện tại
  static void printCurrentConfig() {
    if (EnvironmentConfig.isDevelopment) {
      debugPrint('=== FLUTTER CONFIG ===');
      debugPrint('Platform: ${Platform.operatingSystem}');
      debugPrint('Web Config: $webConfig');
      debugPrint('Current Config: ${getCurrentPlatformConfig()}');
      debugPrint('Run Command: ${generateRunScript()}');
      debugPrint('======================');
    }
  }
}

