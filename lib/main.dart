import 'package:flutter/material.dart';
import 'package:practica_10_puntos/pages/login.dart';

void main() {
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Your App Title',
      home: LoginPage(),
    );
  }
}
