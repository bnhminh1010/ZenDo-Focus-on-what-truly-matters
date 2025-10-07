import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ZenDo App Theme Configuration
/// Dựa trên thiết kế Figma với Material 3 Design System
class AppTheme {
  // Colors từ thiết kế Figma
  static const Color primaryColor = Color(0xFF6C63FF); // Màu chính tím
  static const Color secondaryColor = Color(0xFF03DAC6); // Màu phụ xanh mint
  static const Color backgroundColor = Color(0xFFF8F9FA); // Nền sáng
  static const Color surfaceColor = Color(0xFFFFFFFF); // Màu surface
  static const Color errorColor = Color(0xFFB00020); // Màu lỗi
  
  // Light Theme Text Colors
  static const Color textPrimary = Color(0xFF1A1A1A); // Chữ chính
  static const Color textSecondary = Color(0xFF6B7280); // Chữ phụ
  static const Color textHint = Color(0xFF9CA3AF); // Chữ gợi ý
  
  // Dark Theme Colors
  static const Color darkBackgroundColor = Color(0xFF121212); // Nền tối
  static const Color darkSurfaceColor = Color(0xFF1E1E1E); // Surface tối
  static const Color darkTextPrimary = Color(0xFFE5E5E5); // Chữ chính sáng
  static const Color darkTextSecondary = Color(0xFFB0B0B0); // Chữ phụ sáng
  static const Color darkTextHint = Color(0xFF757575); // Chữ gợi ý sáng
  
  // Task Category Colors
  static const Color workColor = Color(0xFF6C63FF); // Công việc
  static const Color personalColor = Color(0xFF10B981); // Cá nhân
  static const Color healthColor = Color(0xFFEF4444); // Sức khỏe
  static const Color familyColor = Color(0xFFF59E0B); // Gia đình
  
  // Neutral Colors
  static const Color grey50 = Color(0xFFF9FAFB);
  static const Color grey100 = Color(0xFFF3F4F6);
  static const Color grey200 = Color(0xFFE5E7EB);
  static const Color grey300 = Color(0xFFD1D5DB);
  static const Color grey400 = Color(0xFF9CA3AF);
  static const Color grey500 = Color(0xFF6B7280);
  static const Color grey600 = Color(0xFF4B5563);
  static const Color grey700 = Color(0xFF374151);
  static const Color grey800 = Color(0xFF1F2937);
  static const Color grey900 = Color(0xFF111827);

  /// Light Theme Configuration
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        // background: backgroundColor, // Deprecated - removed
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
        // onBackground: textPrimary, // Deprecated - removed
        onError: Colors.white,
      ),
      
      // Typography
      textTheme: GoogleFonts.interTextTheme().copyWith(
        // Heading Styles
        headlineLarge: GoogleFonts.inter(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          height: 1.2,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          height: 1.3,
        ),
        headlineSmall: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          height: 1.3,
        ),
        
        // Title Styles
        titleLarge: GoogleFonts.inter(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          height: 1.4,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: textPrimary,
          height: 1.4,
        ),
        titleSmall: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textPrimary,
          height: 1.4,
        ),
        
        // Body Styles
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: textPrimary,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textPrimary,
          height: 1.5,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: textSecondary,
          height: 1.4,
        ),
        
        // Label Styles
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textPrimary,
          height: 1.4,
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textSecondary,
          height: 1.4,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: textHint,
          height: 1.4,
        ),
      ),
      
      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceColor,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        iconTheme: const IconThemeData(
          color: textPrimary,
          size: 24,
        ),
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      
      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: grey50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: grey300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: grey300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: GoogleFonts.inter(
          fontSize: 14,
          color: textHint,
        ),
        labelStyle: GoogleFonts.inter(
          fontSize: 14,
          color: textSecondary,
        ),
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.all(8),
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: grey400,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      
      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),
      
      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: grey200,
        thickness: 1,
        space: 1,
      ),
    );
  }

  /// Dark Theme Configuration
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: darkSurfaceColor,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: darkTextPrimary,
        onError: Colors.white,
      ),
      
      // Typography
      textTheme: GoogleFonts.interTextTheme().copyWith(
        // Heading Styles
        headlineLarge: GoogleFonts.inter(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: darkTextPrimary,
          height: 1.2,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: darkTextPrimary,
          height: 1.3,
        ),
        headlineSmall: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: darkTextPrimary,
          height: 1.3,
        ),
        
        // Title Styles
        titleLarge: GoogleFonts.inter(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: darkTextPrimary,
          height: 1.4,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: darkTextPrimary,
          height: 1.4,
        ),
        titleSmall: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: darkTextPrimary,
          height: 1.4,
        ),
        
        // Body Styles
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: darkTextPrimary,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: darkTextPrimary,
          height: 1.5,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: darkTextSecondary,
          height: 1.4,
        ),
        
        // Label Styles
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: darkTextPrimary,
          height: 1.4,
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: darkTextSecondary,
          height: 1.4,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: darkTextHint,
          height: 1.4,
        ),
      ),
      
      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: darkSurfaceColor,
        foregroundColor: darkTextPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: darkTextPrimary,
        ),
        iconTheme: const IconThemeData(
          color: darkTextPrimary,
          size: 24,
        ),
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      
      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: grey800,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: grey600),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: grey600),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: GoogleFonts.inter(
          fontSize: 14,
          color: darkTextHint,
        ),
        labelStyle: GoogleFonts.inter(
          fontSize: 14,
          color: darkTextSecondary,
        ),
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        color: darkSurfaceColor,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.all(8),
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkSurfaceColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: grey400,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      
      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),
      
      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: grey600,
        thickness: 1,
        space: 1,
      ),
      
      // Scaffold Background Color
      scaffoldBackgroundColor: darkBackgroundColor,
    );
  }
}

/// Extension để dễ dàng truy cập colors
extension AppColors on BuildContext {
  Color get primaryColor => AppTheme.primaryColor;
  Color get secondaryColor => AppTheme.secondaryColor;
  Color get backgroundColor => AppTheme.backgroundColor;
  Color get surfaceColor => AppTheme.surfaceColor;
  Color get textPrimary => AppTheme.textPrimary;
  Color get textSecondary => AppTheme.textSecondary;
  Color get textHint => AppTheme.textHint;
  
  // Task Category Colors
  Color get workColor => AppTheme.workColor;
  Color get personalColor => AppTheme.personalColor;
  Color get healthColor => AppTheme.healthColor;
  Color get familyColor => AppTheme.familyColor;
}

/// Extension để dễ dàng truy cập text styles
extension AppTextStyles on BuildContext {
  TextStyle get headlineLarge => Theme.of(this).textTheme.headlineLarge!;
  TextStyle get headlineMedium => Theme.of(this).textTheme.headlineMedium!;
  TextStyle get headlineSmall => Theme.of(this).textTheme.headlineSmall!;
  TextStyle get titleLarge => Theme.of(this).textTheme.titleLarge!;
  TextStyle get titleMedium => Theme.of(this).textTheme.titleMedium!;
  TextStyle get titleSmall => Theme.of(this).textTheme.titleSmall!;
  TextStyle get bodyLarge => Theme.of(this).textTheme.bodyLarge!;
  TextStyle get bodyMedium => Theme.of(this).textTheme.bodyMedium!;
  TextStyle get bodySmall => Theme.of(this).textTheme.bodySmall!;
  TextStyle get labelLarge => Theme.of(this).textTheme.labelLarge!;
  TextStyle get labelMedium => Theme.of(this).textTheme.labelMedium!;
  TextStyle get labelSmall => Theme.of(this).textTheme.labelSmall!;
}