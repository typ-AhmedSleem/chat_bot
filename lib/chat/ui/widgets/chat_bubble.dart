import 'dart:io';

import 'package:chat_bot/api/models/response_models.dart';
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
    // * Check if the message is api message
    if (message is APIMessage) {
      final msg = message as APIMessage;
      if (msg.payload is RecognizedPerson) {
        return UserInfoWidget(person: msg.payload as RecognizedPerson);
      } else {
        return Text(msg.payload.toString());
      }
    }
    // * Normal messages
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

class UserInfoWidget extends StatelessWidget {
  final RecognizedPerson person;

  const UserInfoWidget({super.key, required this.person});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipOval(
                child: SizedBox(
                  width: 200,
                  height: 200,
                  child: Image.network(
                    person.familyAvatarUrl,
                    isAntiAlias: true,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              person.familyName,
              style: const TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Relation: ${person.relation}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 2),
            Text(
              'Phone Number: ${person.familyPhoneNumber}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 2),
            Text(
              'Description: ${person.descriptionOfPatient}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'Location:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Latitude: ${person.familyLatitude}',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Longitude: ${person.familyLongitude}',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
