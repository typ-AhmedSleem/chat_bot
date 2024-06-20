import 'dart:math';

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
import 'widgets/chat_bubble.dart';
import 'widgets/chatbot_message_bar.dart';

void main() async {
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
    Message.defaultMessage(),
    Message.announcement(content: Texts.chatBotReady),
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
                  final currMsg = messages[idx];
                  bool showTail = true;
                  if (idx + 1 < messages.length) {
                    final nextMsg = messages[idx + 1];
                    showTail = currMsg.isMe != nextMsg.isMe;
                  }
                  // if (currMsg.sender == SenderType.announcement) return ActionAnnouncementBubble(content: currMsg.content);
                  return ChatBubble.ofMessage(msg: currMsg, showTail: showTail);
                }),
          ),
          const Divider(height: 1.0),
          ChatBotMessageBar(
            controller: _textInputController,
            state: _state,
            answerRequest: _currentActionAnswerRequest,
            onVoiceInputPressed: () async {
              return await askChatBot() ?? "";
            },
            onCancelPressed: () {
              cancelCurrentAction();
            },
            onSubmitMessage: (content) async {
              // * Send message
              final message = Message.user(content: content);
              sendMessage(message, doAfterSending: () {
                _state = ChatBotState.thinking;
              });
              // * Identify action
              final action = await identifyAction(content);
              currentAction = action;
              if (action == null) {
                _state = ChatBotState.idle;
                _updateLastMessage(content: Texts.unknownAction);
                return;
              }
              // * ===== Perform the action ===== * //
              if (action is bot_actions.CreateAlarmAction) {
                await performScheduleAlarmAction(content);
              } else if (action is bot_actions.SearchAction) {
                await performSearchAction();
              } else if (action is bot_actions.CreateTaskAction) {
                await performCreateTaskAction();
              } else if (action is bot_actions.ShowAllTasksAction) {
                await performShowAllTasksAction();
              }
            },
            onSubmitAnswerForAction: (rawAnswer) async {
              // * Handle the answer
              sendMessage(Message.user(content: rawAnswer));
              setState(() {
                _currentActionAnswerRequest = null;
                _state = ChatBotState.readyToPerform;
              });
              // * Make a test on just the create alarm action
              if (currentAction != null) {
                if (currentAction is! bot_actions.CreateAlarmAction) {
                  cancelCurrentAction();
                  return true;
                }
                final action = currentAction as bot_actions.CreateAlarmAction;
                if (action.answerRequest?.isAnswerCorrect ?? false) {
                  cancelCurrentAction();
                  return true;
                }
                final scheduled = await chatBot.scheduleAlarm(id: Random().nextInt(1000), timestamp: action.alarmTime, callback: _handleAlarm);
                if (!scheduled) {
                  sendMessage(Message.bot(content: "تعذر انشاء تنبيه كما طلبت."));
                  await finishCurrentAction();
                  return true;
                }
                sendMessage(Message.bot(content: "تم انشاء تنبيه كما طلبت :)"));
                await finishCurrentAction();
              }
              // * Clear the current request
              _currentActionAnswerRequest = null;
              currentAction?.answerRequest = null;
              return true;
            },
          ),
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

  void sendMessage(Message message, {Function? doBeforeSending, Function? doAfterSending}) {
    setState(() {
      if (doBeforeSending != null) doBeforeSending();
      messages.add(message);
      if (message.isMe) _textInputController.clear();
      scrollToLastMessage();
      if (doAfterSending != null) doAfterSending();
    });
  }

  void _updateLastMessage({String? content, bool? isMe, String? timestamp}) {
    try {
      final lastMessage = messages.last;
      if (lastMessage.sender != SenderType.bot) {
        sendMessage(lastMessage.editedClone(content: content, sender: SenderType.bot, timestamp: timestamp));
        return;
      }
      SenderType? sender;
      if (isMe != null) sender = isMe ? SenderType.user : SenderType.bot;
      messages[messages.length - 1] = lastMessage.editedClone(content: content, sender: sender, timestamp: timestamp);
    } catch (_) {
      // NOTHING TO BE DONE HERE
    }
  }

  Future<String?> askChatBot() async {
    if (messages.last.isMe) {
      sendMessage(Message.bot(content: Texts.listening));
    }
    setState(() {
      _state = ChatBotState.listening;
    });
    try {
      final userSpeech = (await chatBot.askChatBot(throws: true))!;
      // Return the recognized speech
      return userSpeech;
    } on PlatformException catch (e) {
      print("askChatBot faced an error: $e");
      final code = int.parse(e.code);
      final error = ChatBotError.getErrorByCode(code);
      if (error != null) {
        _updateLastMessage(content: error.message);
      }
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
    sendMessage(Message.bot(content: Texts.thinking));
    // * Identify action
    await Future.delayed(const Duration(milliseconds: 1000));
    return await chatBot.identifyAction(content);
  }

  void cancelCurrentAction() {
    setState(() {
      sendMessage(Message.bot(content: Texts.cancelled), doBeforeSending: () {
        _state = ChatBotState.idle;
        _textInputController.clear();
        currentAction = null;
        _currentActionAnswerRequest = null;
      }, doAfterSending: () {
        sendMessage(Message.announcement(content: Texts.chatBotReady));
      });
    });
  }

  Future<void> finishCurrentAction() async {
    sendMessage(Message.announcement(content: Texts.chatBotReady), doAfterSending: () {
      setState(() async {
        _state = ChatBotState.idle;
        _textInputController.clear();
        currentAction = null;
        _currentActionAnswerRequest = null;
        await Future.delayed(const Duration(milliseconds: 500));
        sendMessage(Message.bot(content: "هل تريد تنفيذ شئ اخر ؟"));
      });
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

  static void _handleAlarm(int alarmId) {
    // Since we cannot show a dialog directly from a background callback,
    // consider saving the alarm state and showing a dialog when the app is resumed.
    print('Alarm fired! id= $alarmId');
  }

  // * ========== Actions handlers ========== * //
  Future<void> performScheduleAlarmAction(String rawTimestamp) async {
    final action = currentAction as bot_actions.CreateAlarmAction;
    final alarmTimestamp = parseTimestamp(rawTimestamp);
    final formattedAlarmTime = formatTimestamp(alarmTimestamp);
    // * Check the alarm time parsed or not
    if (alarmTimestamp == null) {
      _updateLastMessage(content: Texts.cantDetermineAlarmTime);
      cancelCurrentAction();
      return;
    }
    // * Schedule the alarm
    action.alarmTime = alarmTimestamp;
    _updateLastMessage(content: formattedAlarmTime);
    sendMessage(Message.bot(content: Texts.createAlarmAction), doAfterSending: () {
      // * Ask user for his answer
      _state = ChatBotState.waitingForUserInput;
      _currentActionAnswerRequest = ActionAnswerRequest(hintMessageBar: Texts.yesOrNo, expectedAnswer: Texts.answerYes);
    });
  }

  Future<void> performSearchAction() async {
    // * Ask user for image uploading
    final imagePath = await chatBot.pickImageFromGallery();
    // * Validate and preprocess the uploaded image
    // * Send message in chat screen
    // * Prepare api call to the target endpoint
    // * Handle api call response and update UI

    finishCurrentAction();
  }

  Future<void> performCreateTaskAction() async {
    // * Ask user for the title of the task
    // * Validate the task title
    // * Save the task in the database
    finishCurrentAction();
  }

  Future<void> performShowAllTasksAction() async {
    // * Query database for tasks created today
    // * Represent the returned tasks list as String
    // * Display the tasks in a message
    finishCurrentAction();
  }
}
