import 'package:flutter/material.dart';

class NearbyPage extends StatelessWidget {
  const NearbyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          '내 근처',
          style: TextStyle(fontSize: 24, color: Colors.white),
        ),
      ),
    );
  }
}
