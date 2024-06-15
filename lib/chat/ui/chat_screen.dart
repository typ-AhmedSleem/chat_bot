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
  final List<Message> messages = [];
  final chatBot = ChatBot();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView(
              children: [ChatBubble.ofMessage(Message.defaultMessage())],
            ),
            // child: ListView.builder(
            //     padding: const EdgeInsets.all(8.0),
            //     itemBuilder: (_, idx) {
            //       return ChatBubble(msg: messages[idx]);
            //     }),
          ),
          const Divider(height: 1.0),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: Texts.typeMessageHere,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                    // onChanged: (msg) {
                    //   message = msg;
                    // },
                  ),
                ),
                const SizedBox(width: 8.0),
                CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () async {
                      throw UnimplementedError("Not yet implemented.");
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void askChatBot() async {}

  void sendMessage(Message message) {
    throw UnimplementedError("sendMessage is not yet implemented.");
  }
}
