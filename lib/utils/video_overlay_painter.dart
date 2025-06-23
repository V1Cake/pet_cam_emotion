import 'package:flutter/material.dart';
import 'dart:math'; // 导入 math 库以使用 pi

class VideoOverlayPainter extends CustomPainter {
  final Map<String, dynamic>? frameData;
  final double videoWidth; // Original video width from controller
  final double videoHeight; // Original video height from controller
  final double
  renderWidth; // Actual rendering width of CustomPaint (screen width)
  final double
  renderHeight; // Actual rendering height of CustomPaint (screen height)
  final double offsetX; // Manual offset for X coordinate
  final double offsetY; // Manual offset for Y coordinate
  final double manualScale; // 恢复整体缩放比例

  VideoOverlayPainter({
    this.frameData,
    required this.videoWidth,
    required this.videoHeight,
    required this.renderWidth,
    required this.renderHeight,
    this.offsetX = -20.0,
    this.offsetY = -10.0,
    this.manualScale = 0.7, // 新增
  });

  // Define the ordered list of keypoint names from your CSV 'bodyparts' row
  final List<String> _keypointNames = const [
    'Nose',
    'Jaw',
    'Nape',
    'Withers',
    'Tail_set',
    'Tail_mid',
    'Tail_tip',
    'Left_Elbow',
    'Left_Claw',
    'Right_Elbow',
    'Right_Claw',
    'Left_Foot',
    'Right_Foot',
  ];

  // Define skeleton connections based on your animal's anatomy
  final List<List<String>> _skeletonConnections = const [
    ['Nose', 'Nape'],
    ['Nape', 'Jaw'],
    ['Nape', 'Withers'],
    ['Withers', 'Tail_set'],
    ['Tail_set', 'Tail_mid'],
    ['Tail_mid', 'Tail_tip'],
    ['Withers', 'Left_Elbow'],
    ['Withers', 'Right_Elbow'],
    ['Left_Elbow', 'Left_Claw'],
    ['Withers', 'Right_Elbow'],
    ['Right_Elbow', 'Right_Claw'],
    ['Tail_set', 'Left_Foot'],
    ['Tail_set', 'Right_Foot'],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (frameData == null || frameData!.isEmpty) return;

    // Debugging: Print video and render dimensions
    print('Painter: videoWidth: $videoWidth, videoHeight: $videoHeight');
    print('Painter: renderWidth: $renderWidth, renderHeight: $renderHeight');

    final pointPaint =
        Paint()
          ..color = Colors.green
          ..style = PaintingStyle.fill
          ..strokeWidth = 6; // Make points more visible
    final linePaint =
        Paint()
          ..color = Colors.blue
          ..strokeWidth = 3;

    final Map<String, Offset> parsedPoints = {};

    // 计算拉伸比例，左上角为基准
    double scaleX = renderWidth / videoWidth;
    double scaleY = renderHeight / videoHeight;

    for (final name in _keypointNames) {
      final xKey = '${name}_x';
      final yKey = '${name}_y';

      final xValue = frameData![xKey];
      final yValue = frameData![yKey];
      final likelihoodKey = '${name}_likelihood';
      final likelihoodValue =
          double.tryParse(frameData![likelihoodKey] ?? '') ?? 0.0;

      if (xValue != null && yValue != null && likelihoodValue > 0.5) {
        double originalCsvX = double.tryParse(xValue.toString()) ?? 0.0;
        double originalCsvY = double.tryParse(yValue.toString()) ?? 0.0;

        // 拉伸到全屏后再整体等比例缩放
        double px = originalCsvX * scaleX * manualScale + offsetX;
        double py = originalCsvY * scaleY * manualScale + offsetY;
        parsedPoints[name] = Offset(px, py);
      }
    }

    // 直接绘制，不进行任何变换

    // Draw points
    for (final entry in parsedPoints.entries) {
      canvas.drawCircle(entry.value, 6, pointPaint);
    }

    // Draw skeleton lines
    for (final connection in _skeletonConnections) {
      final startPointName = connection[0];
      final endPointName = connection[1];

      final startPoint = parsedPoints[startPointName];
      final endPoint = parsedPoints[endPointName];

      if (startPoint != null && endPoint != null) {
        canvas.drawLine(startPoint, endPoint, linePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant VideoOverlayPainter oldDelegate) {
    return oldDelegate.frameData != frameData ||
        oldDelegate.videoWidth != videoWidth ||
        oldDelegate.videoHeight != videoHeight ||
        oldDelegate.renderWidth != renderWidth ||
        oldDelegate.renderHeight != renderHeight ||
        oldDelegate.offsetX != offsetX || // Include offsetX in repaint check
        oldDelegate.offsetY != offsetY || // Include offsetY in repaint check
        oldDelegate.manualScale !=
            manualScale; // Include manualScale in repaint check
  }
}
