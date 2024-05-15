package com.typ.chat_bot.bot

import android.content.Context
import com.typ.chat_bot.ai.ActionTextClassifier
import com.typ.chat_bot.errors.SpeechRecognitionError
import com.typ.chat_bot.utils.Logger

class ChatBot(context: Context) {

    // Logger instance
    private val logger = Logger("ChatBot")

    private val speechRecognizer = ChatBotSpeechRecognizer(context)

    fun listenToUser(callback: (String, SpeechRecognitionError?) -> Unit) {
        speechRecognizer.listenToUser(callback)
    }

    companion object {
        const val TAG = "ChatBot"
    }

}
