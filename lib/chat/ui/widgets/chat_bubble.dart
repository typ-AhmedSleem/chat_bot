import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:flutter/material.dart';

import '../../models/message.dart';

class ChatBubble extends StatelessWidget {
  late final Message msg;
  late final bool _showTail;

  ChatBubble({super.key, required String content, required bool isMe, required String timestamp, required bool showTail}) {
    msg = Message(content: content, sender: isMe ? SenderType.user : SenderType.bot, timestamp: timestamp);
    _showTail = showTail;
  }

  static ChatBubble ofMessage({required Message msg, required bool showTail}) {
    return ChatBubble(
      content: msg.content,
      isMe: msg.isMe,
      timestamp: msg.timestamp,
      showTail: showTail,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BubbleSpecialThree(
      text: msg.content,
      color: msg.isMe ? Colors.blue : const Color(0xFFE8E8EE),
      isSender: msg.isMe,
      tail: _showTail,
      textStyle: TextStyle(color: msg.isMe ? Colors.white : Colors.black, fontSize: 15.0),
    );
  }
}
