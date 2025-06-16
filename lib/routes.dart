import 'screens/home_screen.dart';
import 'screens/camera_screen.dart';
import 'screens/video_demo_screen.dart';

final appRoutes = {
  '/': (context) => HomeScreen(),
  '/camera': (context) => CameraScreen(),
  '/video_demo': (context) => VideoDemoScreen(),
};
