import 'dart:typed_data';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:vet_motion_cam/services/udp_sender_service.dart';
import '../utils/image_utils.dart'; // 用于帧编码

class ModelService {
  late Interpreter _interpreter;

  // 初始化加载模型
  Future<void> loadModel() async {
    _interpreter = await Interpreter.fromAsset('model/model.tflite');
  }

  // 图像预处理（视模型要求调整，比如尺寸、归一化等）
  Uint8List preprocess(img.Image image) {
    // resize
    final resized = img.copyResize(image, width: 224, height: 224);
    // 转float32，归一化等，具体根据模型要求补充
    // 这里只返回uint8list占位，实际请写成Float32List并reshape
    return resized.getBytes();
  }

  // 推理主函数
  Future<List> runModel(Uint8List imageBytes) async {
    // 加载图片为image对象
    final image = img.decodeImage(imageBytes)!;
    final input = preprocess(image);
    // 假设模型输入shape为[1,224,224,3]
    var inputTensor = [List.generate(224, (i) => List.generate(224, (j) => List.filled(3, 0.0)))];
    // 实际这里需要把input按float填充进去
    // ...
    var output = List.filled(1 * 10, 0).reshape([1, 10]); // 假如输出10类
    _interpreter.run(inputTensor, output);
    return output[0];
  }
}
