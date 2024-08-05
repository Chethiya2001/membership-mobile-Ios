import 'package:flutter/material.dart';
import 'package:mobile_app/constant/colors/main_colors.dart';

class RPSCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Layer 1

    Paint paintFill0 = Paint()
      ..color = maingbg
      ..style = PaintingStyle.fill
      ..strokeWidth = size.width * 0.00
      ..strokeCap = StrokeCap.butt
      ..strokeJoin = StrokeJoin.miter;

    Path path_0 = Path();
    path_0.moveTo(size.width * 0.0001375, size.height * 0.0025000);
    path_0.lineTo(size.width * 1.0012500, size.height * 0.0025000);
    path_0.lineTo(size.width * 1.0012500, size.height * 0.9000000);
    path_0.quadraticBezierTo(size.width * 0.9769000, size.height * 0.7611000,
        size.width * 0.9247250, size.height * 0.76000);
    path_0.cubicTo(
        size.width * 0.9646625,
        size.height * 0.7361750,
        size.width * 0.2843312,
        size.height * 0.7524062,
        size.width * 0.0642000,
        size.height * 0.7522000);
    path_0.quadraticBezierTo(size.width * 0.0065270, size.height * 0.7557520, 0,
        size.height * 0.6225020);
    path_0.lineTo(size.width * 0.0001375, size.height * 0.0025000);
    path_0.close();

    canvas.drawPath(path_0, paintFill0);

    // Layer 1

    Paint paintStroke0 = Paint()
      ..color = Colors.transparent
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.00
      ..strokeCap = StrokeCap.butt
      ..strokeJoin = StrokeJoin.miter;

    canvas.drawPath(path_0, paintStroke0);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
