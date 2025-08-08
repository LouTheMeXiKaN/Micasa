import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // SL7 compliance: The Dashboard (Screen 4) is the destination. Redirection handles the gate.
    return const Scaffold(
      body: Center(
        child: Text(
          'Dashboard (Screen 4)',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}