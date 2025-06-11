import 'dart:async';
import 'package:flutter/foundation.dart';

class PerformanceService extends ChangeNotifier {
  int _frameCount = 0;
  double _fps = 0;
  Timer? _timer;

  double get fps => _fps;
  double get memoryMB => 0; // 暂时返回0

  PerformanceService() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _fps = _frameCount.toDouble();
      _frameCount = 0;
      notifyListeners();
    });
  }

  void increaseFrame() {
    _frameCount++;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
