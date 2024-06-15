import 'package:flutter/material.dart';

import '../models/message.dart';

class ChatBubble extends StatelessWidget {
  late final Message msg;

  ChatBubble({super.key, required String content, required bool isMe, required String timestamp}) {
    msg = Message(content: content, isMe: isMe, timestamp: timestamp);
  }

  static ChatBubble ofMessage({required Message msg}) {
    return ChatBubble(content: msg.content, isMe: msg.isMe, timestamp: msg.timestamp);
  }

  static ChatBubble botBubble({required String content, required String timestamp}) {
    return ChatBubble(content: content, isMe: false, timestamp: timestamp);
  }

  static ChatBubble userBubble({required String content, required String timestamp}) {
    return ChatBubble(content: content, isMe: false, timestamp: timestamp);
  }

  @override
  Widget build(BuildContext context) {
    const radius = Radius.circular(12.0);
    return Align(
      alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: msg.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0),
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
            decoration: BoxDecoration(
              color: msg.isMe ? Colors.blue : Colors.grey[300],
              borderRadius: BorderRadius.only(
                topLeft: radius,
                topRight: radius,
                bottomLeft: msg.isMe ? radius : const Radius.circular(0),
                bottomRight: msg.isMe ? const Radius.circular(0) : radius,
              ),
            ),
            child: Column(
              crossAxisAlignment: msg.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  msg.content,
                  style: TextStyle(
                    color: msg.isMe ? Colors.white : Colors.black,
                  ),
                ),
                Text(
                  msg.timestamp,
                  style: TextStyle(
                    color: msg.isMe ? Colors.white70 : Colors.black54,
                    fontSize: 10.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
