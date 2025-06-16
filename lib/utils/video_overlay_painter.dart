import 'package:flutter/material.dart';

class VideoOverlayPainter extends CustomPainter {
  final Map<String, dynamic>? frameData;
  final double videoWidth; // Original video width from controller
  final double videoHeight; // Original video height from controller
  final double
  renderWidth; // Actual rendering width of CustomPaint (screen width)
  final double
  renderHeight; // Actual rendering height of CustomPaint (screen height)

  VideoOverlayPainter({
    this.frameData,
    required this.videoWidth,
    required this.videoHeight,
    required this.renderWidth,
    required this.renderHeight,
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
    ['Nose', 'Jaw'],
    ['Jaw', 'Nape'],
    ['Nape', 'Withers'],
    ['Withers', 'Tail_set'],
    ['Tail_set', 'Tail_mid'],
    ['Tail_mid', 'Tail_tip'],
    ['Withers', 'Left_Elbow'],
    ['Left_Elbow', 'Left_Claw'],
    ['Left_Claw', 'Left_Foot'],
    ['Withers', 'Right_Elbow'],
    ['Right_Elbow', 'Right_Claw'],
    ['Right_Claw', 'Right_Foot'],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (frameData == null || frameData!.isEmpty) return;

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

    // If the video dimensions from the controller indicate a landscape video (e.g., 1280x720)
    // but the content *appears* to be rotated (e.g., portrait dog on its side),
    // it implies the CSV coordinates are relative to the *original portrait orientation*.
    // We need to transform these coordinates to the displayed landscape orientation.
    // Assuming a 90-degree clockwise rotation of a portrait video to fit landscape.
    final bool assumeRotation =
        (videoWidth > videoHeight) &&
        (renderWidth >
            renderHeight); // Check if decoded video is landscape but we're rendering landscape (implies rotation if content is portrait)

    // Example CSV coordinate: (originalCsvX, originalCsvY) from a 720x1280 portrait video
    // Displayed on screen: (x_display, y_display) in a 1280x720 landscape frame

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

        if (assumeRotation) {
          // If original video was logically portrait (e.g., 720x1280)
          // and displayed landscape (e.g., 1280x720) due to player rotation.
          // The videoWidth (1280) corresponds to original height (1280)
          // The videoHeight (720) corresponds to original width (720)

          // Transformed X in landscape frame is original Y in portrait frame
          normalizedX =
              originalCsvY /
              videoWidth; // Use actual videoWidth (1280) for X normalization
          // Transformed Y in landscape frame is original width - original X in portrait frame
          normalizedY =
              (videoHeight - originalCsvX) /
              videoHeight; // Use actual videoHeight (720) for Y normalization

          // Debugging
          // print('Painter: ROTATED $name: Original($originalCsvX, $originalCsvY) -> Normalized($normalizedX, $normalizedY)');
        } else {
          // No rotation assumed or detected (video is natively landscape or portrait and displayed as such)
          normalizedX = originalCsvX / videoWidth;
          normalizedY = originalCsvY / videoHeight;
          // Debugging
          // print('Painter: NON-ROTATED $name: Original($originalCsvX, $originalCsvY) -> Normalized($normalizedX, $normalizedY)');
        }

        // Scale to the actual CustomPaint rendering size (which is the screen size)
        parsedPoints[name] = Offset(
          normalizedX * renderWidth,
          normalizedY * renderHeight,
        );
        // print('Painter: Scaled $name: ${parsedPoints[name]}');
      }
    }

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
        oldDelegate.renderHeight != renderHeight;
  }
}
