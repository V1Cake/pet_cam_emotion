import 'package:flutter/material.dart';
import 'overlay_renderer.dart';

class OverlayPainter extends CustomPainter {
  final List<OverlayRenderer> renderers;

  OverlayPainter(this.renderers);

  @override
  void paint(Canvas canvas, Size size) {
    for (final renderer in renderers) {
      renderer.render(canvas, size);
    }
  }

  @override
  bool shouldRepaint(covariant OverlayPainter oldDelegate) {
    return true; // 你可以根据实际需求优化
  }
}

