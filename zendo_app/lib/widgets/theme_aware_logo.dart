/*
 * Tên: widgets/theme_aware_logo.dart
 * Tác dụng: Hiển thị logo ứng dụng (PNG) thích ứng mọi theme, kèm biến thể animated.
 * Khi nào dùng: AppBar, Splash/Onboarding, màn đăng nhập.
 */
import 'package:flutter/material.dart';

/// Widget logo sử dụng logo duy nhất cho mọi theme
class ThemeAwareLogo extends StatelessWidget {
  /// Chiều rộng logo (optional).
  final double? width;
  /// Chiều cao logo (optional).
  final double? height;
  /// BoxFit khi vẽ logo.
  final BoxFit fit;

  const ThemeAwareLogo({
    Key? key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/icons/logo.png',
      width: width,
      height: height,
      fit: fit,
    );
  }
}

/// Widget logo với animation - sử dụng logo duy nhất
class AnimatedThemeAwareLogo extends StatelessWidget {
  /// Chiều rộng logo (optional).
  final double? width;
  /// Chiều cao logo (optional).
  final double? height;
  /// BoxFit khi vẽ logo.
  final BoxFit fit;
  /// Thời gian animation cross-fade.
  final Duration duration;

  const AnimatedThemeAwareLogo({
    Key? key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.duration = const Duration(milliseconds: 300),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      child: Image.asset(
        'assets/icons/logo.png',
        key: const ValueKey('logo'),
        width: width,
        height: height,
        fit: fit,
      ),
    );
  }
}
