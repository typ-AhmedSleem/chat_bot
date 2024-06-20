package com.typ.chat_bot.bot

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.speech.RecognitionListener
import android.speech.RecognizerIntent
import android.speech.SpeechRecognizer
import com.typ.chat_bot.errors.SpeechRecognitionError
import com.typ.chat_bot.utils.Logger

class ChatBotSpeechRecognizer(private val context: Context) : RecognitionListener {

    // Logger instance
    private val logger = Logger(TAG)

    // Recognizer callback
    private var listeningCallback: ((String, SpeechRecognitionError?) -> Unit)? = null

    // Speech recognizer
    private val recognizer = SpeechRecognizer.createSpeechRecognizer(context).apply {
        this.setRecognitionListener(this@ChatBotSpeechRecognizer)
    }

    // Speech recognizer intent
    private val recognizerIntent: Intent = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH).apply {
        putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM)
        putExtra(RecognizerIntent.EXTRA_LANGUAGE, ARABIC)
    }

    /**
     * Calls SpeechRecognition instance to start listening for
     * speech spoken by user and receive results on callback
     */
    fun listenToUser(callback: (String, SpeechRecognitionError?) -> Unit) {
        // Assign callback
        listeningCallback = callback
        // Start listening
        recognizer.startListening(this.recognizerIntent)
    }

    /**
     * CALLBACK: called when recognizer is ready
     * to listen for speech
     */
    override fun onReadyForSpeech(params: Bundle?) {
        logger.log("onReadyForSpeech. Listening...")
    }

    /**
     * CALLBACK: called when user starts speaking
     * and recognizer starts detecting that
     */
    override fun onBeginningOfSpeech() {
    }

    override fun onRmsChanged(rmsdB: Float) {
    }

    override fun onBufferReceived(buffer: ByteArray?) {
    }

    /**
     * CALLBACK: called when user stops speaking
     * and recognizer detects that
     */
    override fun onEndOfSpeech() {
        logger.log("onEndOfSpeech")
    }

    /**
     * CALLBACK: called when an error happened
     * while or after listening to user speech
     */
    override fun onError(code: Int) {
        val error = when (code) {
            SpeechRecognizer.ERROR_NO_MATCH -> SpeechRecognitionError.SRNoMatchError()
            else -> {
                SpeechRecognitionError.SRNotSupportedError()
            }
        }
        logger.log("onError. code= $code, $error")
        listeningCallback?.invoke(EMPTY_TEXT, error)
    }

    /**
     * CALLBACK: called after recognizer detects end of speech
     * and converts speech into text
     */
    override fun onResults(results: Bundle?) {
        val speech = results?.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)
        listeningCallback?.let { it(speech?.firstOrNull()!!, null) }
        logger.log("onResults. speech= $speech")
    }

    override fun onPartialResults(partialResults: Bundle?) {
        logger.log("onPartialResults.")
    }

    override fun onEvent(eventType: Int, params: Bundle?) {
    }

    companion object {
        const val TAG = "ChatBotSTT"
        const val ARABIC = "ar"
        const val EMPTY_TEXT = ""
    }

}