import 'package:flutter/material.dart';

import '../models/message.dart';
import 'chat_bubble.dart';

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
  String? message;
  final List<Message> messages = [];

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
              children: [
                ChatBubble.botBubble(content: "Hi how can i help?", timestamp: "12:15 am"),
                ChatBubble.userBubble(content: "Search for Ahmed", timestamp: "12:17 am"),
                ChatBubble.botBubble(content: "Okay! Searching for 'Ahmed'...", timestamp: "12:19 am"),
                ChatBubble.botBubble(content: "[INFO ABOUT 'Ahmed']", timestamp: "12:22 am"),
              ],
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
                      hintText: 'Type message here...',
                      suffixIcon: const Icon(Icons.mic),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                    onChanged: (msg) {
                      message = msg;
                    },
                  ),
                ),
                const SizedBox(width: 8.0),
                CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      askChatBot(message);
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

  void askChatBot(String? message) {
    // todo: build message model
    // todo: update ui
    // todo: send message to chat bot native side
    throw UnimplementedError("askChatBot is not yet implemented.");
  }
}
