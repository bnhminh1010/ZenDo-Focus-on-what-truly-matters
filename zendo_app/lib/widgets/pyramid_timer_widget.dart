import 'package:flutter/material.dart';

/// Widget kim tự tháp 4 tầng để hiển thị tiến trình timer với animation smooth
class PyramidTimerWidget extends StatefulWidget {
  final double progress; // 0.0 - 1.0
  final Color activeColor;
  final Color inactiveColor;
  final double size;
  final String timeText;
  final String subText;
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
  late AnimationController _animationController;
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

/// Custom painter để vẽ kim tự tháp 4 tầng với hiệu ứng cát rơi
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

    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.white.withOpacity(0.8);

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

    // Tạo clipping path cho toàn bộ kim tự tháp để đảm bảo hiệu ứng không tràn ra ngoài
    final clipPath = Path();
    clipPath.moveTo(centerX, startY); // Đỉnh kim tự tháp
    clipPath.lineTo(
      centerX - pyramidWidth / 2,
      startY + levelHeight * 4,
    ); // Góc trái dưới
    clipPath.lineTo(
      centerX + pyramidWidth / 2,
      startY + levelHeight * 4,
    ); // Góc phải dưới
    clipPath.close();

    // Áp dụng clipping
    canvas.clipPath(clipPath);

    // Vẽ 4 tầng kim tự tháp từ dưới lên
    for (int level = 3; level >= 0; level--) {
      final levelWidth = pyramidWidth * (level + 1) / 4;
      final levelY = startY + level * levelHeight;

      // Tính toán progress cho từng tầng
      final levelProgress = ((progress * 4) - (3 - level)).clamp(0.0, 1.0);
      final isActive = levelProgress > 0;

      // Vẽ đổ bóng trước
      final shadowPath = Path();
      if (level == 0) {
        // Tầng đầu tiên - tam giác
        shadowPath.moveTo(centerX + 2, levelY + 2);
        shadowPath.lineTo(
          centerX - levelWidth / 2 + 2,
          levelY + levelHeight + 2,
        );
        shadowPath.lineTo(
          centerX + levelWidth / 2 + 2,
          levelY + levelHeight + 2,
        );
        shadowPath.close();
      } else {
        // Các tầng khác - hình thang
        final prevLevelWidth = pyramidWidth * level / 4;
        shadowPath.moveTo(centerX - prevLevelWidth / 2 + 2, levelY + 2);
        shadowPath.lineTo(centerX + prevLevelWidth / 2 + 2, levelY + 2);
        shadowPath.lineTo(
          centerX + levelWidth / 2 + 2,
          levelY + levelHeight + 2,
        );
        shadowPath.lineTo(
          centerX - levelWidth / 2 + 2,
          levelY + levelHeight + 2,
        );
        shadowPath.close();
      }
      canvas.drawPath(shadowPath, shadowPaint);

      // Vẽ tầng kim tự tháp
      final path = Path();
      if (level == 0) {
        // Tầng đầu tiên - tam giác
        path.moveTo(centerX, levelY);
        path.lineTo(centerX - levelWidth / 2, levelY + levelHeight);
        path.lineTo(centerX + levelWidth / 2, levelY + levelHeight);
        path.close();
      } else {
        // Các tầng khác - hình thang
        final prevLevelWidth = pyramidWidth * level / 4;
        path.moveTo(centerX - prevLevelWidth / 2, levelY);
        path.lineTo(centerX + prevLevelWidth / 2, levelY);
        path.lineTo(centerX + levelWidth / 2, levelY + levelHeight);
        path.lineTo(centerX - levelWidth / 2, levelY + levelHeight);
        path.close();
      }

      // Chọn màu dựa trên trạng thái active và progress với hiệu ứng slight in
      if (isActive) {
        // Tạo hiệu ứng "slight in" - màu từ từ xuất hiện từ trên xuống
        final fillHeight = levelHeight * levelProgress;
        final fillPath = Path();

        if (level == 0) {
          // Tầng đầu tiên - tam giác với hiệu ứng fill từ trên xuống
          final fillY = levelY + (levelHeight - fillHeight);
          final fillWidthRatio = fillHeight / levelHeight;
          final fillWidth = levelWidth * fillWidthRatio;

          fillPath.moveTo(centerX, levelY);
          fillPath.lineTo(centerX - fillWidth / 2, fillY);
          fillPath.lineTo(centerX + fillWidth / 2, fillY);
          fillPath.close();
        } else {
          // Các tầng khác - hình thang với hiệu ứng fill từ trên xuống
          final prevLevelWidth = pyramidWidth * level / 4;
          final fillY = levelY + (levelHeight - fillHeight);
          final fillWidthRatio = fillHeight / levelHeight;
          final topFillWidth =
              prevLevelWidth +
              (levelWidth - prevLevelWidth) * (1 - fillWidthRatio);
          final bottomFillWidth = levelWidth;

          fillPath.moveTo(centerX - topFillWidth / 2, fillY);
          fillPath.lineTo(centerX + topFillWidth / 2, fillY);
          fillPath.lineTo(centerX + bottomFillWidth / 2, levelY + levelHeight);
          fillPath.lineTo(centerX - bottomFillWidth / 2, levelY + levelHeight);
          fillPath.close();
        }

        // Gradient màu đẹp hơn với hiệu ứng slight in
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

        // Vẽ phần inactive trước
        paint.shader = null;
        paint.color = inactiveColor;
        canvas.drawPath(path, paint);

        // Vẽ phần active với gradient
        paint.shader = gradient.createShader(fillPath.getBounds());
        canvas.drawPath(fillPath, paint);
      } else {
        paint.shader = null;
        paint.color = inactiveColor;
        canvas.drawPath(path, paint);
      }

      // Vẽ viền
      canvas.drawPath(path, strokePaint);
    }
  }

  @override
  bool shouldRepaint(covariant PyramidPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.inactiveColor != inactiveColor;
  }
}

