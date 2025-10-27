/*
 * Tên: widgets/haptic_feedback_widget.dart
 * Tác dụng: Cung cấp haptic feedback cho các tương tác (nút, icon, FAB), kèm các tiện ích HapticButton/HapticIconButton.
 * Khi nào dùng: Khi muốn thêm phản hồi xúc giác cho thao tác nhấn, lựa chọn, thành công/thất bại trong UI.
 */
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Widget cung cấp haptic feedback cho các interactions
class HapticFeedbackWidget {
  /// Light haptic feedback cho các tương tác nhẹ
  static void light() {
    HapticFeedback.lightImpact();
  }

  /// Medium haptic feedback cho các tương tác trung bình
  static void medium() {
    HapticFeedback.mediumImpact();
  }

  /// Heavy haptic feedback cho các tương tác mạnh
  static void heavy() {
    HapticFeedback.heavyImpact();
  }

  /// Selection feedback cho việc chọn lựa
  static void selection() {
    HapticFeedback.selectionClick();
  }

  /// Vibration pattern cho success
  static void success() {
    HapticFeedback.lightImpact();
    Future.delayed(const Duration(milliseconds: 100), () {
      HapticFeedback.lightImpact();
    });
  }

  /// Vibration pattern cho error
  static void error() {
    HapticFeedback.heavyImpact();
    Future.delayed(const Duration(milliseconds: 100), () {
      HapticFeedback.heavyImpact();
    });
    Future.delayed(const Duration(milliseconds: 200), () {
      HapticFeedback.heavyImpact();
    });
  }
}

/// Button với haptic feedback tích hợp
class HapticButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final HapticFeedbackType feedbackType;
  final ButtonStyle? style;

  const HapticButton({
    super.key,
    required this.child,
    this.onPressed,
    this.feedbackType = HapticFeedbackType.light,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: style,
      onPressed: onPressed == null
          ? null
          : () {
              _triggerHapticFeedback();
              onPressed!();
            },
      child: child,
    );
  }

  void _triggerHapticFeedback() {
    switch (feedbackType) {
      case HapticFeedbackType.light:
        HapticFeedbackWidget.light();
        break;
      case HapticFeedbackType.medium:
        HapticFeedbackWidget.medium();
        break;
      case HapticFeedbackType.heavy:
        HapticFeedbackWidget.heavy();
        break;
      case HapticFeedbackType.selection:
        HapticFeedbackWidget.selection();
        break;
      case HapticFeedbackType.success:
        HapticFeedbackWidget.success();
        break;
      case HapticFeedbackType.error:
        HapticFeedbackWidget.error();
        break;
    }
  }
}

/// IconButton với haptic feedback
class HapticIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final HapticFeedbackType feedbackType;
  final Color? color;
  final double? size;

  const HapticIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.feedbackType = HapticFeedbackType.light,
    this.color,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, color: color, size: size),
      onPressed: onPressed == null
          ? null
          : () {
              _triggerHapticFeedback();
              onPressed!();
            },
    );
  }

  void _triggerHapticFeedback() {
    switch (feedbackType) {
      case HapticFeedbackType.light:
        HapticFeedbackWidget.light();
        break;
      case HapticFeedbackType.medium:
        HapticFeedbackWidget.medium();
        break;
      case HapticFeedbackType.heavy:
        HapticFeedbackWidget.heavy();
        break;
      case HapticFeedbackType.selection:
        HapticFeedbackWidget.selection();
        break;
      case HapticFeedbackType.success:
        HapticFeedbackWidget.success();
        break;
      case HapticFeedbackType.error:
        HapticFeedbackWidget.error();
        break;
    }
  }
}

/// FloatingActionButton với haptic feedback
class HapticFloatingActionButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final HapticFeedbackType feedbackType;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const HapticFloatingActionButton({
    super.key,
    required this.child,
    this.onPressed,
    this.feedbackType = HapticFeedbackType.medium,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      onPressed: onPressed == null
          ? null
          : () {
              _triggerHapticFeedback();
              onPressed!();
            },
      child: child,
    );
  }

  void _triggerHapticFeedback() {
    switch (feedbackType) {
      case HapticFeedbackType.light:
        HapticFeedbackWidget.light();
        break;
      case HapticFeedbackType.medium:
        HapticFeedbackWidget.medium();
        break;
      case HapticFeedbackType.heavy:
        HapticFeedbackWidget.heavy();
        break;
      case HapticFeedbackType.selection:
        HapticFeedbackWidget.selection();
        break;
      case HapticFeedbackType.success:
        HapticFeedbackWidget.success();
        break;
      case HapticFeedbackType.error:
        HapticFeedbackWidget.error();
        break;
    }
  }
}

/// Enum định nghĩa các loại haptic feedback
enum HapticFeedbackType { light, medium, heavy, selection, success, error }

/// Mixin để thêm haptic feedback vào các widget
mixin HapticFeedbackMixin {
  void triggerHapticFeedback(HapticFeedbackType type) {
    switch (type) {
      case HapticFeedbackType.light:
        HapticFeedbackWidget.light();
        break;
      case HapticFeedbackType.medium:
        HapticFeedbackWidget.medium();
        break;
      case HapticFeedbackType.heavy:
        HapticFeedbackWidget.heavy();
        break;
      case HapticFeedbackType.selection:
        HapticFeedbackWidget.selection();
        break;
      case HapticFeedbackType.success:
        HapticFeedbackWidget.success();
        break;
      case HapticFeedbackType.error:
        HapticFeedbackWidget.error();
        break;
    }
  }
}

