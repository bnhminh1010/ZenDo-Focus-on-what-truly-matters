import 'package:flutter/material.dart';
import 'glass_container.dart';

/// Liquid Glass Button Widget
/// Tạo nút với hiệu ứng liquid glass đẹp mắt
class GlassButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final double borderRadius;
  final double blur;
  final double opacity;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final Gradient? gradient;
  final Border? border;
  final double? width;
  final double? height;
  final bool pill;
  final bool highlightEdge;
  final bool innerShadow;
  final List<BoxShadow>? boxShadow;

  const GlassButton({
    super.key,
    required this.child,
    this.onPressed,
    this.onLongPress,
    this.borderRadius = 12,
    this.blur = 16,
    this.opacity = 0.14,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.margin,
    this.color,
    this.gradient,
    this.border,
    this.width,
    this.height,
    this.pill = false,
    this.highlightEdge = true,
    this.innerShadow = false,
    this.boxShadow,
  });

  @override
  State<GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<GlassButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null) {
      _animationController.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onPressed != null) {
      _animationController.reverse();
    }
  }

  void _onTapCancel() {
    if (widget.onPressed != null) {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: GestureDetector(
              onTapDown: _onTapDown,
              onTapUp: _onTapUp,
              onTapCancel: _onTapCancel,
              onTap: widget.onPressed,
              onLongPress: widget.onLongPress,
              child: GlassContainer(
                borderRadius: widget.borderRadius,
                blur: widget.blur,
                opacity: widget.opacity,
                padding: widget.padding,
                margin: widget.margin,
                color: widget.color ?? Colors.white,
                gradient: widget.gradient,
                border: widget.border,
                width: widget.width,
                height: widget.height,
                pill: widget.pill,
                highlightEdge: widget.highlightEdge,
                innerShadow: widget.innerShadow,
                boxShadow:
                    widget.boxShadow ??
                    [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                child: widget.child,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Glass Icon Button - Nút icon với hiệu ứng liquid glass
class GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final Color? iconColor;
  final double borderRadius;
  final double blur;
  final double opacity;
  final EdgeInsetsGeometry padding;
  final String? tooltip;

  const GlassIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = 24,
    this.iconColor,
    this.borderRadius = 12,
    this.blur = 16,
    this.opacity = 0.14,
    this.padding = const EdgeInsets.all(12),
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final button = GlassButton(
      onPressed: onPressed,
      borderRadius: borderRadius,
      blur: blur,
      opacity: opacity,
      padding: padding,
      child: Icon(
        icon,
        size: size,
        color: iconColor ?? Theme.of(context).colorScheme.onSurface,
      ),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: button);
    }

    return button;
  }
}

/// Glass Elevated Button - Nút elevated với hiệu ứng liquid glass
class GlassElevatedButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double borderRadius;
  final double blur;
  final double opacity;
  final EdgeInsetsGeometry padding;

  const GlassElevatedButton({
    super.key,
    required this.child,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius = 12,
    this.blur = 16,
    this.opacity = 0.14,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
  });

  /// Named constructor for icon button
  GlassElevatedButton.icon({
    super.key,
    required Widget icon,
    required Widget label,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius = 12,
    this.blur = 16,
    this.opacity = 0.14,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  }) : child = Row(
         mainAxisSize: MainAxisSize.min,
         children: [icon, const SizedBox(width: 8), label],
       );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveBackgroundColor =
        backgroundColor ?? theme.colorScheme.primary;
    final effectiveForegroundColor =
        foregroundColor ?? theme.colorScheme.onPrimary;

    return GlassButton(
      onPressed: onPressed,
      borderRadius: borderRadius,
      blur: blur,
      opacity: opacity,
      padding: padding,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          effectiveBackgroundColor.withOpacity(0.8),
          effectiveBackgroundColor.withOpacity(0.6),
        ],
      ),
      child: DefaultTextStyle(
        style: TextStyle(
          color: effectiveForegroundColor,
          fontWeight: FontWeight.w500,
        ),
        child: child,
      ),
    );
  }
}

/// Glass Text Button - Nút text với hiệu ứng liquid glass
class GlassTextButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color? textColor;
  final double borderRadius;
  final double blur;
  final double opacity;
  final EdgeInsetsGeometry padding;

  const GlassTextButton({
    super.key,
    required this.child,
    this.onPressed,
    this.textColor,
    this.borderRadius = 8,
    this.blur = 12,
    this.opacity = 0.08,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveTextColor = textColor ?? theme.colorScheme.primary;

    return GlassButton(
      onPressed: onPressed,
      borderRadius: borderRadius,
      blur: blur,
      opacity: opacity,
      padding: padding,
      child: DefaultTextStyle(
        style: TextStyle(
          color: effectiveTextColor,
          fontWeight: FontWeight.w500,
        ),
        child: child,
      ),
    );
  }
}

/// Glass Outlined Button - Nút outlined với hiệu ứng liquid glass
class GlassOutlinedButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color? borderColor;
  final Color? textColor;
  final double borderRadius;
  final double blur;
  final double opacity;
  final EdgeInsetsGeometry padding;

  const GlassOutlinedButton({
    super.key,
    required this.child,
    this.onPressed,
    this.borderColor,
    this.textColor,
    this.borderRadius = 12,
    this.blur = 16,
    this.opacity = 0.08,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveBorderColor = borderColor ?? theme.colorScheme.primary;
    final effectiveTextColor = textColor ?? theme.colorScheme.primary;

    return GlassButton(
      onPressed: onPressed,
      borderRadius: borderRadius,
      blur: blur,
      opacity: opacity,
      padding: padding,
      border: Border.all(
        color: effectiveBorderColor.withOpacity(0.6),
        width: 1.5,
      ),
      child: DefaultTextStyle(
        style: TextStyle(
          color: effectiveTextColor,
          fontWeight: FontWeight.w500,
        ),
        child: child,
      ),
    );
  }
}

/// Glass Floating Action Button - FAB với hiệu ứng liquid glass
class GlassFloatingActionButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double size;
  final double blur;
  final double opacity;

  const GlassFloatingActionButton({
    super.key,
    required this.child,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.size = 56,
    this.blur = 20,
    this.opacity = 0.16,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveBackgroundColor =
        backgroundColor ?? theme.colorScheme.primary;
    final effectiveForegroundColor =
        foregroundColor ?? theme.colorScheme.onPrimary;

    return GlassButton(
      onPressed: onPressed,
      borderRadius: size / 2,
      blur: blur,
      opacity: opacity,
      padding: EdgeInsets.zero,
      width: size,
      height: size,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          effectiveBackgroundColor.withOpacity(0.9),
          effectiveBackgroundColor.withOpacity(0.7),
        ],
      ),
      boxShadow: [
        BoxShadow(
          color: effectiveBackgroundColor.withOpacity(0.3),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ],
      child: DefaultTextStyle(
        style: TextStyle(color: effectiveForegroundColor),
        child: child,
      ),
    );
  }
}

