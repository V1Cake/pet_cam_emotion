import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: Text('Turn on the camera'),
              onPressed: () {
                Navigator.pushNamed(context, '/camera');
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('Video Demo Testing'),
              onPressed: () {
                Navigator.pushNamed(context, '/video_demo');
              },
            ),
          ],
        ),
      ),
    );
  }
}
