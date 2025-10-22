import 'package:flutter/material.dart';
import '../widgets/glass_container.dart';

/// Enhanced loading widget với progress indicators và animations
class EnhancedLoadingWidget extends StatefulWidget {
  final String? message;
  final double? progress; // 0.0 - 1.0 cho progress bar
  final bool showProgress;
  final bool useGlassEffect;
  final IconData? icon;
  final Color? color;
  final Duration animationDuration;

  const EnhancedLoadingWidget({
    super.key,
    this.message,
    this.progress,
    this.showProgress = false,
    this.useGlassEffect = true,
    this.icon,
    this.color,
    this.animationDuration = const Duration(milliseconds: 1500),
  });

  @override
  State<EnhancedLoadingWidget> createState() => _EnhancedLoadingWidgetState();
}

class _EnhancedLoadingWidgetState extends State<EnhancedLoadingWidget>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Rotation animation cho loading icon
    _rotationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _rotationAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );

    // Pulse animation cho loading effect
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _rotationController.repeat();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loadingColor = widget.color ?? theme.colorScheme.primary;

    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Loading icon với animation
        AnimatedBuilder(
          animation: _rotationAnimation,
          builder: (context, child) {
            return Transform.rotate(
              angle: _rotationAnimation.value * 2 * 3.14159,
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Icon(
                      widget.icon ?? Icons.refresh,
                      size: 32,
                      color: loadingColor,
                    ),
                  );
                },
              ),
            );
          },
        ),

        if (widget.showProgress && widget.progress != null) ...[
          const SizedBox(height: 16),
          // Progress bar
          SizedBox(
            width: 200,
            child: Column(
              children: [
                LinearProgressIndicator(
                  value: widget.progress,
                  backgroundColor: loadingColor.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(loadingColor),
                ),
                const SizedBox(height: 8),
                Text(
                  '${(widget.progress! * 100).toInt()}%',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: loadingColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],

        if (widget.message != null) ...[
          const SizedBox(height: 16),
          Text(
            widget.message!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );

    if (widget.useGlassEffect) {
      return Center(
        child: GlassContainer(
          padding: const EdgeInsets.all(24),
          child: content,
        ),
      );
    }

    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: content,
      ),
    );
  }
}

/// Loading overlay để hiển thị trên toàn màn hình
class LoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? message;
  final double? progress;
  final bool showProgress;

  const LoadingOverlay({
    super.key,
    required this.child,
    required this.isLoading,
    this.message,
    this.progress,
    this.showProgress = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: EnhancedLoadingWidget(
              message: message,
              progress: progress,
              showProgress: showProgress,
              useGlassEffect: true,
            ),
          ),
      ],
    );
  }
}

/// Button loading state
class LoadingButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final bool isLoading;
  final String? loadingText;
  final ButtonStyle? style;

  const LoadingButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.isLoading = false,
    this.loadingText,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: style,
      child: isLoading
          ? Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                if (loadingText != null) ...[
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      loadingText!,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ],
            )
          : child,
    );
  }
}

