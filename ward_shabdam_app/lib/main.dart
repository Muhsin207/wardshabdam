import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const WardShabdamApp());
}

class WardShabdamApp extends StatelessWidget {
  const WardShabdamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Ward Shabdam",
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const LoginScreen(),
    );
  }
}