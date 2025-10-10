import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Circular Time Picker Widget
/// Cho phép chọn thời gian từ 5 phút đến 3 giờ với giao diện vòng tròn như đồng hồ báo thức
class CircularTimePicker extends StatefulWidget {
  final Duration initialDuration;
  final Duration minDuration;
  final Duration maxDuration;
  final ValueChanged<Duration> onDurationChanged;
  final Color primaryColor;
  final Color backgroundColor;
  final double size;

  const CircularTimePicker({
    super.key,
    required this.initialDuration,
    required this.onDurationChanged,
    this.minDuration = const Duration(minutes: 5),
    this.maxDuration = const Duration(hours: 3),
    this.primaryColor = Colors.blue,
    this.backgroundColor = Colors.grey,
    this.size = 280.0,
  });

  @override
  State<CircularTimePicker> createState() => _CircularTimePickerState();
}

class _CircularTimePickerState extends State<CircularTimePicker> {
  late Duration _currentDuration;
  double _angle = 0.0;

  @override
  void initState() {
    super.initState();
    _currentDuration = widget.initialDuration;
    _updateAngleFromDuration();
  }

  void _updateAngleFromDuration() {
    final totalMinutes = _currentDuration.inMinutes;
    final minMinutes = widget.minDuration.inMinutes;
    final maxMinutes = widget.maxDuration.inMinutes;
    
    // Chuyển đổi từ minutes sang angle (0 - 2π)
    final progress = (totalMinutes - minMinutes) / (maxMinutes - minMinutes);
    _angle = progress * 2 * math.pi;
  }

  void _updateDurationFromAngle() {
    final minMinutes = widget.minDuration.inMinutes;
    final maxMinutes = widget.maxDuration.inMinutes;
    
    // Chuyển đổi từ angle sang minutes
    final progress = _angle / (2 * math.pi);
    final totalMinutes = (minMinutes + progress * (maxMinutes - minMinutes)).round();
    
    // Làm tròn theo bước 5 phút
    final roundedMinutes = (totalMinutes / 5).round() * 5;
    final clampedMinutes = roundedMinutes.clamp(minMinutes, maxMinutes);
    
    _currentDuration = Duration(minutes: clampedMinutes);
    widget.onDurationChanged(_currentDuration);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final center = Offset(widget.size / 2, widget.size / 2);
    final position = details.localPosition - center;
    
    // Tính góc từ vị trí touch
    double newAngle = math.atan2(position.dy, position.dx);
    
    // Chuyển đổi từ -π -> π sang 0 -> 2π
    if (newAngle < 0) {
      newAngle += 2 * math.pi;
    }
    
    // Xoay 90 độ để bắt đầu từ trên cùng
    newAngle = (newAngle + 3 * math.pi / 2) % (2 * math.pi);
    
    setState(() {
      _angle = newAngle;
      _updateDurationFromAngle();
    });
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.backgroundColor.withValues(alpha: 0.1),
              border: Border.all(
                color: widget.backgroundColor.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
          ),
          
          // Time markers
          CustomPaint(
            size: Size(widget.size, widget.size),
            painter: TimeMarkersPainter(
              primaryColor: widget.primaryColor,
              backgroundColor: widget.backgroundColor,
              minDuration: widget.minDuration,
              maxDuration: widget.maxDuration,
            ),
          ),
          
          // Progress arc
          CustomPaint(
            size: Size(widget.size, widget.size),
            painter: ProgressArcPainter(
              angle: _angle,
              primaryColor: widget.primaryColor,
              strokeWidth: 8.0,
            ),
          ),
          
          // Draggable handle
          Positioned(
            left: widget.size / 2 + (widget.size / 2 - 20) * math.cos(_angle - math.pi / 2) - 15,
            top: widget.size / 2 + (widget.size / 2 - 20) * math.sin(_angle - math.pi / 2) - 15,
            child: GestureDetector(
              onPanUpdate: _onPanUpdate,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.primaryColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.drag_handle,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
          
          // Center display
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).scaffoldBackgroundColor,
              border: Border.all(
                color: widget.primaryColor.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _formatDuration(_currentDuration),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: widget.primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Focus Time',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          
          // Gesture detector for the entire widget
          GestureDetector(
            onPanUpdate: _onPanUpdate,
            child: Container(
              width: widget.size,
              height: widget.size,
              color: Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }
}

/// Painter cho các vạch thời gian
class TimeMarkersPainter extends CustomPainter {
  final Color primaryColor;
  final Color backgroundColor;
  final Duration minDuration;
  final Duration maxDuration;

  TimeMarkersPainter({
    required this.primaryColor,
    required this.backgroundColor,
    required this.minDuration,
    required this.maxDuration,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;
    
    final paint = Paint()
      ..color = backgroundColor.withValues(alpha: 0.5)
      ..strokeWidth = 1;

    // Vẽ các vạch thời gian (mỗi 15 phút)
    final totalMinutes = maxDuration.inMinutes - minDuration.inMinutes;
    final stepMinutes = 15;
    final steps = (totalMinutes / stepMinutes).ceil();
    
    for (int i = 0; i <= steps; i++) {
      final angle = (i / steps) * 2 * math.pi - math.pi / 2;
      final isMainMark = i % 4 == 0; // Mỗi giờ
      
      final startRadius = radius - (isMainMark ? 15 : 8);
      final endRadius = radius;
      
      final startX = center.dx + startRadius * math.cos(angle);
      final startY = center.dy + startRadius * math.sin(angle);
      final endX = center.dx + endRadius * math.cos(angle);
      final endY = center.dy + endRadius * math.sin(angle);
      
      paint.strokeWidth = isMainMark ? 2 : 1;
      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        paint,
      );
      
      // Vẽ nhãn thời gian cho các vạch chính
      if (isMainMark) {
        final minutes = minDuration.inMinutes + (i * stepMinutes);
        final duration = Duration(minutes: minutes);
        final label = duration.inHours > 0 
            ? '${duration.inHours}h'
            : '${duration.inMinutes}m';
        
        final textPainter = TextPainter(
          text: TextSpan(
            text: label,
            style: TextStyle(
              color: backgroundColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        
        textPainter.layout();
        
        final labelRadius = radius - 30;
        final labelX = center.dx + labelRadius * math.cos(angle) - textPainter.width / 2;
        final labelY = center.dy + labelRadius * math.sin(angle) - textPainter.height / 2;
        
        textPainter.paint(canvas, Offset(labelX, labelY));
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Painter cho arc tiến trình
class ProgressArcPainter extends CustomPainter {
  final double angle;
  final Color primaryColor;
  final double strokeWidth;

  ProgressArcPainter({
    required this.angle,
    required this.primaryColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;
    
    final paint = Paint()
      ..color = primaryColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Vẽ arc từ trên cùng đến vị trí hiện tại
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Bắt đầu từ trên cùng
      angle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}