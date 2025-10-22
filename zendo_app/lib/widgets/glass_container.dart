import 'dart:ui';
import 'package:flutter/material.dart';

/// GlassContainer Class
/// Tác dụng: Container với hiệu ứng kính mờ (glass morphism) có thể tái sử dụng
/// Sử dụng khi: Cần tạo UI element với hiệu ứng glass morphism hiện đại
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blur;
  final double opacity;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final List<BoxShadow>? boxShadow;
  final Gradient? gradient;
  final Color color;
  final Border? border;
  final double? width;
  final double? height;
  // iOS-style Liquid Glass refinements
  final bool pill; // stadium shape
  final bool highlightEdge; // subtle top highlight edge
  final bool innerShadow; // gentle inner shadow for depth

  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius = 16,
    this.blur = 12,
    this.opacity = 0.18,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.boxShadow,
    this.gradient,
    this.color = Colors.white,
    this.border,
    this.width,
    this.height,
    this.pill = false,
    this.highlightEdge = true,
    this.innerShadow = false,
  });

  @override
  Widget build(BuildContext context) {
    final defaultShadow =
        boxShadow ??
        [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ];

    final defaultBorder =
        border ??
        Border.all(color: Colors.white.withOpacity(0.3), width: 1);

    final defaultGradient =
        gradient ??
        LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(opacity + 0.05),
            Colors.white.withOpacity(opacity - 0.04),
          ],
        );

    final effectiveRadius = pill ? 40.0 : borderRadius;

    return Container(
      margin: margin,
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(effectiveRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Stack(
            children: [
              // Base glass surface
              Container(
                padding: padding,
                decoration: BoxDecoration(
                  gradient: defaultGradient,
                  color: color.withOpacity(opacity),
                  border: defaultBorder,
                  boxShadow: defaultShadow,
                  borderRadius: BorderRadius.circular(effectiveRadius),
                ),
                child: child,
              ),

              // Top highlight edge (subtle white gradient)
              if (highlightEdge)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: IgnorePointer(
                    ignoring: true,
                    child: Container(
                      height: 2,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(effectiveRadius),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withOpacity(0.35),
                            Colors.white.withOpacity(0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              // Inner shadow (approximation using edge gradients)
              if (innerShadow) ...[
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: IgnorePointer(
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(effectiveRadius),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.06),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: IgnorePointer(
                    child: Container(
                      height: 10,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(effectiveRadius),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.08),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

