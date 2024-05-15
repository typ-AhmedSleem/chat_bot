package com.typ.chat_bot.bot

import android.content.Context
import android.util.Log
import com.typ.chat_bot.actions.Action
import com.typ.chat_bot.actions.ActionIdentifier
import com.typ.chat_bot.errors.SpeechRecognitionError
import com.typ.chat_bot.utils.Logger

class ChatBot(context: Context) {

    // Logger instance
    private val logger = Logger("ChatBot")

    private val speechRecognizer = ChatBotSpeechRecognizer(context)
    private val actionIdentifier = ActionIdentifier(context)

    fun listenToUser(callback: (String, SpeechRecognitionError?) -> Unit) {
        speechRecognizer.listenToUser(callback)
    }

    fun identifyAction(text: String, callback: (Action?, String?) -> Unit) {
        Log.i(TAG, "identifyAction: $text")
        actionIdentifier.identifyAction(text, callback)
    }

    companion object {
        const val TAG = "ChatBot"
    }

}
