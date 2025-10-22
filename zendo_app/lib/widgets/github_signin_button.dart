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
            onPressed: provider.isLoading
                ? null
                : () => _handleSignIn(context, provider),
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
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: Image.asset(
                          'assets/icons/github.png',
                          width: 20,
                          height: 20,
                          fit: BoxFit.contain,
                          color: Colors.white, // Tô màu trắng cho icon
                        ),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          text ?? 'Đăng nhập bằng GitHub',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
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
  Future<void> _handleSignIn(
    BuildContext context,
    GitHubSignInProvider provider,
  ) async {
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }
}

/// Custom painter để vẽ GitHub icon - DEPRECATED, sử dụng PNG thay thế
class GitHubIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Deprecated - sử dụng PNG thay thế
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
        return SizedBox(
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
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF24292e),
                      ),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: Image.asset(
                          'assets/icons/github.png',
                          width: 20,
                          height: 20,
                          fit: BoxFit.contain,
                          color: const Color(
                            0xFF24292e,
                          ), // Tô màu GitHub cho outlined button
                        ),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          text ?? 'Đăng nhập bằng GitHub',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
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

/// GitHub icon painter cho outlined button - DEPRECATED, sử dụng PNG thay thế
class GitHubIconPainterOutlined extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Deprecated - sử dụng PNG thay thế
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

