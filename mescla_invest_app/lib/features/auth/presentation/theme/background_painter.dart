/* Autor: Gabriela Sichiroli Ferrari */

import 'package:flutter/material.dart';

class BackgroundPainter extends CustomPainter {
  const BackgroundPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    //LOSANGO (quadrado girado)
    final path = Path();
    path.moveTo(size.width * 0.5, size.height * 0.1);
    path.lineTo(size.width * 0.9, size.height * 0.5);
    path.lineTo(size.width * 0.5, size.height * 0.9);
    path.lineTo(size.width * 0.1, size.height * 0.5);
    path.close();

    canvas.drawPath(path, paint);

    //CÍRCULOS
    canvas.drawCircle(
        Offset(size.width * 0.2, size.height * 0.8), 30, paint);

    canvas.drawCircle(
        Offset(size.width * 0.8, size.height * 0.7), 40, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}