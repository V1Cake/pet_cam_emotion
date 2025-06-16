import 'package:flutter/material.dart';

String _getMockEmotion() {
  // 可以根据帧数返回一个标签
  const emotions = ['兴奋', '高兴', '平静', '伤心'];
  return emotions[DateTime.now().second % emotions.length];
}

class EmotionWidget extends StatefulWidget {
  const EmotionWidget({super.key});

  @override
  State<EmotionWidget> createState() => _EmotionWidgetState();
}

class _EmotionWidgetState extends State<EmotionWidget> {
  String currentEmotion = "未知";

  void _updateEmotion() {
    setState(() {
      currentEmotion = _getMockEmotion();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('当前情绪: $currentEmotion'),
        ElevatedButton(onPressed: _updateEmotion, child: Text('模拟刷新情绪')),
      ],
    );
  }
}
