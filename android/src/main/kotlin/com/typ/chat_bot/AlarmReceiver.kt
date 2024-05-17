package com.typ.chat_bot

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

class AlarmReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context?, intent: Intent?) {
        // todo: Notify user about the alarm
        Log.v(TAG, "onReceive: Alarm received")
    }

    companion object {
        private const val TAG = "ChatBotAlarmReceiver"
    }

}