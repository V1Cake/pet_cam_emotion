// This file should only contain the FrameQueue class

class FrameQueue<T> {
  final int maxLength;
  final List<T> _queue = [];

  FrameQueue({this.maxLength = 3});

  void add(T item) {
    if (_queue.length >= maxLength) {
      _queue.removeAt(0); // 丢弃最旧帧
    }
    _queue.add(item);
  }

  T? get latest => _queue.isNotEmpty ? _queue.last : null;
  int get length => _queue.length;
  void clear() => _queue.clear();
}
