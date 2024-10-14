import 'package:flutter/material.dart';
import 'package:todo_offline/today_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TodayScreen(context),
    );
  }
}