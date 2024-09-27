import 'package:flutter/material.dart';
import 'package:frc_stategy_app/classes/semantic_line.dart';

class FieldPainter extends CustomPainter {
  final List<SemanticLine> lines;
  final SemanticLine? tempLine;

  FieldPainter(this.lines, this.tempLine);

  @override
  void paint(Canvas canvas, Size size) {
    for (SemanticLine line in lines) {
      if(!line.isVisible) continue;
      final paint = Paint()
        ..color = line.color
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 5.0;

      for (int i = 0; i < line.points.length - 1; i++) {
        if (line.points[i] != null && line.points[i + 1] != null) {
          canvas.drawLine(line.points[i], line.points[i + 1], paint);
        }
      }
    }

    if (tempLine != null) {
      final paint = Paint()
        ..color = tempLine!.color
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 5.0;

      for (int i = 0; i < tempLine!.points.length - 1; i++) {
        if (tempLine!.points[i] != null && tempLine!.points[i + 1] != null) {
          canvas.drawLine(tempLine!.points[i], tempLine!.points[i + 1], paint);
        }
      }
    }
    
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}