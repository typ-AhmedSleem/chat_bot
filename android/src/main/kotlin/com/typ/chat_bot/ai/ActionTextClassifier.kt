package com.typ.chat_bot.ai

import android.content.Context
import android.util.Log
import com.google.mediapipe.tasks.core.BaseOptions
import com.google.mediapipe.tasks.text.textclassifier.TextClassifier
import com.google.mediapipe.tasks.text.textclassifier.TextClassifierResult
import java.util.concurrent.ScheduledThreadPoolExecutor

class ActionTextClassifier(
    private val context: Context,
    private val listener: ActionClassifierListener
) {

    private lateinit var textClassifier: TextClassifier
    private lateinit var executor: ScheduledThreadPoolExecutor

    init {
        initClassifier()
    }

    private fun initClassifier() {
        val baseOptionsBuilder = BaseOptions.builder()
            .setModelAssetPath(MODEL_PATH)

        try {
            val baseOptions = baseOptionsBuilder.build()
            val options = TextClassifier.TextClassifierOptions.builder()
                .setBaseOptions(baseOptions)
                .build()
            textClassifier = TextClassifier.createFromOptions(context, options)
        } catch (e: IllegalStateException) {
            listener.onError("Text classifier failed to initialize. See error logs for " + "details")
            Log.e(TAG, "Text classifier failed to load the task with error: " + e.message)
        }
    }

    fun classify(sentence: String) {
        executor = ScheduledThreadPoolExecutor(1)
        executor.execute {
            val results = textClassifier.classify(sentence)
            listener.onClassifierResults(results)
        }
    }

    fun close() {
        executor.shutdown()
        textClassifier.close()
    }

    interface ActionClassifierListener {
        fun onClassifierResults(result: TextClassifierResult)
        fun onError(error: String)
    }

    companion object {
        const val TAG = "TextClassifier"
        const val MODEL_PATH = "model_bert.tflite"
    }

}