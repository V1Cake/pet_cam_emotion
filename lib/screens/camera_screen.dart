import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../services/camera_service.dart';
import '../services/performance_service.dart';
import '../widgets/performance_panel.dart';
import '../widgets/overlay/overlay_painter.dart';
import '../widgets/overlay/bounding_box_renderer.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

/// 根据模型返回的数据生成 BoundingBox 列表
List<BoundingBox> generateBoundingBoxes(
  List<Map<String, dynamic>> modelResults,
  Size canvasSize,
) {
  return modelResults.map((result) {
    // 1. 计算实际像素坐标
    final rect = Rect.fromLTWH(
      (result['x'] as double) * canvasSize.width,
      (result['y'] as double) * canvasSize.height,
      (result['w'] as double) * canvasSize.width,
      (result['h'] as double) * canvasSize.height,
    );

    // 2. 根据置信度或类别动态设置颜色
    Color color;
    if (result['score'] != null && result['score'] is double) {
      double score = result['score'];
      if (score > 0.8) {
        color = Colors.green;
      } else if (score > 0.5) {
        color = Colors.yellow;
      } else {
        color = Colors.red;
      }
    } else {
      color = Colors.blue; // 默认色
    }

    // 3. 生成标签
    String label = result['label'] ?? 'Unknown';

    return BoundingBox(rect: rect, label: label, color: color);
  }).toList();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraService cameraService;
  late PerformanceService performanceService;
  bool _initialized = false;

  // 用于存储模型推理结果（可替换为实际推理结果）
  List<Map<String, dynamic>> modelResults = [];

  // 模拟接收联网数据的方法
  void onReceiveNetworkData(List<Map<String, dynamic>> data) {
    setState(() {
      modelResults = data;
    });
  }

  @override
  void initState() {
    super.initState();
    performanceService = PerformanceService();
    cameraService = CameraService(
      onFrameSampled: () {
        performanceService.increaseFrame();
      },
    );
    _initAll();
  }

  @override
  Future<void> _initAll() async {
    await cameraService.initialize();
    await cameraService.initializeUdpSender('192.168.1.100', 5000);
    setState(() {
      _initialized = true;
    });
  }

  @override
  void dispose() {
    cameraService.dispose();
    performanceService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (cameraService.controller == null ||
        !cameraService.controller!.value.isInitialized) {
      return const Scaffold(
        body: Center(child: Text('Error initializing camera.')),
      );
    }

    final Size canvasSize = MediaQuery.of(context).size;
    final List<BoundingBox> detectedBoxes =
        modelResults.isNotEmpty
            ? generateBoundingBoxes(modelResults, canvasSize)
            : [];

    return Scaffold(
      appBar: AppBar(title: Text('Camera')),
      body: Stack(
        children: [
          CameraPreview(cameraService.controller!),
          // 仅在有数据时才绘制框
          if (detectedBoxes.isNotEmpty)
            CustomPaint(
              painter: OverlayPainter([BoundingBoxRenderer(detectedBoxes)]),
              child: Container(),
            ),
          Positioned(
            top: 16,
            right: 16,
            child: PerformancePanel(performanceService: performanceService),
          ),
          // ====== 模拟按钮：点击后模拟接收数据 ======
          Positioned(
            bottom: 32,
            right: 32,
            child: FloatingActionButton(
              onPressed: () {
                // 模拟收到联网数据
                onReceiveNetworkData([
                  {
                    'x': 0.1,
                    'y': 0.2,
                    'w': 0.3,
                    'h': 0.2,
                    'label': 'Corgi',
                    'score': 0.85,
                  },
                  {
                    'x': 0.5,
                    'y': 0.4,
                    'w': 0.2,
                    'h': 0.15,
                    'label': 'Golden Retriever',
                    'score': 0.65,
                  },
                ]);
              },
              child: const Icon(Icons.cloud_download),
              tooltip: '模拟接收联网数据',
            ),
          ),
        ],
      ),
    );
  }
}
