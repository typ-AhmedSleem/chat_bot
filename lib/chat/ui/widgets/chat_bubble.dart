import 'dart:io';

import 'package:chat_bot/chat/ui/widgets/chat_action_announcement_bubble.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:flutter/material.dart';

import '../../models/message.dart';

class ChatBubble extends StatelessWidget {
  late final Message msg;
  late final bool _showTail;

  ChatBubble({super.key, required MessageType type, required String content, required bool isMe, required String timestamp, required bool showTail}) {
    msg = Message(type: type, content: content, sender: isMe ? SenderType.user : SenderType.bot, timestamp: timestamp);
    _showTail = showTail;
  }

  static ChatBubble ofMessage({required Message msg, required bool showTail}) {
    return ChatBubble(
      type: msg.type,
      content: msg.content,
      isMe: msg.isMe,
      timestamp: msg.timestamp,
      showTail: showTail,
    );
  }

  @override
  Widget build(BuildContext context) {
    // * Return the bubble widget suitable for this message
    switch (msg.type) {
      case MessageType.text:
        if (msg.sender == SenderType.announcement) {
          // Announcement bubble
          return ActionAnnouncementBubble(content: msg.content);
        } else {
          // Normal text bubble from user or bot
          return BubbleSpecialThree(
            text: msg.content,
            color: msg.isMe ? Colors.blue : const Color(0xFFE8E8EE),
            isSender: msg.isMe,
            tail: _showTail,
            textStyle: TextStyle(color: msg.isMe ? Colors.white : Colors.black, fontSize: 15.0),
          );
        }
      case MessageType.image:
        // Image bubble
        print("Displaying image at path: ${File(msg.content)}");
        return BubbleNormalImage(id: msg.content.hashCode.toString(), image: Image.file(File(msg.content)));
      default:
        return Container();
    }
  }
}
