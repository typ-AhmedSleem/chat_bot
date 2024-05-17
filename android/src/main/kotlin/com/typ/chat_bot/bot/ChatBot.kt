package com.typ.chat_bot.bot

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.util.Log
import com.typ.chat_bot.AlarmReceiver
import com.typ.chat_bot.actions.Action
import com.typ.chat_bot.actions.ActionIdentifier
import com.typ.chat_bot.errors.SpeechRecognitionError
import com.typ.chat_bot.utils.formattedTimestamp
import java.util.Calendar
import kotlin.random.Random

class ChatBot(private val context: Context) {

    private val speechRecognizer = ChatBotSpeechRecognizer(context)
    private val actionIdentifier = ActionIdentifier(context)

    fun listenToUser(callback: (String, SpeechRecognitionError?) -> Unit) {
        speechRecognizer.listenToUser(callback)
    }

    fun identifyAction(text: String, callback: (Action?, String?) -> Unit) {
        Log.i(TAG, "identifyAction: $text")
        actionIdentifier.identifyAction(text, callback)
    }

    fun scheduleAlarm(time: Calendar) {
        Log.i(TAG, "scheduleAlarm: Scheduling alarm at ${time.time.formattedTimestamp()}")
        val am = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val alarmIntent = Intent(context, AlarmReceiver::class.java)
        val operation = PendingIntent.getBroadcast(context, Random.nextInt(3000), alarmIntent, PendingIntent.FLAG_MUTABLE)
        am.setExact(AlarmManager.RTC_WAKEUP, time.timeInMillis, operation)
        Log.i(TAG, "scheduleAlarm: Scheduled alarm at ${time.time.formattedTimestamp()}")
    }

    companion object {
        const val TAG = "ChatBot"
    }

}
