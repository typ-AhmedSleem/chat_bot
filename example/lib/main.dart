import 'package:chat_bot_example/logger.dart';
import 'package:flutter/material.dart';

import 'package:chat_bot/chat_bot.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  final chatBot = ChatBot();
  final logger = Logger("ChatBotExample");

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: FilledButton(onPressed: () async {
            // Ask ChatBot and wait for speech
          String speech = await chatBot.askChatBot() ?? " <<<NO-SPEECH-RETURNED>>>";
          logger.log(speech);
          }, child: const Text("Ask ChatBot"))
        ),
      ),
    );
  }
}
