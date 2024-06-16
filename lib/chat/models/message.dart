import 'package:chat_bot/helpers/datetime_helper.dart';
import 'package:chat_bot/helpers/texts.dart';

class Message {
  final String content;
  final bool isMe;
  final String timestamp;

  Message({required this.content, required this.isMe, required this.timestamp});

  static Message defaultMessage() {
    return Message(content: Texts.startOfChatMessageContent, isMe: false, timestamp: nowFormatted());
  }

  Message editedClone({String? content, bool? isMe, String? timestamp}) {
    return Message(content: content ?? this.content, isMe: isMe ?? this.isMe, timestamp: timestamp ?? this.timestamp);
  }
}
