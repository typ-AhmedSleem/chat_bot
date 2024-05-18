package com.typ.chat_bot.utils

import android.util.Log
import com.typ.chat_bot.errors.ChatBotError
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Date
import java.util.Locale


fun Any?.ensureNotNull(msgIfEmpty: String): Any {
    if (this == null) throw ChatBotError(msgIfEmpty)
    return this
}

fun List<*>?.ensureNotEmpty(msgIfEmpty: String): List<*> {
    if (this == null) throw ChatBotError("List can't be null.")
    if (this.isEmpty()) throw ChatBotError(msgIfEmpty)

    return this
}

/**
 * Parses the timestamp string and convert it to a Calendar object.
 */
fun parseTimestamp(timestamp: String): Calendar {
    val formatter = SimpleDateFormat.getInstance()
    val date = runCatching { formatter.parse(timestamp) }.getOrDefault(Date())
    val calendar = Calendar.getInstance()
    calendar.time = date
    calendar.roll(Calendar.MINUTE, 1)
    Log.d("ChatBotPlugin-utils", "parseTimestamp: Parsed '$timestamp' into '${calendar.time.formattedTimestamp()}'")
    return calendar
}


fun Date.formattedTimestamp(pattern: String = "dd/MM/yyyy hh:mm aa"): String = SimpleDateFormat(pattern, Locale.getDefault()).format(this)

