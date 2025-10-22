import 'package:flutter/material.dart';

/// Widget logo tự động thay đổi theo dark/light theme
class ThemeAwareLogo extends StatelessWidget {
  final double? width;
  final double? height;
  final BoxFit fit;

  const ThemeAwareLogo({
    Key? key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Kiểm tra theme hiện tại
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Image.asset(
      // Chọn logo phù hợp với theme
      isDarkMode 
        ? 'assets/icons/LogoLightMode.png'  // Logo sáng cho dark mode
        : 'assets/icons/LogoDarkMode.png',   // Logo tối cho light mode
      width: width,
      height: height,
      fit: fit,
    );
  }
}

/// Widget logo với animation khi chuyển theme
class AnimatedThemeAwareLogo extends StatelessWidget {
  final double? width;
  final double? height;
  final BoxFit fit;
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return AnimatedSwitcher(
      duration: duration,
      child: Image.asset(
        isDarkMode 
          ? 'assets/icons/LogoLightMode.png'
          : 'assets/icons/LogoDarkMode.png',
        key: ValueKey(isDarkMode), // Key để trigger animation
        width: width,
        height: height,
        fit: fit,
      ),
    );
  }
}