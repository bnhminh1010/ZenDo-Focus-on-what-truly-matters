/*
 * Tên: widgets/pyramid_timer_widget.dart
 * Tác dụng: Vẽ và hiển thị kim tự tháp 4 tầng thể hiện tiến trình timer với animation mượt.
 * Khi nào dùng: Trong Pomodoro Timer và các nơi cần hiển thị tiến trình dạng kim tự tháp.
 */
import 'package:flutter/material.dart';

/*
 * Widget: PyramidTimerWidget
 * Tác dụng: Trình bày tiến trình timer dưới dạng kim tự tháp 4 tầng với hiệu ứng mượt.
 * Khi nào dùng: Kết hợp trong PomodoroTimerWidget hoặc nơi cần visual hóa tiến trình theo tầng.
 */
class PyramidTimerWidget extends StatefulWidget {
  /// Tiến độ hiện tại (0.0 – 1.0).
  final double progress; // 0.0 - 1.0
  /// Màu sắc của phần đã hoàn thành.
  final Color activeColor;
  /// Màu sắc nền chưa hoàn thành.
  final Color inactiveColor;
  /// Kích thước tổng thể của widget (chiều rộng/chiều cao).
  final double size;
  /// Chuỗi thời gian hiển thị ở trung tâm.
  final String timeText;
  /// Dòng mô tả phụ hiển thị dưới thời gian.
  final String subText;
  /// Callback khi người dùng chạm vào vùng thời gian.
  final VoidCallback? onTimeTap;

  const PyramidTimerWidget({
    super.key,
    required this.progress,
    required this.activeColor,
    required this.inactiveColor,
    required this.size,
    required this.timeText,
    required this.subText,
    this.onTimeTap,
  });

  @override
  State<PyramidTimerWidget> createState() => _PyramidTimerWidgetState();
}

