import 'package:chat_bot/actions/actions.dart';
import 'package:chat_bot/helpers/datetime_helper.dart';
import 'package:flutter/material.dart';

import '../../helpers/utils.dart';
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
        title: const Text('ChatBot'),
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
                            String content = value.text;
                            if (content.isEmpty) {
                              // * Start voice input
                              final userSpeech = await chatBot.askChatBot() ?? "";
                              if (userSpeech.isEmpty) {
                                // No speech was recognized
                                showToast(Texts.noSpeechWasRecognized);
                                return;
                              }
                              // Speech is recognized
                              setState(() {
                                // Show the recognized speech in the input field
                                content = userSpeech;
                                _textInputController.text = content;
                              });
                              return;
                            }
                            // * Send message
                            final message = Message(content: content, isMe: true, timestamp: nowFormatted());
                            sendMessage(message);

                            // * Make ChatBot identify action
                            final identified = await identifyAction(content);

                            // todo * Update state for runtime and UI
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

  Future<bool> identifyAction(String content) async {
    // * Show chat bot is thinking
    await Future.delayed(const Duration(milliseconds: 250));
    sendMessage(Message(content: "Thinking...", isMe: false, timestamp: nowFormatted()));
    // * Identify action
    await Future.delayed(const Duration(milliseconds: 1500));
    final action = await chatBot.identifyAction(content);
    _updateLastMessage(content: action?.name ?? "Can't identify action");

    return action != null;
  }

  void _updateLastMessage({String? content, bool? isMe, String? timestamp}) {
    try {
      final lastMessage = messages.last;
      messages[messages.length - 1] = lastMessage.editedClone(content: content, isMe: isMe, timestamp: timestamp);
    } catch (_) {
      // NOTHING TO BE DONE HERE
    }
  }

  void askChatBot() async {
    throw UnimplementedError("askChatBot is not yet implemented.");
  }

  void sendMessage(Message message) {
    setState(() {
      messages.add(message);
      if (message.isMe) _textInputController.clear(); // Clear input field if msg from user.
    });
  }
}
