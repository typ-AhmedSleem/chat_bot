import 'package:chat_bot/helpers/datetime_helper.dart';
import 'package:chat_bot/helpers/texts.dart';

enum SenderType { user, bot, announcement, api }

enum MessageType { text, image }

class Message {
  final MessageType type;
  final String content;
  final SenderType sender;
  final String timestamp;

  bool get isMe => (SenderType.user == sender);

  bool get isImageMessage => (MessageType.image == type);

  Message({required this.type, required this.content, required this.sender, required this.timestamp});

  static Message now({MessageType type = MessageType.text, required String content, required SenderType sender}) {
    return Message(type: type, content: content, sender: sender, timestamp: nowFormatted());
  }

  static Message user({required String content}) => now(content: content, sender: SenderType.user);

  static Message bot({required String content}) => now(content: content, sender: SenderType.bot);

  static Message announcement({required String content}) => now(content: content, sender: SenderType.announcement);

  static Message image({required String path}) => now(type: MessageType.image, content: path, sender: SenderType.user);

  static Message api({required dynamic payload}) => APIMessage(payload);

  static Message defaultMessage() => Message.bot(content: Texts.startOfChatMessageContent);

  Message editedClone({MessageType? type, String? content, SenderType? sender, String? timestamp}) {
    return Message(type: type ?? this.type, content: content ?? this.content, sender: sender ?? this.sender, timestamp: timestamp ?? this.timestamp);
  }
}

class APIMessage extends Message {
  final dynamic payload;

  APIMessage(this.payload) : super(type: MessageType.text, content: payload.toString(), sender: SenderType.bot, timestamp: nowFormatted());
}
