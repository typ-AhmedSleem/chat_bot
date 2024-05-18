package com.typ.chat_bot.errors

import android.speech.SpeechRecognizer

/**
 * Class for SpeechRecognition Error that holds
 * error code and message
 */
sealed class SpeechRecognitionError(val code: Int, val message: String) {
    class SREmptyResponseError : SpeechRecognitionError(0, "Speech recognition returned an empty string.")
    class SRNoMatchError : SpeechRecognitionError(SpeechRecognizer.ERROR_NO_MATCH, "Speech recognition can't figure out what you speak.")
    class SRNotSupportedError : SpeechRecognitionError(14, "Speech recognition isn't supported in this device.")
    class SRServerError : SpeechRecognitionError(SpeechRecognizer.ERROR_SERVER, "Can't reach servers to use service.")
    class SRTimeoutError : SpeechRecognitionError(SpeechRecognizer.ERROR_SPEECH_TIMEOUT, "Speech timeout.")
    class SRLanguageNotSupported : SpeechRecognitionError(12, "Recognition language is not supported.")
    class SRAudioError : SpeechRecognitionError(SpeechRecognizer.ERROR_AUDIO, "Error recording audio. Check your mic.")
    class SRClientError : SpeechRecognitionError(SpeechRecognizer.ERROR_CLIENT, "Error with recognizer client. Try again.")
    class SRNeedPermissionsError : SpeechRecognitionError(SpeechRecognizer.ERROR_INSUFFICIENT_PERMISSIONS, "Some needed permissions are not granted.")
    class SRRecognizerBusyError : SpeechRecognitionError(SpeechRecognizer.ERROR_RECOGNIZER_BUSY, "Speech recognizer is busy being used by another app.")

    override fun toString(): String {
        return "${this::class.simpleName}(code=$code, message='$message')"
    }
}