import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:chat_bot/chat/ui/chat_screen.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the alarm manager
  await AndroidAlarmManager.initialize();
  runApp(const ChatApp());
}

// class MyApp extends StatefulWidget {
//   const MyApp({super.key});
//
//   @override
//   State<MyApp> createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   final chatBot = ChatBot();
//   final logger = Logger("ChatBotExample");
//
//   // Test runtime
//   bool listening = false;
//   String userSpeech = "";
//   String prompt = "What do you want..?";
//   String buttonStatus = "Ask ChatBot";
//
//   @override
//   void initState() {
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: const Text('ChatBot'),
//         ),
//         body: Center(
//             child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Padding(
//                 padding: const EdgeInsets.only(top: 0, bottom: 50),
//                 child: Text(
//                   prompt,
//                   style: const TextStyle(fontSize: 18),
//                 )),
//             // Ask ChatBot button
//             FilledButton(
//                 onPressed: () async {
//                   // if (listening) return;
//                   // // * Ask ChatBot and wait for speech
//                   // try {
//                   //   setState(() {
//                   //     listening = true;
//                   //     prompt = "Listening...";
//                   //   });
//                   //   userSpeech = await chatBot.askChatBot() ?? "";
//                   //   if (userSpeech.isEmpty) throw Exception("User speech can't be empty.");
//                   // } on PlatformException catch (e) {
//                   //   setState(() {
//                   //     prompt = e.message ?? "ChatBot can't listen to your speech. Try again.";
//                   //     buttonStatus = "code: ${e.code}";
//                   //     listening = false;
//                   //   });
//                   //   await Future.delayed(const Duration(seconds: 3));
//                   //   setState(() {
//                   //     buttonStatus = "Ask ChatBot";
//                   //     prompt = "What do you want..?";
//                   //     listening = false;
//                   //   });
//                   //   return;
//                   // }
//                   // // * Show what user just said and wait for 3 seconds
//                   // setState(() {
//                   //   prompt = "You said: '$userSpeech'";
//                   //   buttonStatus = "Identifying action...";
//                   // });
//                   // await Future.delayed(const Duration(seconds: 3));
//                   //
//                   // // * Identify action
//                   // try {
//                   //   final action = await chatBot.identifyAction(userSpeech);
//                   //   if (action == null) throw Exception("Action is null.");
//                   //
//                   //   setState(() {
//                   //     buttonStatus = "Performing...";
//                   //     prompt = "Performing action: ${action.methodName}";
//                   //   });
//                   //   await Future.delayed(const Duration(seconds: 2));
//                   //
//                   //   // * Perform action
//                   //   if (action is CreateAlarmAction) {
//                   //     // * Create alarm
//                   //     bool scheduled = await chatBot.performAction(action, ["08:15"]);
//                   //     setState(() {
//                   //       if (scheduled) {
//                   //         prompt = "Scheduled alarm successfully.";
//                   //       } else {
//                   //         prompt = "Can't schedule alarm at given time.";
//                   //       }
//                   //     });
//                   //   } else if (action is SearchAction) {
//                   //     await chatBot.performAction(action);
//                   //     // * Ask user what to search for
//                   //     setState(() {
//                   //       buttonStatus = "Searching...";
//                   //       prompt = "What do you want to search for ?";
//                   //     });
//                   //     await Future.delayed(const Duration(seconds: 1));
//                   //     String target = await chatBot.askChatBot(throws: false) ?? "";
//                   //     if (target.isNotEmpty) {
//                   //       setState(() {
//                   //         prompt = "Searching for '$target'...";
//                   //       });
//                   //       await Future.delayed(const Duration(seconds: 2));
//                   //       setState(() {
//                   //         buttonStatus = "Search finished.";
//                   //         prompt = "Found ${Random().nextInt(10)} results for your search.";
//                   //       });
//                   //     } else {
//                   //       setState(() {
//                   //         prompt = "Can't search for nothing :(";
//                   //       });
//                   //     }
//                   //   } else if (action is ShowAllTasksAction) {
//                   //     await chatBot.performAction(action);
//                   //     // * Show all tasks
//                   //     setState(() {
//                   //       prompt = "Collecting you tasks...";
//                   //     });
//                   //     await Future.delayed(const Duration(seconds: 1));
//                   //     setState(() {
//                   //       prompt = "You have ${Random().nextInt(50)} tasks in the database.";
//                   //     });
//                   //   } else if (action is CreateTaskAction) {
//                   //     await chatBot.performAction(action);
//                   //     // * Create new task
//                   //     setState(() {
//                   //       buttonStatus = "Creating task...";
//                   //       prompt = "What is the title of your task ?";
//                   //     });
//                   //     await Future.delayed(const Duration(seconds: 1));
//                   //     String title = await chatBot.askChatBot(throws: false) ?? "";
//                   //     if (title.isNotEmpty) {
//                   //       setState(() {
//                   //         prompt = "Creating task with title '$title'...";
//                   //       });
//                   //       await Future.delayed(const Duration(seconds: 1));
//                   //       setState(() {
//                   //         buttonStatus = "Task created";
//                   //         prompt = "Task with title '$title' has been created :)";
//                   //       });
//                   //     } else {
//                   //       setState(() {
//                   //         prompt = "Can't create task with empty title :(";
//                   //       });
//                   //     }
//                   //   }
//                   // } catch (e) {
//                   //   setState(() {
//                   //     prompt = "Can't identify action from user speech";
//                   //     buttonStatus = "Try again";
//                   //   });
//                   //   await Future.delayed(const Duration(seconds: 2));
//                   // }
//                   //
//                   // // * Reset UI and runtime
//                   // await Future.delayed(const Duration(seconds: 2));
//                   // setState(() {
//                   //   buttonStatus = "Ask ChatBot";
//                   //   prompt = "What do you want..?";
//                   //   listening = false;
//                   // });
//                 },
//                 child: Text(buttonStatus)),
//
//             // =========== APIs ===========
//             // const Padding(padding: EdgeInsets.only(top: 40, bottom: 5), child: Text("APIs")),
//             // FilledButton(
//             //     onPressed: () async {
//             //       logger.log("API::register => ${(await auth.register("Ahmed Sleem", "typ", "typahmedsleem@gmail.com", "1234567890", "role", "010", 23))}");
//             //     },
//             //     child: const Text("API.register")),
//             // FilledButton(
//             //     onPressed: () async {
//             //       logger.log("API::login => ${(await auth.login("Ahmed Sleem", "typ"))}");
//             //     },
//             //     child: const Text("API.login")),
//             // FilledButton(
//             //     onPressed: () async {
//             //       // logger.log("API::confirm => ${(await auth.confirm("Ahmed Sleem", "typ"))}");
//             //     },
//             //     child: const Text("API.confirm (not ready)")),
//             // FilledButton(
//             //     onPressed: () async {
//             //       logger.log("API::resetPassword => ${(await auth.resetPassword("Ahmed Sleem", "typ", "typahmedsleem@gmail.com", "1234567890"))}");
//             //     },
//             //     child: const Text("API.resetPassword")),
//             // FilledButton(
//             //     onPressed: () async {
//             //       // logger.log("API::forgetPassword => ${(await auth.forgetPassword("Ahmed Sleem"))}");
//             //     },
//             //     child: const Text("API.forgetPassword (not ready)")),
//             // FilledButton(
//             //     onPressed: () async {
//             //       logger.log("API::changePassword => ${(await auth.changePassword("Ahmed Sleem", "typ", "typahmedsleem@gmail.com", "1234567890"))}");
//             //     },
//             //     child: const Text("API.changePassword"))
//           ],
//         )),
//       ),
//     );
//   }
// }
