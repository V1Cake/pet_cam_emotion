import 'dart:isolate';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import 'dart:typed_data';

Future<void> processVideoFrame(Uint8List frame) async {
  await Isolate.run(() {
    // 复杂运算放这里（如图像预处理/推理）
  });
}

// 将CameraImage编码为JPEG
Future<Uint8List?> encodeCameraImageToJpeg(CameraImage image) async {
  try {
    if (image.format.group != ImageFormatGroup.yuv420) return null;
    final int width = image.width;
    final int height = image.height;

    // 1. YUV420转RGB
    final img.Image rgbImage = yuv420ToImage(image);

    // 2. 编码为JPEG
    return Uint8List.fromList(img.encodeJpg(rgbImage));
  } catch (e) {
    return null;
  }
}

// YUV420转RGB
img.Image yuv420ToImage(CameraImage image) {
  final int width = image.width;
  final int height = image.height;
  final img.Image rgbImage = img.Image(width: width, height: height);

  final yPlane = image.planes[0];
  final uPlane = image.planes[1];
  final vPlane = image.planes[2];

  final int uvRowStride = uPlane.bytesPerRow;
  final int uvPixelStride = uPlane.bytesPerPixel!;

  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      final int yIndex = y * yPlane.bytesPerRow + x;
      final int uvIndex = (y ~/ 2) * uvRowStride + (x ~/ 2) * uvPixelStride;

      final int yValue = yPlane.bytes[yIndex];
      final int uValue = uPlane.bytes[uvIndex];
      final int vValue = vPlane.bytes[uvIndex];

      // YUV转RGB公式
      int r = (yValue + 1.370705 * (vValue - 128)).round();
      int g =
          (yValue - 0.337633 * (uValue - 128) - 0.698001 * (vValue - 128))
              .round();
      int b = (yValue + 1.732446 * (uValue - 128)).round();

      // 限定在0~255
      r = r.clamp(0, 255);
      g = g.clamp(0, 255);
      b = b.clamp(0, 255);

      rgbImage.setPixel(x, y, img.getColor(r, g, b));
    }
  }
  return rgbImage;
}
