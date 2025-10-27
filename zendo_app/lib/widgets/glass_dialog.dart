/*
 * Tên: widgets/glass_dialog.dart
 * Tác dụng: Dialog phong cách glassmorphism với BackdropFilter, nền mờ và viền nổi.
 * Khi nào dùng: Dùng cho các hộp thoại xác nhận/thông báo cần hiệu ứng kính sang trọng.
 */
import 'dart:ui';
import 'package:flutter/material.dart';

/// Glass-styled dialog using BackdropFilter and translucent background
class GlassDialog extends StatelessWidget {
  final Widget title;
  final Widget? content;
  final List<Widget>? actions;
  final double borderRadius;
  final double blur;
  final double opacity;

  const GlassDialog({
    super.key,
    required this.title,
    this.content,
    this.actions,
    this.borderRadius = 20,
    this.blur = 14,
    this.opacity = 0.22,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(opacity),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(color: Colors.white.withOpacity(0.35)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 16,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DefaultTextStyle(
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium!.copyWith(color: Colors.white),
                    child: title,
                  ),
                  if (content != null) ...[
                    const SizedBox(height: 12),
                    DefaultTextStyle(
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                      child: content!,
                    ),
                  ],
                  if (actions != null && actions!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: actions!,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
