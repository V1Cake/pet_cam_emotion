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

  VideoOverlayPainter({
    this.frameData,
    required this.videoWidth,
    required this.videoHeight,
    required this.renderWidth,
    required this.renderHeight,
    this.offsetX = -170.0, // Default to 0.0
    this.offsetY = -130.0, // Default to 0.0
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

    // 计算缩放比例，保持原始比例，居中显示
    double scale = min(renderWidth / videoWidth, renderHeight / videoHeight);
    double displayVideoWidth = videoWidth * scale;
    double displayVideoHeight = videoHeight * scale;

    // 计算自动居中偏移
    double autoOffsetX = (renderWidth - displayVideoWidth) / 2;
    double autoOffsetY = (renderHeight - displayVideoHeight) / 2;

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

        double normalizedX, normalizedY;

        // 仅进行归一化，不进行坐标旋转
        normalizedX = originalCsvX / videoWidth;
        normalizedY = originalCsvY / videoHeight;

        // Debugging: Print a few keypoint coordinates after normalization
        if (name == 'Nose' || name == 'Tail_tip') {
          print(
            'Painter: $name: originalCsvX: $originalCsvX, originalCsvY: $originalCsvY',
          );
          print(
            'Painter: $name: normalizedX: $normalizedX, normalizedY: $normalizedY',
          );
        }

        // 点位映射时，叠加手动微调偏移
        parsedPoints[name] = Offset(
          normalizedX * displayVideoWidth + autoOffsetX + this.offsetX,
          normalizedY * displayVideoHeight + autoOffsetY + this.offsetY,
        );
      }
    }

    // 保存当前的 canvas 状态
    canvas.save();

    // 不再需要移动原点和旋转，直接绘制

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

    // 恢复 canvas 状态
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant VideoOverlayPainter oldDelegate) {
    return oldDelegate.frameData != frameData ||
        oldDelegate.videoWidth != videoWidth ||
        oldDelegate.videoHeight != videoHeight ||
        oldDelegate.renderWidth != renderWidth ||
        oldDelegate.renderHeight != renderHeight ||
        oldDelegate.offsetX != offsetX || // Include offsetX in repaint check
        oldDelegate.offsetY != offsetY; // Include offsetY in repaint check
  }
}
