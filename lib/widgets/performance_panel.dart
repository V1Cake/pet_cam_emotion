// 用于内存信息
import 'package:flutter/material.dart';
import '../services/performance_service.dart';

class PerformancePanel extends StatelessWidget {
  final PerformanceService performanceService;

  const PerformancePanel({required this.performanceService, super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: performanceService,
      builder: (context, _) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('FPS: ${performanceService.fps.toStringAsFixed(1)}'),
                Text(
                  '内存: ${performanceService.memoryMB.toStringAsFixed(1)} MB',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
