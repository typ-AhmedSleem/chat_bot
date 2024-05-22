package com.typ.chat_bot

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.media.RingtoneManager
import android.util.Log
import android.widget.Toast
import kotlin.concurrent.thread

class AlarmReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context?, intent: Intent?) {
        Log.v(TAG, "onReceive: Alarm received")
        Toast.makeText(context, "You have an alarm now !!!", Toast.LENGTH_SHORT).show()
        // Play alarm sound
        thread {
            // Get default alarm system sound
            val alarmUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
            RingtoneManager.getRingtone(context, alarmUri).apply {
                audioAttributes = AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_ALARM)
                    .build()
                // Play alarm sound
                play()
                // Stop alarm after 3 seconds
                Thread.sleep(ALARM_DURATION)
                stop()
            }
        }
    }

    companion object {
        private const val TAG = "ChatBotAlarmReceiver"
        private const val ALARM_DURATION = 10 * 1000L
    }

}