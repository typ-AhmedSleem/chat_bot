import 'package:chat_bot/actions/action_answer.dart';
import 'package:chat_bot/chat/utils/chatbot_state.dart';
import 'package:chat_bot/helpers/texts.dart';
import 'package:flutter/material.dart';

class ChatBotMessageBar extends StatelessWidget {
  final TextEditingController controller;
  ChatBotState state;
  final Future<String> Function() onVoiceInputPressed;
  final Function onCancelPressed;
  final Function(String) onSubmitMessage;
  final Future<bool> Function(String) onSubmitAnswerForAction;
  ActionAnswerRequest? answerRequest;

  ChatBotMessageBar(
      {super.key,
      required this.controller,
      required this.state,
      required this.onVoiceInputPressed,
      required this.onCancelPressed,
      required this.onSubmitMessage,
      required this.onSubmitAnswerForAction,
      this.answerRequest});

  get inputHasContent => (controller.text.isNotEmpty);

  get isIdleOrWaitingInput => (state == ChatBotState.idle || state == ChatBotState.waitingForUserInput);

  get isPerformingAction => ([ChatBotState.thinking, ChatBotState.readyToPerform, ChatBotState.performingAction].contains(state));

  get hasAnswerRequest => (null != answerRequest);

  get shouldMakeInputEnabled {
    if (state == ChatBotState.idle) return true;
    if (state == ChatBotState.waitingForUserInput && hasAnswerRequest) return true;
    return false;
  }

  IconData getIconByState() {
    if (isPerformingAction) return Icons.stop;
    if (isIdleOrWaitingInput && inputHasContent) return Icons.send;
    return Icons.mic;
  }

  Color getActionButtonBgColor() {
    if (isIdleOrWaitingInput) {
      if (state == ChatBotState.waitingForUserInput) return Colors.green;
      return Colors.blue;
    }
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: SizedBox(
              height: 50,
              child: TextField(
                controller: controller,
                maxLines: 1,
                enabled: isIdleOrWaitingInput,
                decoration: InputDecoration(
                  hintText: hasAnswerRequest ? answerRequest!.hintMessageBar : Texts.typeMessageHere,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10.0),
          ValueListenableBuilder(
              valueListenable: controller,
              builder: (_, value, __) {
                return CircleAvatar(
                  backgroundColor: getActionButtonBgColor(),
                  child: IconButton(
                    icon: Icon(
                      size: 18,
                      color: Colors.white,
                      getIconByState(),
                    ),
                    onPressed: () async {
                      // * Check if idle or waiting for input
                      if (isIdleOrWaitingInput) {
                        String content = controller.text.trim();
                        if (content.isEmpty) {
                          // * Start voice input
                          final speech = await onVoiceInputPressed();
                          controller.text = speech;
                        } else {
                          // * Check if chatbot is waiting for raw input
                          if (state == ChatBotState.waitingForUserInput) {
                            if (!hasAnswerRequest) return;
                            // * Handle the action answer request
                            final handled = await onSubmitAnswerForAction(content);
                            if (handled) {
                              controller.clear();
                              answerRequest = null;
                            }
                            return;
                          }
                          // * Send message content as normal message
                          onSubmitMessage(content);
                          controller.clear();
                        }
                        return;
                      }
                      // * Check if action is to cancel the action
                      if (isPerformingAction) onCancelPressed();
                    },
                  ),
                );
              }),
        ],
      ),
    );
  }
}
