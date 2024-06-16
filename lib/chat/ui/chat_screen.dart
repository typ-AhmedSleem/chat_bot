import 'package:chat_bot/actions/actions.dart' as actions;
import 'package:chat_bot/chat/utils/chatbot_state.dart';
import 'package:chat_bot/chat_bot.dart';
import 'package:chat_bot/chat_bot_errors.dart';
import 'package:chat_bot/helpers/datetime_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../helpers/texts.dart';
import '../../helpers/utils.dart';
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
  // Runtime
  final chatBot = ChatBot();
  final List<Message> messages = [
    Message.defaultMessage(), // Add the default message at the start of chat.
  ];
  ChatBotState state = ChatBotState.idle;

  // UI controllers
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
                        backgroundColor: state == ChatBotState.idle ? Colors.blue : Colors.red,
                        child: IconButton(
                          icon: Icon(
                            color: Colors.white,
                            state == ChatBotState.idle
                                ? value.text.isEmpty
                                    ? Icons.mic
                                    : Icons.send
                                : Icons.stop,
                          ),
                          onPressed: () async {
                            // * First, check current ChatBot state
                            if (state != ChatBotState.idle) {
                              setState(() {
                                state = ChatBotState.idle;
                                _textInputController.clear();
                                _updateLastMessage(content: Texts.cancelled);
                              });
                              return;
                            }
                            // * Get current typed text
                            String content = value.text;
                            if (content.isEmpty) {
                              // * Start voice input
                              content = await askChatBot() ?? "";
                              return;
                            }
                            // * Send message
                            final message = Message(content: content, isMe: true, timestamp: nowFormatted());
                            sendMessage(message);

                            // * Make ChatBot identify action
                            final action = await identifyAction(content);
                            chatBot.logger.log(action.toString());
                            setState(() {
                              _updateLastMessage(content: action?.title ?? Texts.unknownAction);
                            });

                            if (action == null) {
                              // Unknown action, reset runtime and
                              setState(() {
                                state = ChatBotState.idle;
                              });
                              return;
                            }

                            // todo: * Continue on performing the identified action
                            setState(() {
                              state = ChatBotState.readyToPerform;
                            });
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

  void sendMessage(Message message) {
    setState(() {
      messages.add(message);
      if (message.isMe) {
        _textInputController.clear(); // Clear input field if msg from user.
      }
    });
  }

  void _updateLastMessage({String? content, bool? isMe, String? timestamp}) {
    try {
      final lastMessage = messages.last;
      if (lastMessage.isMe) return;
      messages[messages.length - 1] = lastMessage.editedClone(content: content, isMe: isMe, timestamp: timestamp);
    } catch (_) {
      // NOTHING TO BE DONE HERE
    }
  }

  Future<String?> askChatBot() async {
    state = ChatBotState.listening;
    try {
      final userSpeech = (await chatBot.askChatBot(throws: true))!!;
      if (userSpeech.isEmpty) {
        // No speech was recognized
        state = ChatBotState.idle;
        showToast(Texts.errorNoSpeechWasRecognized);
        return null;
      }
      // Speech is recognized
      setState(() {
        // Show the recognized speech in the input field
        _textInputController.text = userSpeech;
      });

      // Return the recognized speech
      state = ChatBotState.idle;
      return userSpeech;
    } on PlatformException catch (e) {
      state = ChatBotState.idle;
      final code = int.parse(e.code);
      final error = ChatBotError.getErrorByCode(code);
      if (error != null) showToast(error.message);
      return null;
    }
  }

  Future<actions.Action?> identifyAction(String content) async {
    // * Show chat bot is thinking
    state = ChatBotState.thinking;
    await Future.delayed(const Duration(milliseconds: 250));
    sendMessage(Message(content: Texts.thinking, isMe: false, timestamp: nowFormatted()));
    // * Identify action
    await Future.delayed(const Duration(milliseconds: 1500));
    return await chatBot.identifyAction(content);
  }
}