class _PyramidTimerWidgetState extends State<PyramidTimerWidget>
    with SingleTickerProviderStateMixin {
  /// Controller điều khiển animation tiến độ.
  late AnimationController _animationController;
  /// Animation nội suy giá trị progress mềm mại.
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(PyramidTimerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.progress != oldWidget.progress) {
      _animationController.animateTo(widget.progress);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Pyramid Timer
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return CustomPaint(
                size: Size(widget.size, widget.size * 0.8),
                painter: PyramidPainter(
                  progress: _animation.value,
                  activeColor: widget.activeColor,
                  inactiveColor: widget.inactiveColor,
                ),
              );
            },
          ),
          // Time and Sub Text
          Positioned(
            child: GestureDetector(
              onTap: widget.onTimeTap,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.timeText,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          offset: Offset(1, 1),
                          blurRadius: 3,
                          color: Colors.black26,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.subText,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                      shadows: [
                        Shadow(
                          offset: Offset(1, 1),
                          blurRadius: 2,
                          color: Colors.black26,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter để vẽ kim tự tháp 4 tầng với hiệu ứng đổ nước
class PyramidPainter extends CustomPainter {
  final double progress; // 0.0 - 1.0
  final Color activeColor;
  final Color inactiveColor;

  PyramidPainter({
    required this.progress,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Shadow paint cho hiệu ứng đổ bóng
    final shadowPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.black.withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    // Tính toán kích thước các tầng
    final centerX = size.width / 2;
    final startY = size.height * 0.1;
    final pyramidWidth = size.width * 0.8;
    final levelHeight = (size.height * 0.8) / 4;

    // Vẽ shadow cho toàn bộ kim tự tháp
    final pyramidShadowPath = Path();
    pyramidShadowPath.moveTo(centerX + 2, startY + 2);
    pyramidShadowPath.lineTo(
      centerX - pyramidWidth / 2 + 2,
      startY + levelHeight * 4 + 2,
    );
    pyramidShadowPath.lineTo(
      centerX + pyramidWidth / 2 + 2,
      startY + levelHeight * 4 + 2,
    );
    pyramidShadowPath.close();
    canvas.drawPath(pyramidShadowPath, shadowPaint);

    // Vẽ background inactive cho toàn bộ kim tự tháp
    final pyramidPath = Path();
    pyramidPath.moveTo(centerX, startY);
    pyramidPath.lineTo(centerX - pyramidWidth / 2, startY + levelHeight * 4);
    pyramidPath.lineTo(centerX + pyramidWidth / 2, startY + levelHeight * 4);
    pyramidPath.close();

    paint.color = inactiveColor;
    canvas.drawPath(pyramidPath, paint);

    // Tạo clipping path cho toàn bộ kim tự tháp
    canvas.save();
    canvas.clipPath(pyramidPath);

    // Vẽ 4 tầng kim tự tháp từ dưới lên (chỉ phần active, không có viền)
    for (int level = 3; level >= 0; level--) {
      final levelWidth = pyramidWidth * (level + 1) / 4;
      final levelY = startY + level * levelHeight;

      // Tính toán progress cho từng tầng - ĐỔ TỪ TRÊN XUỐNG
      // Giống như đổ nước: nước chảy xuống, đầy từ dưới lên trên
      // Tầng 3 (đáy): 0.00 - 0.25 (đầy đầu tiên)
      // Tầng 2: 0.25 - 0.50 (đầy tiếp theo)
      // Tầng 1: 0.50 - 0.75 (đầy tiếp theo)
      // Tầng 0 (đỉnh): 0.75 - 1.00 (đầy cuối cùng)
      double levelProgress;
      final levelStart = (3 - level) * 0.25;
      final levelEnd = (4 - level) * 0.25;

      if (progress < levelStart) {
        levelProgress = 0.0;
      } else if (progress >= levelEnd) {
        levelProgress = 1.0;
      } else {
        levelProgress = (progress - levelStart) / 0.25;
        levelProgress = levelProgress.clamp(0.0, 1.0);
      }

      final isActive = levelProgress > 0;

      // Vẽ phần active với hiệu ứng fill từ DƯỚI LÊN TRÊN
      if (isActive) {
        final fillHeight = levelHeight * levelProgress;
        final fillPath = Path();

        if (level == 0) {
          // Tầng tam giác - fill từ đáy lên đỉnh
          final fillTopY = levelY + levelHeight - fillHeight;
          final fillWidth = levelWidth * levelProgress;

          fillPath.lineTo(
            centerX - levelWidth / 2,
            levelY + levelHeight,
          ); // Đáy trái
          fillPath.lineTo(
            centerX + levelWidth / 2,
            levelY + levelHeight,
          ); // Đáy phải
          fillPath.lineTo(centerX + fillWidth / 2, fillTopY); // Lên phải
          fillPath.lineTo(centerX - fillWidth / 2, fillTopY); // Lên trái
          fillPath.close();
        } else {
          // Tầng hình thang - fill từ đáy lên
          final prevLevelWidth = pyramidWidth * level / 4;
          final fillTopY = levelY + levelHeight - fillHeight;

          // Tính chiều rộng tại vị trí fill (càng lên càng hẹp)
          final widthShrink =
              (levelWidth - prevLevelWidth) * (1 - levelProgress);
          final fillTopWidth = prevLevelWidth + widthShrink;

          fillPath.moveTo(
            centerX - levelWidth / 2,
            levelY + levelHeight,
          ); // Đáy trái
          fillPath.lineTo(
            centerX + levelWidth / 2,
            levelY + levelHeight,
          ); // Đáy phải
          fillPath.lineTo(centerX + fillTopWidth / 2, fillTopY); // Lên phải
          fillPath.lineTo(centerX - fillTopWidth / 2, fillTopY); // Lên trái
          fillPath.close();
        }

        // Gradient màu cho phần active
        final gradient = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            activeColor.withOpacity(0.9),
            activeColor.withOpacity(0.7),
            activeColor,
          ],
          stops: const [0.0, 0.5, 1.0],
        );

        paint.shader = gradient.createShader(fillPath.getBounds());
        canvas.drawPath(fillPath, paint);
      }
    }

    canvas.restore();

    // Vẽ viền ngoài cho toàn bộ kim tự tháp
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.white.withOpacity(0.8);

    paint.shader = null;
    canvas.drawPath(pyramidPath, strokePaint);
  }

  @override
  bool shouldRepaint(covariant PyramidPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.inactiveColor != inactiveColor;
  }
}
