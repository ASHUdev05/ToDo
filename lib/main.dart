import 'package:flutter/material.dart';
import 'package:todo_offline/navbarControllers/home_screen.dart';
import 'package:todo_offline/services/local_notification.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalNotification.init();
  runApp(const MaterialApp(
    home: Scaffold(
      body: HomeScreen(),
    ),
  ));
}
