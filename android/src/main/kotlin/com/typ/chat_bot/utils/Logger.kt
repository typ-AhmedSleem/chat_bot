package com.typ.chat_bot.utils

import android.util.Log

class Logger(private val tag: String) {

    fun log(what: Any, level: LogLevel = LogLevel.DEBUG) {
        if (!LOG_ENABLED) return
        Log.println(logLevelsMap[level]!!, tag, what.toString())
    }

    enum class LogLevel {
        DEBUG,
        INFO,
        VERBOSE,
        WARNING,
        ERROR,
        ASSERT
    }

    companion object {
        private const val LOG_ENABLED = true
        private val logLevelsMap = mapOf(
            LogLevel.DEBUG to Log.DEBUG,
            LogLevel.INFO to Log.INFO,
            LogLevel.VERBOSE to Log.VERBOSE,
            LogLevel.WARNING to Log.WARN,
            LogLevel.ERROR to Log.ERROR,
            LogLevel.ASSERT to Log.ASSERT,
        )
    }

}