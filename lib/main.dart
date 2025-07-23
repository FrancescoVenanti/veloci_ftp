import 'package:flutter/material.dart';
import 'screens/connection_screen.dart';

void main() {
  runApp(const VelociFTP());
}

class VelociFTP extends StatelessWidget {
  const VelociFTP({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'VelociFTP', home: const ConnectionScreen());
  }
}
