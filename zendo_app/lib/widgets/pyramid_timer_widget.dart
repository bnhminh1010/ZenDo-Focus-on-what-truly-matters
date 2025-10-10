import 'package:flutter/material.dart';

/// Widget kim tự tháp 4 tầng để hiển thị tiến trình timer với animation smooth
class PyramidTimerWidget extends StatefulWidget {
  final double progress; // 0.0 - 1.0
  final Color activeColor;
  final Color inactiveColor;
  final double size;
  final String timeText;
  final String subText;
  final VoidCallback? onTimeTap; // Callback khi tap vào thời gian

  const PyramidTimerWidget({
    super.key,
    required this.progress,
    required this.activeColor,
    required this.inactiveColor,
    this.size = 200,
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
  late Animation<double> _progressAnimation;
  double _previousProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800), // Animation mượt trong 800ms
      vsync: this,
    );
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.progress,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic, // Curve mượt mà
    ));
    
    _previousProgress = widget.progress;
    _animationController.forward();
  }

  @override
  void didUpdateWidget(PyramidTimerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Chỉ animate khi progress thay đổi
    if (oldWidget.progress != widget.progress) {
      _progressAnimation = Tween<double>(
        begin: _previousProgress,
        end: widget.progress,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutCubic,
      ));
      
      _previousProgress = widget.progress;
      _animationController.reset();
      _animationController.forward();
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
          // Kim tự tháp với animation
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return CustomPaint(
                size: Size(widget.size, widget.size * 0.8), // Chiều cao kim tự tháp = 80% chiều rộng
                painter: PyramidPainter(
                  progress: _progressAnimation.value,
                  activeColor: widget.activeColor,
                  inactiveColor: widget.inactiveColor,
                ),
              );
            },
          ),
          
          // Text hiển thị thời gian ở giữa kim tự tháp - có thể tap được
          Positioned(
            bottom: widget.size * 0.15, // Đặt text ở phần dưới kim tự tháp
            child: GestureDetector(
              onTap: widget.onTimeTap,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.timeText,
                    style: TextStyle(
                      fontSize: widget.size * 0.12, // Kích thước font tỷ lệ với size
                      fontWeight: FontWeight.bold,
                      color: widget.activeColor,
                    ),
                  ),
                  if (widget.subText.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      widget.subText,
                      style: TextStyle(
                        fontSize: widget.size * 0.06,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter để vẽ kim tự tháp 4 tầng
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
    final paint = Paint()
      ..style = PaintingStyle.fill;

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
    final pyramidWidth = size.width * 0.8;
    final pyramidHeight = size.height;
    final levelHeight = pyramidHeight / 4;
    
    // Tọa độ trung tâm
    final centerX = size.width / 2;
    final startY = size.height * 0.1; // Bắt đầu từ 10% chiều cao

    // Vẽ từng tầng (hình học từ trên xuống), nhưng tính active theo tiến trình từ dưới lên
    for (int level = 0; level < 4; level++) {
      // Tính toán độ rộng của mỗi tầng (tầng trên hẹp hơn tầng dưới)
      final levelWidth = pyramidWidth * (level + 1) / 4;
      final y = startY + level * levelHeight;
      
      // Xác định màu sắc dựa trên progress (fill bottom-up)
      // Mỗi tầng tương ứng với 25% progress, tầng dưới cùng được tô trước
      // Map: bottom(level=3) -> 0.25, level=2 -> 0.50, level=1 -> 0.75, top(level=0) -> 1.00
      final levelProgress = (4 - level) * 0.25;
      final isActive = progress >= levelProgress;
      
      // Tạo gradient màu đẹp hơn cho từng tầng
      Color levelColor;
      if (isActive) {
        // Gradient từ đỏ cam (bottom) đến xanh lá (top)
        final gradientProgress = level / 3.0; // 0.0 to 1.0 từ bottom lên top
        levelColor = Color.lerp(
          const Color(0xFFFF6B6B), // Đỏ cam đẹp
          const Color(0xFF4ECDC4), // Xanh mint đẹp
          gradientProgress,
        )!;
        
        // Thêm hiệu ứng glow cho tầng active
        levelColor = levelColor.withOpacity(0.9);
      } else {
        levelColor = inactiveColor.withOpacity(0.3);
      }
      
      // Vẽ hình thang cho mỗi tầng
      final path = Path();
      
      if (level == 0) {
        // Tầng đầu tiên - hình tam giác
        path.moveTo(centerX, y);
        path.lineTo(centerX - levelWidth / 2, y + levelHeight);
        path.lineTo(centerX + levelWidth / 2, y + levelHeight);
        path.close();
      } else {
        // Các tầng khác - hình thang
        final prevLevelWidth = pyramidWidth * level / 4;
        path.moveTo(centerX - prevLevelWidth / 2, y);
        path.lineTo(centerX + prevLevelWidth / 2, y);
        path.lineTo(centerX + levelWidth / 2, y + levelHeight);
        path.lineTo(centerX - levelWidth / 2, y + levelHeight);
        path.close();
      }
      
      // Vẽ shadow trước (chỉ cho tầng active)
      if (isActive) {
        final shadowPath = Path.from(path);
        shadowPath.transform(Matrix4.translationValues(2, 2, 0).storage);
        canvas.drawPath(shadowPath, shadowPaint);
      }
      
      // Tạo gradient paint cho tầng
      if (isActive) {
        final rect = path.getBounds();
        paint.shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            levelColor.withOpacity(1.0),
            levelColor.withOpacity(0.7),
          ],
        ).createShader(rect);
      } else {
        paint.shader = null;
        paint.color = levelColor;
      }
      
      // Vẽ tầng
      canvas.drawPath(path, paint);
      
      // Vẽ viền trắng với hiệu ứng glow nhẹ cho tầng active
      if (isActive) {
        strokePaint.color = Colors.white.withOpacity(0.9);
        strokePaint.strokeWidth = 2.5;
        strokePaint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);
      } else {
        strokePaint.color = Colors.white.withOpacity(0.4);
        strokePaint.strokeWidth = 1.5;
        strokePaint.maskFilter = null;
      }
      canvas.drawPath(path, strokePaint);
    }
  }

  @override
  bool shouldRepaint(PyramidPainter oldDelegate) {
    return oldDelegate.progress != progress ||
           oldDelegate.activeColor != activeColor ||
           oldDelegate.inactiveColor != inactiveColor;
  }
}