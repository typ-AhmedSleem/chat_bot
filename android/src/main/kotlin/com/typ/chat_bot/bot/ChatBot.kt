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
import java.util.Calendar

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
        val am = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val alarmIntent = Intent(context, AlarmReceiver::class.java)
        val operation = PendingIntent.getBroadcast(context, RC_ALARM_RECEIVER, alarmIntent, PendingIntent.FLAG_UPDATE_CURRENT)
        am.setExact(AlarmManager.RTC_WAKEUP, time.timeInMillis, operation)
        Log.i(TAG, "scheduleAlarm: Alarm scheduled at ${time.time}")
    }

    companion object {
        const val TAG = "ChatBot"
        private const val RC_ALARM_RECEIVER = 123
    }

}
