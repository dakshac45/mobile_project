import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_project/view/home.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project/controller/auth.dart';
import 'package:flutter_project/view/login.dart';
import 'package:flutter_project/view/signup.dart';
import 'package:flutter_project/view/camera.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get/get.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
  runApp(const MyApp());
  
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        body: AuthHelper().getUser() != null
            ? const HomeScreen()
            : const LoginPage(),
      ),
    );
  }
}