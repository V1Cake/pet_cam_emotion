import 'package:flutter/material.dart';
import 'package:vet_motion_cam/widgets/overlay/overlay_painter.dart';
import 'overlay_renderer.dart';

class BoundingBox {
  final Rect rect;
  final String label;
  final Color color;

  BoundingBox({required this.rect, required this.label, required this.color});
}

class BoundingBoxRenderer implements OverlayRenderer {
  final List<BoundingBox> boxes;

  BoundingBoxRenderer(this.boxes);

  @override
  void render(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0;

    for (final box in boxes) {
      paint.color = box.color;
      canvas.drawRect(box.rect, paint);

      // 绘制标签
      final textSpan = TextSpan(
        text: box.label,
        style: TextStyle(
          color: box.color,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, Offset(box.rect.left, box.rect.top - 20));
    }
  }
}
