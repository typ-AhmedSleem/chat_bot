package com.typ.chat_bot.errors

open class ChatBotError(
    override val message: String?,
    override val cause: Throwable? = null
) : Throwable(message, cause)