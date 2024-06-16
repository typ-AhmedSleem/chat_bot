import 'package:chat_bot/actions/action_answer.dart';
import 'package:chat_bot/actions/actions.dart' as bot_actions;
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
import 'widgets/chatbot_message_bar.dart';

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
  bot_actions.Action? currentAction;
  ActionAnswerRequest? _currentActionAnswerRequest;
  final chatBot = ChatBot();
  final List<Message> messages = [
    Message.defaultMessage(), // Add the default message at the start of chat.
  ];
  ChatBotState _state = ChatBotState.idle;

  get isIdleOrWaitingInput => (_state == ChatBotState.idle || _state == ChatBotState.waitingForUserInput);

  // UI controllers
  final _textInputController = TextEditingController();
  final _listScrollController = ScrollController();

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
                controller: _listScrollController,
                itemBuilder: (_, idx) {
                  bool showTail = true;
                  if (idx + 1 < messages.length) {
                    final currMsg = messages[idx];
                    final nextMsg = messages[idx + 1];
                    showTail = currMsg.isMe != nextMsg.isMe;
                  }
                  return ChatBubble.ofMessage(msg: messages[idx], showTail: showTail);
                }),
          ),
          const Divider(height: 1.0),
          ChatBotMessageBar(
            controller: _textInputController,
            state: _state,
            answerRequest: _currentActionAnswerRequest,
            onVoiceInputPressed: () async {
              final speech = await askChatBot() ?? "";
              if (speech.isEmpty) {
                showToast(Texts.errorNoSpeechWasRecognized);
                return "";
              }
              return speech;
            },
            onCancelPressed: () {
              cancelCurrentAction();
            },
            onSubmitMessage: (content) async {
              // * Send message
              final message = Message.user(content: content);
              sendMessage(message, doBeforeSending: () {
                _state = ChatBotState.thinking;
              });
              // * Make ChatBot identify action
              final action = await identifyAction(content);
              chatBot.logger.log(action.toString());
              setState(() {
                if (action == null) {
                  _state = ChatBotState.idle;
                  sendMessage(Message.bot(content: Texts.unknownAction));
                  return;
                }
                _updateLastMessage(content: action.title);
                setState(() {
                  currentAction = action;
                  _state = ChatBotState.waitingForUserInput;
                  _currentActionAnswerRequest = ActionAnswerRequest.raw(hintMessageBar: "نعم او لا...");
                });
              });
            },
            onSubmitAnswerForAction: (answer) async {
              if (answer.type == AnswerType.raw) {
                // Only raw text answer, always return true to clear the message bar
                final rawAnswer = answer.answer as String;
                // todo: Handle the raw answer
                sendMessage(Message.user(content: rawAnswer));
                setState(() {
                  _currentActionAnswerRequest = null;
                  _state = ChatBotState.readyToPerform;
                });
                // * Make a test on just the create alarm action
                if (currentAction != null) {
                  if (currentAction is! bot_actions.CreateAlarmAction) cancelCurrentAction();
                  sendMessage(Message.bot(content: "تم انشاء تنبيه كما طلبت :)"));
                  await finishCurrentAction();
                }
                return true;
              }

              if (answer.type == AnswerType.choice) {
                // todo: Handle the selected choice answer
                // todo: Perform the desired operation based on selected choice
              }
              return true;
            },
          ),
          //       onPressed: () async {
          //         // * Check current ChatBot state
          //         if (state == ChatBotState.waitingForUserInput) {
          //           // Grab the current input as its needed for action being executed
          //           grabInputForCurrentExecutingAction(value.text.trim());
          //           return;
          //         }
          //         if (state != ChatBotState.idle) {
          //           cancelCurrentAction();
          //           return;
          //         }
          //         // * Get current typed text
          //         String content = value.text.trim();
          //         if (content.isEmpty) {
          //           // * Start voice input
          //           content = await askChatBot() ?? "";
          //           return;
          //         }
          //         // * Send message
          //         final message = Message(content: content, isMe: true, timestamp: nowFormatted());
          //         sendMessage(message);
          //
          //         // * Make ChatBot identify action
          //         final action = await identifyAction(content);
          //         chatBot.logger.log(action.toString());
          //         setState(() {
          //           _updateLastMessage(content: action?.title ?? Texts.unknownAction);
          //         });
          //
          //         if (action == null) {
          //           // Unknown action, reset runtime and
          //           setState(() {
          //             state = ChatBotState.idle;
          //           });
          //           return;
          //         }
          //
          //         // todo: * Continue on performing the identified action
          //         setState(() {
          //           state = ChatBotState.waitingForUserInput;
          //         });
          //       },
          //     ),
          //   );
          // }),
        ],
      ),
    );
  }

  void scrollToLastMessage() {
    _listScrollController.animateTo(
      _listScrollController.positions.last.extentTotal,
      duration: const Duration(milliseconds: 500),
      curve: Curves.fastOutSlowIn,
    );
  }

  void sendMessage(Message message, {Function? doBeforeSending}) {
    setState(() {
      if (doBeforeSending != null) doBeforeSending!();
      messages.add(message);
      if (message.isMe) {
        _textInputController.clear(); // Clear input field if msg from user.
      }
      scrollToLastMessage();
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
    setState(() {
      _state = ChatBotState.listening;
    });
    try {
      final userSpeech = (await chatBot.askChatBot(throws: true))!!;
      if (userSpeech.isEmpty) {
        // No speech was recognized
        showToast(Texts.errorNoSpeechWasRecognized);
        return null;
      }
      // Return the recognized speech
      return userSpeech;
    } on PlatformException catch (e) {
      final code = int.parse(e.code);
      final error = ChatBotError.getErrorByCode(code);
      if (error != null) showToast(error.message);
      return null;
    } finally {
      setState(() {
        if (_currentActionAnswerRequest != null) {
          _state = ChatBotState.waitingForUserInput;
          return;
        }
        _state = ChatBotState.idle;
      });
    }
  }

  Future<bot_actions.Action?> identifyAction(String content) async {
    // * Show chat bot is thinking
    _state = ChatBotState.thinking;
    await Future.delayed(const Duration(milliseconds: 250));
    sendMessage(Message(content: Texts.thinking, isMe: false, timestamp: nowFormatted()));
    // * Identify action
    await Future.delayed(const Duration(milliseconds: 1500));
    return await chatBot.identifyAction(content);
  }

  void cancelCurrentAction() {
    setState(() {
      _state = ChatBotState.idle;
      _textInputController.clear();
      currentAction = null;
      _currentActionAnswerRequest = null;
      sendMessage(Message.bot(content: Texts.cancelled));
      // todo: add small centered message showing that this current action life has ended
    });
  }

  Future<void> finishCurrentAction() async {
    await Future.delayed(const Duration(seconds: 1));
    sendMessage(Message.bot(content: "هل تريد تنفيذ شئ اخر ؟"));
    setState(() {
      _state = ChatBotState.idle;
      _textInputController.clear();
      currentAction = null;
      _currentActionAnswerRequest = null;
      // todo: add small centered message showing that this current action life has ended
    });
  }

  void grabInputForCurrentExecutingAction(String typedContent) async {
    if (typedContent.isNotEmpty) {
      // Use the typed content
      return;
    }
    final content = await askChatBot() ?? "";
    if (content.isEmpty) {
      showToast(Texts.chatBotNeedsYourAnswer);
      return;
    }

    setState(() {
      // todo: * Associate the response with the provided answer
      _state = ChatBotState.performingAction;
    });
  }
}
