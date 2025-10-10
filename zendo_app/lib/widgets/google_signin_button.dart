import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../providers/google_signin_provider.dart';

/// Custom Google Sign-In Button với Material 3 design
/// Tự động xử lý loading state và error handling
class GoogleSignInButton extends StatelessWidget {
  final VoidCallback? onSignInSuccess;
  final VoidCallback? onSignInError;
  final String? customText;
  final bool showIcon;
  final double? width;
  final double? height;

  const GoogleSignInButton({
    super.key,
    this.onSignInSuccess,
    this.onSignInError,
    this.customText,
    this.showIcon = true,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<GoogleSignInProvider>(
      builder: (context, provider, child) {
        return SizedBox(
          width: width ?? double.infinity,
          height: height ?? 56,
          child: ElevatedButton(
            onPressed: provider.isLoading ? null : () => _handleSignIn(context, provider),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              elevation: 2,
              shadowColor: Colors.black26,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: provider.isLoading
                ? _buildLoadingContent()
                : _buildButtonContent(context),
          ),
        );
      },
    );
  }

  /// Xử lý sự kiện đăng nhập
  Future<void> _handleSignIn(BuildContext context, GoogleSignInProvider provider) async {
    // Kiểm tra platform support
    if (defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Google Sign-In không được hỗ trợ trên Windows/Linux. Vui lòng sử dụng GitHub Sign-In.'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    final success = await provider.signInWithGoogle();
    
    if (success) {
      onSignInSuccess?.call();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đăng nhập thành công! Chào mừng ${provider.displayName}'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      onSignInError?.call();
      if (context.mounted && provider.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage!),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Build loading content
  Widget _buildLoadingContent() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey.shade600),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'Đang đăng nhập...',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  /// Build button content
  Widget _buildButtonContent(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (showIcon) ...[
          _buildGoogleIcon(),
          const SizedBox(width: 12),
        ],
        Flexible(
          child: Text(
            customText ?? 'Đăng nhập bằng Google',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// Build Google icon (SVG-like design)
  Widget _buildGoogleIcon() {
    return Container(
      width: 24,
      height: 24,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
      ),
      child: CustomPaint(
        painter: GoogleIconPainter(),
      ),
    );
  }
}

/// Custom painter để vẽ Google icon
class GoogleIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    
    // Google "G" colors
    const blueColor = Color(0xFF4285F4);
    const redColor = Color(0xFFEA4335);
    const yellowColor = Color(0xFFFBBC05);
    const greenColor = Color(0xFF34A853);
    
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    // Draw blue arc (top-right)
    paint.color = blueColor;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.57, // -90 degrees
      1.57,  // 90 degrees
      true,
      paint,
    );
    
    // Draw red arc (top-left)
    paint.color = redColor;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14, // -180 degrees
      1.57,  // 90 degrees
      true,
      paint,
    );
    
    // Draw yellow arc (bottom-left)
    paint.color = yellowColor;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.57, // -90 degrees
      -1.57, // -90 degrees
      true,
      paint,
    );
    
    // Draw green arc (bottom-right)
    paint.color = greenColor;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0,     // 0 degrees
      1.57,  // 90 degrees
      true,
      paint,
    );
    
    // Draw white center circle
    paint.color = Colors.white;
    canvas.drawCircle(center, radius * 0.4, paint);
    
    // Draw "G" shape
    paint.color = Colors.grey.shade700;
    paint.strokeWidth = 1.5;
    paint.style = PaintingStyle.stroke;
    
    final path = Path();
    path.addArc(
      Rect.fromCircle(center: center, radius: radius * 0.3),
      -1.57, // Start from top
      3.14,  // Half circle
    );
    
    canvas.drawPath(path, paint);
    
    // Draw horizontal line for "G"
    canvas.drawLine(
      Offset(center.dx, center.dy - radius * 0.1),
      Offset(center.dx + radius * 0.25, center.dy - radius * 0.1),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Compact version của Google Sign-In Button (chỉ icon)
class GoogleSignInIconButton extends StatelessWidget {
  final VoidCallback? onSignInSuccess;
  final VoidCallback? onSignInError;
  final double size;

  const GoogleSignInIconButton({
    super.key,
    this.onSignInSuccess,
    this.onSignInError,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<GoogleSignInProvider>(
      builder: (context, provider, child) {
        return SizedBox(
          width: size,
          height: size,
          child: ElevatedButton(
            onPressed: provider.isLoading ? null : () => _handleSignIn(context, provider),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              elevation: 2,
              shadowColor: Colors.black26,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(size / 4),
                side: BorderSide(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
              ),
              padding: EdgeInsets.zero,
            ),
            child: provider.isLoading
                ? SizedBox(
                    width: size * 0.4,
                    height: size * 0.4,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.grey.shade600),
                    ),
                  )
                : Container(
                    width: size * 0.5,
                    height: size * 0.5,
                    decoration: const BoxDecoration(shape: BoxShape.circle),
                    child: CustomPaint(painter: GoogleIconPainter()),
                  ),
          ),
        );
      },
    );
  }

  Future<void> _handleSignIn(BuildContext context, GoogleSignInProvider provider) async {
    final success = await provider.signInWithGoogle();
    
    if (success) {
      onSignInSuccess?.call();
    } else {
      onSignInError?.call();
      if (context.mounted && provider.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage!),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}