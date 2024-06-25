import 'dart:math';

import 'package:chat_bot/actions/action_answer.dart';
import 'package:chat_bot/actions/actions.dart' as bot_actions;
import 'package:chat_bot/api/chat_bot_api.dart';
import 'package:chat_bot/api/models/appointment.dart';
import 'package:chat_bot/api/models/media.dart';
import 'package:chat_bot/api/models/medicine.dart';
import 'package:chat_bot/api/models/patient_related_member.dart';
import 'package:chat_bot/api/models/recognized_person.dart';
import 'package:chat_bot/api/models/secret_file.dart';
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

class ChatScreen extends StatefulWidget {
  late final ChatBot _chatBot;

  ChatScreen({super.key, required String token}) {
    _chatBot = ChatBot(token: token);
  }

  ChatBot get chatBot => _chatBot;

  @override
  State<StatefulWidget> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // Runtime
  bot_actions.Action? currentAction;
  ActionAnswerRequest? _currentActionAnswerRequest;
  final List<Message> messages = [
    Message.defaultMessage(),
  ];
  ChatBotState _state = ChatBotState.idle;

  get isIdleOrWaitingInput => (_state == ChatBotState.idle || _state == ChatBotState.waitingForUserInput);

  // UI controllers
  final _textInputController = TextEditingController();
  final _listScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _performAPITest();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Center(
          child: Text('Chatbot'),
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 15),
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
                final scheduled = await widget.chatBot.scheduleAlarm(id: Random().nextInt(1000), timestamp: action.alarmTime);
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

  Future<void> sendMessage(Message message, {Function? doBeforeSending, Function? doAfterSending}) async {
    if (doBeforeSending != null) await doBeforeSending();
    setState(() {
      messages.add(message);
      if (message.isMe) _textInputController.clear();
      scrollToLastMessage();
    });
    if (doAfterSending != null) {
      await doAfterSending();
      setState(() {});
    }
  }

