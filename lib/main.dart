
import 'package:flutter/material.dart';
import 'home_screen.dart';

void main() {
  runApp(const CampusPulseApp());
}

class CampusPulseApp extends StatelessWidget {
  const CampusPulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Campus Pulse',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}
