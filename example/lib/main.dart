import 'package:chat_bot_example/logger.dart';
import 'package:flutter/material.dart';

import 'package:chat_bot/chat_bot.dart';
import 'package:chat_bot/api/chat_bot_api.dart' as api;

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
  final auth = api.Auth();
  final logger = Logger("ChatBotExample");
  bool listening = false;
  String userSpeech = "Ask ChatBot";

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
            child: Column(
          children: [
            FilledButton(
                onPressed: () async {
                  // Ask ChatBot and wait for speech
                  userSpeech =
                      await chatBot.askChatBot() ?? " <<<NO-SPEECH-RETURNED>>>";
                  logger.log(userSpeech);
                  setState(() {});
                },
                child: Text(listening ? "Listening" : userSpeech)),
            FilledButton(
                onPressed: () async {
                  logger.log(
                      "API::register => ${(await auth.register("Ahmed Sleem", "typ", "typahmedsleem@gmail.com", "1234567890", "role", "010", 23))}");
                },
                child: const Text("API.register")),
            FilledButton(
                onPressed: () async {
                  logger.log(
                      "API::login => ${(await auth.login("Ahmed Sleem", "typ"))}");
                },
                child: const Text("API.login")),
            FilledButton(
                onPressed: () async {
                  // logger.log("API::confirm => ${(await auth.confirm("Ahmed Sleem", "typ"))}");
                },
                child: const Text("API.confirm (not ready)")),
            FilledButton(
                onPressed: () async {
                  logger.log(
                      "API::resetPassword => ${(await auth.resetPassword("Ahmed Sleem", "typ", "typahmedsleem@gmail.com", "1234567890"))}");
                },
                child: const Text("API.resetPassword")),
            FilledButton(
                onPressed: () async {
                  // logger.log("API::forgetPassword => ${(await auth.forgetPassword("Ahmed Sleem"))}");
                },
                child: const Text("API.forgetPassword (not ready)")),
            FilledButton(
                onPressed: () async {
                  logger.log(
                      "API::changePassword => ${(await auth.changePassword("Ahmed Sleem", "typ", "typahmedsleem@gmail.com", "1234567890"))}");
                },
                child: const Text("API.changePassword"))
          ],
        )),
      ),
    );
  }
}