  void _updateLastMessage({String? content, bool? isMe, String? timestamp}) {
    try {
      final lastMessage = messages.last;
      if (lastMessage.sender != SenderType.bot) {
        sendMessage(Message.bot(content: content ?? lastMessage.content));
        return;
      }
      setState(() {
        SenderType? sender;
        if (isMe != null) sender = isMe ? SenderType.user : SenderType.bot;
        messages[messages.length - 1] = lastMessage.editedClone(content: content, sender: sender, timestamp: timestamp);
      });
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
      final userSpeech = (await widget.chatBot.askChatBot(throws: true))!;
      // Return the recognized speech
      return userSpeech;
    } on PlatformException catch (e) {
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
    return await widget.chatBot.identifyAction(content);
  }

  void cancelCurrentAction({bool reportWithMessage = true}) {
    setState(() {
      _state = ChatBotState.idle;
      _textInputController.clear();
      currentAction = null;
      _currentActionAnswerRequest = null;
    });
    if (reportWithMessage) sendMessage(Message.bot(content: Texts.cancelled));
    sendMessage(Message.announcement(content: Texts.chatBotReady));
  }

  Future<void> finishCurrentAction({Duration delay = const Duration(milliseconds: 500)}) async {
    sendMessage(Message.announcement(content: Texts.chatBotReady), doBeforeSending: () async {
      setState(() {
        _state = ChatBotState.idle;
        _textInputController.clear();
        currentAction = null;
        _currentActionAnswerRequest = null;
      });
    }, doAfterSending: () async {
      await Future.delayed(delay);
      await sendMessage(Message.bot(content: "هل تريد تنفيذ شئ اخر ؟"));
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
    try {
      // * Ask user for image uploading
      _updateLastMessage(content: Texts.uploadPictureToSearch);
      final String? imagePath = await widget.chatBot.pickImageFromGallery();
      // * Validate the image
      if (imagePath == null) throw CBError(message: "Image picker returned a null path.");
      if (imagePath.isEmpty) throw CBError(message: "Image picker returned an empty path.");
      // * Send message in chat screen
      await sendMessage(Message.image(path: imagePath), doBeforeSending: () {
        // Update the last message content
        _updateLastMessage(content: Texts.uploadPictureToSearch);
      });
      await Future.delayed(const Duration(milliseconds: 250));
      _updateLastMessage(content: Texts.imageAccepted);

      // * Do some fancy UI updates
      await sendMessage(Message.bot(content: Texts.uploadingImage), doAfterSending: () async {
        await Future.delayed(const Duration(milliseconds: 250));
      });

      // * Send the api call
      final recognizedFaces = await widget.chatBot.api.recognizeFaces(imagePath);

      // * Handle recognized persons
      if (recognizedFaces.isEmpty) throw CBError(message: Texts.cantRecognizeFaces);
      await sendMessage(Message.bot(content: Texts.facesRecognized));
      for (RecognizedPerson person in recognizedFaces) {
        sendMessage(Message.api(payload: person));
      }

      // * Finish the current action
      finishCurrentAction(delay: const Duration(seconds: 1));
    } on ChatBotError catch (cbe) {
      await sendMessage(Message.bot(content: cbe.message), doAfterSending: () {
        cancelCurrentAction(reportWithMessage: false);
      });
    } catch (e) {
      await sendMessage(Message.bot(content: Texts.errorOccurredWhileDoingAction), doAfterSending: () {
        cancelCurrentAction(reportWithMessage: false);
      });
    }
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

  Future<void> _performAPITest() async {
    await sendMessage(Message.user(content: "Test APIs"), doBeforeSending: () async {
      await Future.delayed(const Duration(seconds: 1));
    }, doAfterSending: () async {
      await Future.delayed(const Duration(seconds: 1));
    });
    await sendMessage(Message.bot(content: "Start testing of APIs..."), doAfterSending: () async {
      await Future.delayed(const Duration(seconds: 1));
    });
    await sendMessage(Message.user(content: "Test:  [searchForSomeone]"));
    await performSearchAction();
    // Region: Start of APIs test

    // * getPatientProfile
    await sendMessage(Message.user(content: "Test:  [getPatientProfile]"));
    await ApiRunner.run(
        name: "getPatientProfile",
        runner: widget.chatBot.api.getPatientProfile,
        onSuccess: (profile) async {
          await sendMessage(Message.api(payload: profile));
        },
        onFail: (error) async {
          await sendMessage(Message.bot(content: error.message));
        });
    await sendMessage(Message.announcement(content: "Finished testing [getPatientProfile]"));
    await Future.delayed(const Duration(seconds: 1));

    // * getPatientRelatedMembers
    await sendMessage(Message.user(content: "Test:  [getPatientRelatedMembers]"));
    await ApiRunner.run(
        name: "getPatientRelatedMembers",
        runner: widget.chatBot.api.getPatientRelatedMembers,
        onSuccess: (members) async {
          for (PatientRelatedMember member in members) {
            await sendMessage(Message.api(payload: member));
          }
        },
        onFail: (error) async {
          await sendMessage(Message.bot(content: error.message));
        });
    await sendMessage(Message.announcement(content: "Finished testing [getPatientRelatedMembers]"));
    await Future.delayed(const Duration(seconds: 1));

    // * updatePatientProfile
    await sendMessage(Message.user(content: "Test:  [updatePatientProfile]"));
    await ApiRunner.run(
        name: "updatePatientProfile",
        runner: () => widget.chatBot.api.updatePatientProfile("123", 23, "29/6/2024", 123),
        onSuccess: (response) async => await sendMessage(Message.bot(content: response)),
        onFail: (error) async => await sendMessage(Message.bot(content: error.message)));
    await sendMessage(Message.announcement(content: "Finished testing [updatePatientProfile]"));
    await Future.delayed(const Duration(seconds: 1));

    // * getFamilyLocation
    await sendMessage(Message.user(content: "Test:  [getFamilyLocation]"));
    await ApiRunner.run(
        name: "getFamilyLocation",
        runner: () async => await widget.chatBot.api.getFamilyLocation("12323"),
        onSuccess: (location) async => await sendMessage(Message.api(payload: location)),
        onFail: (error) async => await sendMessage(Message.bot(content: error.message)));
    await sendMessage(Message.announcement(content: "Finished testing [getFamilyLocation]"));
    await Future.delayed(const Duration(seconds: 1));

    // * markMedicationReminder
    await sendMessage(Message.user(content: "Test:  [markMedicationReminder]"));
    await ApiRunner.run(
        name: "markMedicationReminder",
        runner: () => widget.chatBot.api.markMedicationReminder("m", true),
        onSuccess: (response) async => await sendMessage(Message.bot(content: response)),
        onFail: (error) async => await sendMessage(Message.bot(content: error.message)));
    await sendMessage(Message.announcement(content: "Finished testing [markMedicationReminder]"));
    await Future.delayed(const Duration(seconds: 1));

    // * askToSeeSecretFile
    await sendMessage(Message.user(content: "Test:  [askToSeeSecretFile]"));
    await ApiRunner.run(
        name: "askToSeeSecretFile",
        runner: () async => widget.chatBot.api.askToSeeSecretFile(videoPath: await widget.chatBot.pickVideoFromGallery() ?? ""),
        onSuccess: (response) async => await sendMessage(Message.bot(content: response)),
        onFail: (error) async => await sendMessage(Message.bot(content: error.message)));
    await sendMessage(Message.announcement(content: "Finished testing [askToSeeSecretFile]"));
    await Future.delayed(const Duration(seconds: 1));

    // * addGameScore
    await sendMessage(Message.user(content: "Test:  [addGameScore]"));
    await ApiRunner.run(
        name: "addGameScore",
        runner: () async => widget.chatBot.api.addGameScore(5, 2),
        onSuccess: (response) async => await sendMessage(Message.bot(content: response)),
        onFail: (error) async => await sendMessage(Message.bot(content: error.message)));
    await sendMessage(Message.announcement(content: "Finished testing [addGameScore]"));
    await Future.delayed(const Duration(seconds: 1));
    //
    // * getSecretFile
    await sendMessage(Message.user(content: "Test:  [getSecretFile]"));
    await ApiRunner.run(
        name: "getSecretFile",
        runner: widget.chatBot.api.getSecretFile,
        onFail: (error) async => await sendMessage(Message.bot(content: error.message)),
        onSuccess: (files) async {
          for (SecretFile file in files) {
            await sendMessage(Message.api(payload: file));
          }
        });
    await sendMessage(Message.announcement(content: "Finished testing [getSecretFile]"));
    await Future.delayed(const Duration(seconds: 1));

    // * getAllAppointments
    await sendMessage(Message.user(content: "Test:  [getAllAppointments]"));
    await ApiRunner.run(
        name: "getAllAppointments",
        runner: widget.chatBot.api.getAllAppointments,
        onFail: (error) async => await sendMessage(Message.bot(content: error.message)),
        onSuccess: (appointments) async {
          for (Appointment appointment in appointments) {
            await sendMessage(Message.api(payload: appointment));
          }
        });
    await sendMessage(Message.announcement(content: "Finished testing [getAllAppointments]"));
    await Future.delayed(const Duration(seconds: 1));

    // * getAllMedicines
    await sendMessage(Message.user(content: "Test:  [getAllMedicines]"));
    await ApiRunner.run(
        name: "getAllMedicines",
        runner: widget.chatBot.api.getAllMedicines,
        onFail: (error) async => await sendMessage(Message.bot(content: error.message)),
        onSuccess: (medicines) async {
          for (Medicine medicine in medicines) {
            await sendMessage(Message.api(payload: medicine));
          }
        });
    await sendMessage(Message.announcement(content: "Finished testing [getAllMedicines]"));
    await Future.delayed(const Duration(seconds: 1));

    // * getMedia
    await sendMessage(Message.user(content: "Test:  [getMedia]"));
    await ApiRunner.run(
        name: "getMedia",
        runner: widget.chatBot.api.getMedia,
        onFail: (error) async => await sendMessage(Message.bot(content: error.message)),
        onSuccess: (mediaFiles) async {
          for (Media media in mediaFiles) {
            await sendMessage(Message.api(payload: media));
          }
        });
    await sendMessage(Message.announcement(content: "Finished testing [getMedia]"));
    await Future.delayed(const Duration(seconds: 1));

    // * getAllGameScores
    // await sendMessage(Message.user(content: "Test:  [getAllGameScores]"));
    // await ApiRunner.run(
    //     name: "getAllGameScores",
    //     runner: widget.chatBot.api.getAllGameScores,
    //     onSuccess: (response) async => await sendMessage(Message.bot(content: response.toString())),
    //     onFail: (error) async => await sendMessage(Message.bot(content: error.message)));
    // await sendMessage(Message.announcement(content: "Finished testing [getAllGameScores]"));
    // await Future.delayed(const Duration(seconds: 1));

    // * getCurrentAndMaxScore
    await sendMessage(Message.user(content: "Test:  [getCurrentAndMaxScore]"));
    await ApiRunner.run(
        name: "getCurrentAndMaxScore",
        runner: widget.chatBot.api.getCurrentAndMaxScore,
        onSuccess: (data) async => await sendMessage(Message.api(payload: data)),
        onFail: (error) async => await sendMessage(Message.bot(content: error.message)));
    await sendMessage(Message.announcement(content: "Finished testing [getCurrentAndMaxScore]"));
    await Future.delayed(const Duration(seconds: 1));
    // Region: End of APIs test
    finishCurrentAction();
  }
}
