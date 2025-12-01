import 'package:flutter/material.dart';

class MyPage extends StatelessWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          '나의 밤톨',
          style: TextStyle(fontSize: 24, color: Colors.white),
        ),
      ),
    );
  }
}
