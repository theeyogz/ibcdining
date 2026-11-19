
import 'package:flutter/material.dart';
import 'screens/auth_screens.dart';

void main() {
  runApp(const IBCDiningApp());
}

class IBCDiningApp extends StatelessWidget {
  const IBCDiningApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'IBC Dining',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F7F5),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E3A34),
          surface: Colors.white,
        ),
      ),
      home: const AuthGate(),
    );
  }
}
