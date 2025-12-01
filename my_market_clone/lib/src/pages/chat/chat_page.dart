import 'package:flutter/material.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          '채팅',
          style: TextStyle(fontSize: 24, color: Colors.white),
        ),
      ),
    );
  }
}
