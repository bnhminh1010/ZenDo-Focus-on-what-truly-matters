import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/github_signin_provider.dart';

/// Widget button để đăng nhập bằng GitHub
/// Tích hợp với GitHubSignInProvider và có Material 3 design
class GitHubSignInButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String? text;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;

  const GitHubSignInButton({
    super.key,
    this.onPressed,
    this.text,
    this.width,
    this.height,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<GitHubSignInProvider>(
      builder: (context, provider, child) {
        return Container(
          width: width ?? double.infinity,
          height: height ?? 56,
          padding: padding,
          child: ElevatedButton(
            onPressed: provider.isLoading ? null : () => _handleSignIn(context, provider),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF24292e), // GitHub dark color
              foregroundColor: Colors.white,
              elevation: 2,
              shadowColor: Colors.black26,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: provider.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(20, 20),
                        painter: GitHubIconPainter(),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        text ?? 'Đăng nhập bằng GitHub',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  /// Xử lý sự kiện đăng nhập
  Future<void> _handleSignIn(BuildContext context, GitHubSignInProvider provider) async {
    // Clear error trước khi đăng nhập
    provider.clearError();
    
    // Gọi callback nếu có
    if (onPressed != null) {
      onPressed!();
      return;
    }

    // Thực hiện đăng nhập
    final success = await provider.signIn();
    
    if (!success && provider.errorMessage != null && context.mounted) {
      // Hiển thị error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage!),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }
}

/// Custom painter để vẽ GitHub icon
class GitHubIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();
    
    // GitHub icon path (simplified version)
    // Vẽ GitHub logo dựa trên SVG path
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = size.width * 0.45;
    
    // Main circle
    path.addOval(Rect.fromCircle(
      center: Offset(centerX, centerY),
      radius: radius,
    ));
    
    // Cat ears (simplified)
    path.moveTo(centerX - radius * 0.6, centerY - radius * 0.8);
    path.lineTo(centerX - radius * 0.3, centerY - radius * 0.5);
    path.lineTo(centerX - radius * 0.8, centerY - radius * 0.3);
    path.close();
    
    path.moveTo(centerX + radius * 0.6, centerY - radius * 0.8);
    path.lineTo(centerX + radius * 0.3, centerY - radius * 0.5);
    path.lineTo(centerX + radius * 0.8, centerY - radius * 0.3);
    path.close();
    
    canvas.drawPath(path, paint);
    
    // Draw simplified GitHub cat face
    final facePaint = Paint()
      ..color = const Color(0xFF24292e)
      ..style = PaintingStyle.fill;
    
    // Eyes
    canvas.drawCircle(
      Offset(centerX - radius * 0.3, centerY - radius * 0.2),
      radius * 0.15,
      facePaint,
    );
    canvas.drawCircle(
      Offset(centerX + radius * 0.3, centerY - radius * 0.2),
      radius * 0.15,
      facePaint,
    );
    
    // Mouth area
    final mouthPath = Path();
    mouthPath.moveTo(centerX - radius * 0.4, centerY + radius * 0.1);
    mouthPath.quadraticBezierTo(
      centerX, centerY + radius * 0.4,
      centerX + radius * 0.4, centerY + radius * 0.1,
    );
    mouthPath.lineTo(centerX + radius * 0.2, centerY + radius * 0.6);
    mouthPath.lineTo(centerX - radius * 0.2, centerY + radius * 0.6);
    mouthPath.close();
    
    canvas.drawPath(mouthPath, facePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Variant của GitHub button với outline style
class GitHubSignInButtonOutlined extends StatelessWidget {
  final VoidCallback? onPressed;
  final String? text;
  final double? width;
  final double? height;

  const GitHubSignInButtonOutlined({
    super.key,
    this.onPressed,
    this.text,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<GitHubSignInProvider>(
      builder: (context, provider, child) {
        return Container(
          width: width ?? double.infinity,
          height: height ?? 56,
          child: OutlinedButton(
            onPressed: provider.isLoading ? null : onPressed,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF24292e), width: 2),
              foregroundColor: const Color(0xFF24292e),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: provider.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF24292e)),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(20, 20),
                        painter: GitHubIconPainterOutlined(),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        text ?? 'Đăng nhập bằng GitHub',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}

/// GitHub icon painter cho outlined button
class GitHubIconPainterOutlined extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF24292e)
      ..style = PaintingStyle.fill;

    // Sử dụng cùng logic như GitHubIconPainter nhưng với màu khác
    final path = Path();
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = size.width * 0.45;
    
    path.addOval(Rect.fromCircle(
      center: Offset(centerX, centerY),
      radius: radius,
    ));
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}