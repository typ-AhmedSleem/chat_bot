package com.typ.chat_bot

import com.typ.chat_bot.bot.ChatBot
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** ChatBotPlugin */
class ChatBotPlugin : FlutterPlugin, MethodCallHandler {

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
                        // Result the error back to flutter
                        result.error(error.code.toString(), error.message, null)
                        return@listenToUser
                    }
                    // Result the text to flutter
                    result.success(text)
                }
            }

            MethodsNames.IDENTIFY_ACTION -> {
                val text = call.arguments as String?
                // feature: Understand the speech and determine tokens
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
