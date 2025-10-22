import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/google_signin_provider.dart';
import '../providers/auth_model.dart';
import '../widgets/loading_state_widget.dart';
import '../theme.dart'; // Import theme để sử dụng AppColors extension

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
            onPressed: provider.isLoading
                ? null
                : () => _handleSignIn(context, provider),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.surface,
              foregroundColor: Theme.of(context).colorScheme.onSurface,
              elevation: 2,
              shadowColor: Theme.of(
                context,
              ).colorScheme.shadow.withOpacity(0.26),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: context.grey300, width: 1),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: provider.isLoading
                ? LoadingStateWidget(size: 24)
                : _buildButtonContent(context),
          ),
        );
      },
    );
  }

  /// Xử lý sự kiện đăng nhập
  Future<void> _handleSignIn(
    BuildContext context,
    GoogleSignInProvider provider,
  ) async {
    final success = await provider.signInWithGoogle();

    if (success) {
      // Cập nhật AuthModel để GoRouter có thể redirect
      if (context.mounted) {
        final authModel = Provider.of<AuthModel>(context, listen: false);
        authModel.updateFromGoogleAuth(
          true,
          provider.email,
          provider.displayName,
        );
      }

      onSignInSuccess?.call();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Đăng nhập thành công! Chào mừng ${provider.displayName}',
            ),
            backgroundColor: context.successColor,
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
            backgroundColor: context.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Build loading content

  /// Build button content
  Widget _buildButtonContent(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (showIcon) ...[_buildGoogleIcon(context), const SizedBox(width: 12)],
        Flexible(
          child: Text(
            customText ?? 'Đăng nhập bằng Google',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  /// Build Google icon (sử dụng ảnh PNG)
  Widget _buildGoogleIcon(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 24,
      child: Image.asset(
        'assets/icons/google.png',
        width: 24,
        height: 24,
        fit: BoxFit.contain,
      ),
    );
  }
}

/// Custom painter để vẽ Google icon - DEPRECATED, sử dụng PNG thay thế
class GoogleIconPainter extends CustomPainter {
  final Color centerColor;
  final Color strokeColor;

  GoogleIconPainter({required this.centerColor, required this.strokeColor});

  @override
  void paint(Canvas canvas, Size size) {
    // Deprecated - sử dụng PNG thay thế
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
            onPressed: provider.isLoading
                ? null
                : () => _handleSignIn(context, provider),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.surface,
              elevation: 2,
              shadowColor: Theme.of(
                context,
              ).colorScheme.shadow.withOpacity(0.26),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(size / 4),
                side: BorderSide(color: context.grey300, width: 1),
              ),
              padding: EdgeInsets.zero,
            ),
            child: provider.isLoading
                ? LoadingStateWidget(size: size * 0.4)
                : SizedBox(
                    width: size * 0.5,
                    height: size * 0.5,
                    child: Image.asset(
                      'assets/icons/google.png',
                      width: size * 0.5,
                      height: size * 0.5,
                      fit: BoxFit.contain,
                    ),
                  ),
          ),
        );
      },
    );
  }

  Future<void> _handleSignIn(
    BuildContext context,
    GoogleSignInProvider provider,
  ) async {
    final success = await provider.signInWithGoogle();

    if (success) {
      // Cập nhật AuthModel để GoRouter có thể redirect
      if (context.mounted) {
        final authModel = Provider.of<AuthModel>(context, listen: false);
        authModel.updateFromGoogleAuth(
          true,
          provider.email,
          provider.displayName,
        );
      }

      onSignInSuccess?.call();
    } else {
      onSignInError?.call();
      if (context.mounted && provider.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage!),
            backgroundColor: context.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

