package com.typ.chat_bot.actions

import android.util.Log

enum class ActionType {
    ALARM,
    SEARCH,
    SHOW_ALL_TASKS,
    TASK,
    UNKNOWN;

    companion object {
        @JvmStatic
        fun getTypeByName(name: String): ActionType {
            Log.d("ActionType", "getTypeByName: Getting type for name: $name")
            return when (name.trim().lowercase()) {
                "alarm" -> ALARM
                "search" -> SEARCH
                "show_all_tasks" -> SHOW_ALL_TASKS
                "task" -> TASK
                else -> UNKNOWN
            }.apply {
                Log.d("ActionType", "getActionByName: $this")
            }
        }
    }

}