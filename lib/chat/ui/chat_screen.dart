import 'package:flutter/material.dart';

import '../models/message.dart';
import 'chat_bubble.dart';
import '../../helpers/texts.dart';
import 'package:chat_bot/chat_bot.dart';

void main() {
  runApp(const ChatApp());
}

class ChatApp extends StatelessWidget {
  const ChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat Bot',
      home: const ChatScreen(),
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<StatefulWidget> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // Runtime
  final chatBot = ChatBot();
  final List<Message> messages = [
    Message.defaultMessage() // Add the default message at the start of chat.
  ];

  final _textInputController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: messages.length,
                itemBuilder: (_, idx) {
                  return ChatBubble.ofMessage(msg: messages[idx]);
                }),
          ),
          const Divider(height: 1.0),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _textInputController,
                    decoration: InputDecoration(
                      hintText: Texts.typeMessageHere,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                ValueListenableBuilder(
                    valueListenable: _textInputController,
                    builder: (_, value, __) {
                      return CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: IconButton(
                          icon: Icon(value.text.isEmpty ? Icons.mic : Icons.send),
                          onPressed: () async {
                            throw UnimplementedError("handle the send button click.");
                          },
                        ),
                      );
                    }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void askChatBot() async {
    throw UnimplementedError("askChatBot is not yet implemented.");
  }

  void sendMessage(Message message) {
    throw UnimplementedError("sendMessage is not yet implemented.");
  }
}
