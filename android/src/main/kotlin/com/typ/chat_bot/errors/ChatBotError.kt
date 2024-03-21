package com.typ.chat_bot.errors

/**
 * Base class for all errors
 * faced or thrown within codebase
 */
open class ChatBotError(
    override val message: String?,
    override val cause: Throwable? = null
) : Throwable(message, cause)