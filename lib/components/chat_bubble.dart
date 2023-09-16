import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final Color color;
  const ChatBubble({super.key, required this.message, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: color, borderRadius: BorderRadius.all(Radius.circular(4))),
      child: Text(message),
    );
  }
}
