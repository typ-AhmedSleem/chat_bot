package com.typ.chat_bot

import com.typ.chat_bot.bot.ChatBot
import com.typ.chat_bot.errors.SpeechRecognitionError
import com.typ.chat_bot.utils.Logger
import com.typ.chat_bot.utils.ensureNotEmpty
import com.typ.chat_bot.utils.formattedTimestamp
import com.typ.chat_bot.utils.parseTimestamp
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** ChatBotPlugin */
class ChatBotPlugin : FlutterPlugin, MethodCallHandler {

    private val logger = Logger("ChatBotPlugin")
    private lateinit var channel: MethodChannel
    private lateinit var bot: ChatBot

    override fun onAttachedToEngine(pluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(pluginBinding.binaryMessenger, Constants.METHOD_CHANNEL_NAME)
        channel.setMethodCallHandler(this)
        // Create a new ChatBot instance
        bot = ChatBot(pluginBinding.applicationContext)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            MethodsNames.START_VOICE_INPUT -> {
                // Listen what user says using SpeechRecognizer
                bot.listenToUser { text, error ->
                    if (error != null) {
                        // * Check if the error is a missing permission
                        if (error is SpeechRecognitionError.SRNotSupportedError) {
                            // Open app permissions on device settings
//                            bot.showAppSettings()
                        }
                        // * Result the error back to flutter
                        result.error(error.code.toString(), error.message, null)
                        return@listenToUser
                    }
                    // * Result the text to flutter
                    result.success(text)
                }
            }

            MethodsNames.IDENTIFY_ACTION -> {
                val text = call.arguments as String? ?: return
                logger.log("Identifying action for text: $text", Logger.LogLevel.INFO)
                bot.identifyAction(text) { action, error ->
                    if (action != null) result.success(action.name)
                    else result.error("123", error, null)
                }
            }

            MethodsNames.CREATE_ALARM -> {
                // Grab the formatted timestamp form args list
                val args = (call.arguments as List<*>?).ensureNotEmpty("You should pass the formatted timestamp in the flutter call args.")
                val formattedTimestamp = args.first() as String
                val alarmTime = parseTimestamp(formattedTimestamp)
                logger.log("Creating alarm at: ${alarmTime.time.formattedTimestamp()}", Logger.LogLevel.INFO)

                // Schedule alarm at the given alarmTime
                val scheduled = runCatching { bot.scheduleAlarm(alarmTime) }.isSuccess
                result.success(scheduled)
            }

            MethodsNames.SEARCH_FOR_SOMETHING -> {
                // Always returns 'true' as require completion signal
                result.success(true)
            }

            MethodsNames.SHOW_ALL_TASKS -> {
                // Always returns 'true' as require completion signal
                result.success(true)
            }

            MethodsNames.CREATE_NEW_TASK -> {
                // Always returns 'true' as require completion signal
                result.success(true)
            }

            else -> {
                result.notImplemented()
            }
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
