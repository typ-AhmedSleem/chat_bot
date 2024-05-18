abstract class Action {
  String name;
  String methodName;

  Action(this.name, this.methodName);

  List<dynamic> args = [];

  Action withArgs(List<dynamic> args) {
    this.args = args;
    return this;
  }

  factory Action.getActionByName(String name) {
    final actionName = name.trim().toLowerCase();
    for (Action action in [CreateAlarmAction(), SearchAction(), ShowAllTasksAction(), CreateTaskAction()]) {
      if (action.name == actionName) return action;
    }
    return UnknownAction();
  }
}

class CreateAlarmAction extends Action {
  CreateAlarmAction() : super("alarm", "createAlarm");
}

class SearchAction extends Action {
  SearchAction() : super("search", "searchForSomething");
}

class ShowAllTasksAction extends Action {
  ShowAllTasksAction() : super("show_all_tasks", "showAllTasks");
}

class CreateTaskAction extends Action {
  CreateTaskAction() : super("task", "createNewTask");
}

class UnknownAction extends Action {
  UnknownAction() : super("unknown", "unknown");
}
