package com.typ.chat_bot.bot

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.speech.RecognitionListener
import android.speech.RecognizerIntent
import android.speech.SpeechRecognizer
import com.typ.chat_bot.errors.SpeechRecognitionError
import com.typ.chat_bot.utils.Logger
import java.util.Locale

class ChatBot(context: Context) : RecognitionListener {

    private val logger = Logger("ChatBot")
    private var listeningCallback: ((String, SpeechRecognitionError?) -> Unit)? = null
    private val recognizer = SpeechRecognizer.createSpeechRecognizer(context).apply {
        this.setRecognitionListener(this@ChatBot)
    }
    private val recognizerIntent: Intent = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH).apply {
        putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL,RecognizerIntent.LANGUAGE_MODEL_FREE_FORM)
        putExtra(RecognizerIntent.EXTRA_LANGUAGE, Locale("ar"))
    }

    fun listenToUser(callback: (String, SpeechRecognitionError?) -> Unit) {
        listeningCallback = callback
        // Start speech recognition
        recognizer.startListening(Intent(RecognizerIntent.ACTION_VOICE_SEARCH_HANDS_FREE))
        logger.log(Logger.LogLevel.DEBUG, "listenToUser. Listening...")
    }

    override fun onReadyForSpeech(params: Bundle?) {
        logger.log(Logger.LogLevel.DEBUG, "onReadyForSpeech")
    }

    override fun onBeginningOfSpeech() {
        logger.log(Logger.LogLevel.DEBUG, "onBeginningOfSpeech")
    }

    override fun onRmsChanged(rmsdB: Float) {
    }

    override fun onBufferReceived(buffer: ByteArray?) {
    }

    override fun onEndOfSpeech() {
        logger.log(Logger.LogLevel.DEBUG, "onEndOfSpeech")
    }

    override fun onError(code: Int) {
        val error= when (code) {
            SpeechRecognizer.ERROR_NO_MATCH -> SpeechRecognitionError.SRNoMatchError()
            else -> {
                SpeechRecognitionError.SRNotSupportedError()
            }
        }
        logger.log(Logger.LogLevel.DEBUG, "onError. code= $code, $error")
    }

    override fun onResults(results: Bundle?) {
        val speech = results?.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)
        listeningCallback?.let { it(speech?.firstOrNull()!!, null) }
        logger.log(Logger.LogLevel.DEBUG, "onResults. speech= $speech")
    }

    override fun onPartialResults(partialResults: Bundle?) {
        val speech = partialResults?.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)
        logger.log(Logger.LogLevel.DEBUG, "onPartialResults. speech= $speech")
    }

    override fun onEvent(eventType: Int, params: Bundle?) {
    }

    companion object {
        const val TAG = "ChatBot"
    }

}
