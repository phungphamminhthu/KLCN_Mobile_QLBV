
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class PasswordVisibilityIcon extends StatelessWidget {
  final bool isHidden;
  final Color color;
  final double size;

  const PasswordVisibilityIcon({
    super.key,
    required this.isHidden,
    this.color = const Color(0xFF64748B),
    this.size = 21,
  });

  @override
  Widget build(BuildContext context) {
    if (!isHidden) {
      return Icon(
        LucideIcons.eye,
        size: size,
        color: color,
      );
    }

    return CustomPaint(
      size: Size(size, size),
      painter: _ClosedEyePainter(color),
    );
  }
}

class _ClosedEyePainter extends CustomPainter {
  final Color color;

  _ClosedEyePainter(this.color);

  
    
@override
void paint(Canvas canvas, Size size) {
  final paint = Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.7
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  // Đường mí mắt nhắm: cụp xuống ở giữa
  final eyelid = Path()
    ..moveTo(size.width * 0.08, size.height * 0.32)
    ..quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.88,
      size.width * 0.92,
      size.height * 0.32,
    );

  canvas.drawPath(eyelid, paint);

  // Lông mi bên trái
  final leftLash = Path()
    ..moveTo(size.width * 0.22, size.height * 0.48)
    ..lineTo(size.width * 0.12, size.height * 0.65);

  canvas.drawPath(leftLash, paint);

  // Lông mi ở giữa bên trái
  final middleLeftLash = Path()
    ..moveTo(size.width * 0.38, size.height * 0.65)
    ..lineTo(size.width * 0.34, size.height * 0.82);

  canvas.drawPath(middleLeftLash, paint);

  // Lông mi ở giữa bên phải
  final middleRightLash = Path()
    ..moveTo(size.width * 0.62, size.height * 0.65)
    ..lineTo(size.width * 0.66, size.height * 0.82);

  canvas.drawPath(middleRightLash, paint);

  // Lông mi bên phải
  final rightLash = Path()
    ..moveTo(size.width * 0.78, size.height * 0.48)
    ..lineTo(size.width * 0.88, size.height * 0.65);

  canvas.drawPath(rightLash, paint);
}



  @override
  bool shouldRepaint(covariant _ClosedEyePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
