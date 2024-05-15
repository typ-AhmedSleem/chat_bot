package com.typ.chat_bot.ai

import android.content.Context
import android.util.Log
import com.google.mediapipe.tasks.core.BaseOptions
import com.google.mediapipe.tasks.text.textclassifier.TextClassifier
import com.google.mediapipe.tasks.text.textclassifier.TextClassifierResult
import java.util.concurrent.ScheduledThreadPoolExecutor

class ActionTextClassifier(private val context: Context) {

    private var ready = false
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
            ready = true
            Log.i(TAG, "Text classifier is ready")
        } catch (e: IllegalStateException) {
            ready = false
            Log.e(TAG, "Text classifier failed to load the task with error: " + e.message)
        }
    }

    fun classify(sentence: String, callback: (TextClassifierResult?, String?) -> Unit) {
        if (!ready || !::textClassifier.isInitialized) {
            callback(null, "Text classifier is not ready")
            return
        }
        executor = ScheduledThreadPoolExecutor(1)
        executor.execute {
            val results = textClassifier.classify(sentence)
            callback(results, null)
        }
    }

    fun close() {
        executor.shutdown()
        textClassifier.close()
        ready = false
    }

    companion object {
        const val TAG = "TextClassifier"
        const val MODEL_PATH = "model_bert_v2.tflite"
    }

}