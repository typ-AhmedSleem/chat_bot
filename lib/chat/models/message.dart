import 'package:chat_bot/helpers/datetime_helper.dart';
import 'package:chat_bot/helpers/texts.dart';

enum SenderType { user, bot, announcement }

class Message {
  final String content;
  final SenderType sender;
  final String timestamp;

  bool get isMe => (SenderType.user == sender);

  Message({required this.content, required this.sender, required this.timestamp});

  static Message now({required String content, required SenderType sender}) => Message(content: content, sender: sender, timestamp: nowFormatted());

  static Message user({required String content}) => now(content: content, sender: SenderType.user);

  static Message bot({required String content}) => now(content: content, sender: SenderType.bot);

  static Message announcement({required String content}) => now(content: content, sender: SenderType.announcement);

  static Message defaultMessage() {
    return Message.bot(content: Texts.startOfChatMessageContent);
  }

  Message editedClone({String? content, SenderType? sender, String? timestamp}) {
    return Message(content: content ?? this.content, sender: sender ?? this.sender, timestamp: timestamp ?? this.timestamp);
  }
}
