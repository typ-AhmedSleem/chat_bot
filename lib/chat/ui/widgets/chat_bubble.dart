import 'dart:io';

import 'package:chat_bot/chat/ui/widgets/chat_action_announcement_bubble.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:flutter/material.dart';

import '../../models/message.dart';

class ChatBubble extends StatelessWidget {
  final Message message;
  final bool showTail;

  const ChatBubble({super.key, required this.message, required this.showTail});

  static ChatBubble ofMessage({required Message msg, required bool showTail}) {
    return ChatBubble(message: msg, showTail: showTail);
  }

  @override
  Widget build(BuildContext context) {
    // * Return the bubble widget suitable for this message
    switch (message.type) {
      case MessageType.text:
        if (message.sender == SenderType.announcement) {
          // Announcement bubble
          return ActionAnnouncementBubble(content: message.content);
        } else {
          // Normal text bubble from user or bot
          return BubbleSpecialThree(
            text: message.content,
            color: message.isMe ? Colors.blue : const Color(0xFFE8E8EE),
            isSender: message.isMe,
            tail: showTail,
            textStyle: TextStyle(color: message.isMe ? Colors.white : Colors.black, fontSize: 15.0),
          );
        }
      case MessageType.image:
        // Image bubble
        return BubbleNormalImage(id: message.content.hashCode.toString(), image: Image.file(File(message.content)));
      default:
        return Container();
    }
  }
}
