import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:image_picker/image_picker.dart';

import 'actions/actions.dart';
import 'alarm_handler.dart';
import 'api/chat_bot_api.dart';
import 'chat_bot_platform_interface.dart';
import 'helpers/logger.dart';

/// Class that holds most functions
/// that ChatBot can do
class ChatBot {
  final logger = Logger("ChatBot");
  late final PatientAPI _api;
  final _imagePicker = ImagePicker();

  ChatBot({required String token}) {
    _api = PatientAPI(token: token);
  }

  PatientAPI get api => _api;

  /// Starts SpeechToText service in
  /// the android native side and return
  /// the detected text after he finishes.
  Future<String?> askChatBot({bool throws = true}) async {
    logger.log("askChatBot: ChaBot is asking user for his speech...");
    try {
      return ChatBotPluginPlatform.instance.askChatBot();
    } catch (e) {
      if (throws) {
        rethrow;
      } else {
        return null;
      }
    }
  }

  Future<Action?> identifyAction(String text) {
    logger.log("identifyAction: Identifying action '$text'...");
    return ChatBotPluginPlatform.instance.identifyAction(text);
  }

  // Future<T?> performAction<T>(Action action, [List<dynamic> args = const []]) {
  //   logger.log("performAction: Performing '${action.name}' at '${action.methodName}' with args '$args'.");
  //   return ChatBotPluginPlatform.instance.performAction(action, args);
  // }

  Future<bool> scheduleAlarm({required int id, DateTime? timestamp}) async {
    if (timestamp == null) return false;
    return AndroidAlarmManager.oneShotAt(timestamp, id, handleAlarm, exact: true, wakeup: true, rescheduleOnReboot: true);
  }

  Future<String?> pickImageFromGallery() async {
    final XFile? imgXFile = await _imagePicker.pickImage(source: ImageSource.gallery);
    return imgXFile?.path;
  }

  Future<String?> pickVideoFromGallery() async {
    final XFile? imgXFile = await _imagePicker.pickVideo(source: ImageSource.gallery);
    return imgXFile?.path;
  }
}
