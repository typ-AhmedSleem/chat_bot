class Action {
  ActionType type;

  Action(this.type);

  String? getActionName() {
    if (type == ActionType.unknown) return null;
    return type.name;
  }

  factory Action.getActionFromName(String name) {
    final String rawAction = name.trim().toLowerCase();
    for (ActionType type in ActionType.values) {
        if (type.name == rawAction) {
            return Action(type);
        }
    }

    return Action(ActionType.unknown);
  }
}

enum ActionType { alarm, search, show_all_tasks, task, unknown }
