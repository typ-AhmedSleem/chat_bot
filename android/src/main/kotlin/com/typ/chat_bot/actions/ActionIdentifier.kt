package com.typ.chat_bot.actions

import android.content.Context
import android.util.Log
import com.typ.chat_bot.ai.ActionTextClassifier

class ActionIdentifier(context: Context) {

    private val classifier = ActionTextClassifier(context)

    fun identifyAction(text: String, callback: (Action?, String?) -> Unit) {
        classifier.classify(text) { result, error ->
            // Check if has error at first
            if (error != null || result == null) {
                Log.e(TAG, "identifyAction: Error => $error")
                callback(null, error)
                return@classify
            }
            // Handle the result
            val rawResult = result.classificationResult()
                .classifications()
                .first()
                .categories().maxByOrNull { it.score() }

            rawResult?.let { raw ->
                Log.d(TAG, "identified action: $raw")
                callback(Action(raw.categoryName()), null)
            } ?: callback(null, "Action not found.")
        }
    }

    companion object {
        const val TAG = "ActionIdentifier"
    }

}