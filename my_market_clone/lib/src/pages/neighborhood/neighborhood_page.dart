import 'package:flutter/material.dart';

class NeighborhoodPage extends StatelessWidget {
  const NeighborhoodPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          '동네생활',
          style: TextStyle(fontSize: 24, color: Colors.white),
        ),
      ),
    );
  }
}
