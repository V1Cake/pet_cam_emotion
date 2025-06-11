import 'package:flutter/material.dart';
import 'routes.dart';
import 'services/model_service.dart'; // 记得导入你的模型服务

final modelService = ModelService();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await modelService.loadModel();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Camera Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: appRoutes,
      // home: MyHomePage(title: 'Flutter Demo Home Page'), // 可选：如未用路由，打开这一行
    );
  }
}
