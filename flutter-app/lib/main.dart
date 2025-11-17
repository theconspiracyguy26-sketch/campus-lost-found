import 'package:flutter/material.dart';
import 'src/screens/auth_page.dart';
import 'src/services/appwrite_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppwriteService.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campus Lost & Found',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: AuthPage(),
    );
  }
}
