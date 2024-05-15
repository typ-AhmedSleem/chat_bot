package com.typ.chat_bot.actions

class Action(
    val name: String
) {

    val type by lazy { ActionType.getTypeByName(name) }

}
