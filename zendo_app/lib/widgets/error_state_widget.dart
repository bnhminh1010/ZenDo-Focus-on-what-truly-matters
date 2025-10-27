/*
 * Tên: widgets/error_state_widget.dart
 * Tác dụng: Bộ widget hiển thị trạng thái lỗi/empty, có các factory cho network/server/not-found/permission.
 * Khi nào dùng: Khi cần thông báo lỗi hoặc trạng thái trống với hành động Retry/Quay lại và hiệu ứng glass tuỳ chọn.
 */
import 'package:flutter/material.dart';
import 'glass_container.dart';

/// Widget chuẩn cho error states trong app
class ErrorStateWidget extends StatelessWidget {
  final String? title;
  final String? message;
  final IconData? icon;
  final VoidCallback? onRetry;
  final String? retryButtonText;
  final bool useGlassEffect;
  final Widget? customAction;

  const ErrorStateWidget({
    super.key,
    this.title,
    this.message,
    this.icon,
    this.onRetry,
    this.retryButtonText,
    this.useGlassEffect = false,
    this.customAction,
  });

  /// Error widget cho network issues
  factory ErrorStateWidget.network({
    VoidCallback? onRetry,
    String? retryButtonText,
    bool useGlassEffect = false,
  }) {
    return ErrorStateWidget(
      title: 'Lỗi kết nối',
      message:
          'Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng và thử lại.',
      icon: Icons.wifi_off_outlined,
      onRetry: onRetry,
      retryButtonText: retryButtonText ?? 'Thử lại',
      useGlassEffect: useGlassEffect,
    );
  }

  /// Error widget cho server errors
  factory ErrorStateWidget.server({
    VoidCallback? onRetry,
    String? retryButtonText,
    bool useGlassEffect = false,
  }) {
    return ErrorStateWidget(
      title: 'Lỗi máy chủ',
      message: 'Đã xảy ra lỗi từ phía máy chủ. Vui lòng thử lại sau.',
      icon: Icons.error_outline,
      onRetry: onRetry,
      retryButtonText: retryButtonText ?? 'Thử lại',
      useGlassEffect: useGlassEffect,
    );
  }

  /// Error widget cho not found
  factory ErrorStateWidget.notFound({
    String? title,
    String? message,
    VoidCallback? onRetry,
    String? retryButtonText,
    bool useGlassEffect = false,
  }) {
    return ErrorStateWidget(
      title: title ?? 'Không tìm thấy',
      message: message ?? 'Nội dung bạn tìm kiếm không tồn tại hoặc đã bị xóa.',
      icon: Icons.search_off_outlined,
      onRetry: onRetry,
      retryButtonText: retryButtonText ?? 'Quay lại',
      useGlassEffect: useGlassEffect,
    );
  }

  /// Error widget cho permission denied
  factory ErrorStateWidget.permission({
    String? title,
    String? message,
    VoidCallback? onRetry,
    String? retryButtonText,
    bool useGlassEffect = false,
  }) {
    return ErrorStateWidget(
      title: title ?? 'Không có quyền truy cập',
      message: message ?? 'Bạn không có quyền truy cập vào nội dung này.',
      icon: Icons.lock_outline,
      onRetry: onRetry,
      retryButtonText: retryButtonText ?? 'Đăng nhập',
      useGlassEffect: useGlassEffect,
    );
  }

  /// Error widget cho empty state
  factory ErrorStateWidget.empty({
    String? title,
    String? message,
    IconData? icon,
    VoidCallback? onRetry,
    String? retryButtonText,
    bool useGlassEffect = false,
    Widget? customAction,
  }) {
    return ErrorStateWidget(
      title: title ?? 'Trống',
      message: message ?? 'Chưa có dữ liệu nào.',
      icon: icon ?? Icons.inbox_outlined,
      onRetry: onRetry,
      retryButtonText: retryButtonText ?? 'Tải lại',
      useGlassEffect: useGlassEffect,
      customAction: customAction,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Icon
        Semantics(
          label: 'Biểu tượng lỗi',
          child: Icon(
            icon ?? Icons.error_outline,
            size: 64,
            color: theme.colorScheme.error.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 24),

        // Title
        if (title != null)
          Text(
            title!,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),

        if (title != null && message != null) const SizedBox(height: 12),

        // Message
        if (message != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              message!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ),

        const SizedBox(height: 32),

        // Actions
        if (customAction != null)
          customAction!
        else if (onRetry != null)
          Semantics(
            label: 'Nút thử lại',
            hint: 'Nhấn để thử lại',
            child: FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(retryButtonText ?? 'Thử lại'),
            ),
          ),
      ],
    );

    if (useGlassEffect) {
      return Center(
        child: GlassContainer(
          child: Padding(padding: const EdgeInsets.all(32), child: content),
        ),
      );
    }

    return Center(
      child: Padding(padding: const EdgeInsets.all(24), child: content),
    );
  }
}

/// Widget cho inline error messages
class InlineErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final String? retryText;
  final IconData? icon;

  const InlineErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.retryText,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withOpacity(0.1),
        border: Border.all(color: theme.colorScheme.error.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon ?? Icons.error_outline,
            color: theme.colorScheme.error,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: 12),
            TextButton(
              onPressed: onRetry,
              child: Text(
                retryText ?? 'Thử lại',
                style: TextStyle(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Widget cho form field errors
class FormErrorWidget extends StatelessWidget {
  final String message;
  final EdgeInsets? padding;

  const FormErrorWidget({super.key, required this.message, this.padding});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: padding ?? const EdgeInsets.only(top: 8, left: 16, right: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, color: theme.colorScheme.error, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Mixin để xử lý error states
mixin ErrorHandlerMixin {
  /// Xử lý và hiển thị error message phù hợp
  String getErrorMessage(dynamic error) {
    if (error == null) return 'Đã xảy ra lỗi không xác định';

    final errorString = error.toString().toLowerCase();

    if (errorString.contains('network') ||
        errorString.contains('connection') ||
        errorString.contains('timeout')) {
      return 'Lỗi kết nối mạng. Vui lòng kiểm tra kết nối và thử lại.';
    }

    if (errorString.contains('server') ||
        errorString.contains('500') ||
        errorString.contains('502') ||
        errorString.contains('503')) {
      return 'Lỗi máy chủ. Vui lòng thử lại sau.';
    }

    if (errorString.contains('unauthorized') || errorString.contains('401')) {
      return 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.';
    }

    if (errorString.contains('forbidden') || errorString.contains('403')) {
      return 'Bạn không có quyền truy cập vào nội dung này.';
    }

    if (errorString.contains('not found') || errorString.contains('404')) {
      return 'Không tìm thấy nội dung yêu cầu.';
    }

    return 'Đã xảy ra lỗi: ${error.toString()}';
  }

  /// Hiển thị error snackbar
  void showErrorSnackBar(BuildContext context, dynamic error) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(getErrorMessage(error)),
        backgroundColor: Theme.of(context).colorScheme.error,
        action: SnackBarAction(
          label: 'Đóng',
          textColor: Theme.of(context).colorScheme.onError,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}
