import 'package:chat_bot/helpers/texts.dart';

import 'action_answer.dart';

abstract class Action {
  String title;
  String name;
  String methodName;
  ActionAnswerRequest? answerRequest;

  Action({required this.title, required this.name, required this.methodName});

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
  DateTime? alarmTime;

  CreateAlarmAction() : super(title: Texts.createAlarmAction, name: "alarm", methodName: "createAlarm");
}

class SearchAction extends Action {
  SearchAction() : super(title: Texts.searchForSomeoneAction, name: "search", methodName: "searchForSomething");
}

class ShowAllTasksAction extends Action {
  ShowAllTasksAction() : super(title: Texts.showAllTasksAction, name: "show_all_tasks", methodName: "showAllTasks");
}

class CreateTaskAction extends Action {
  CreateTaskAction() : super(title: Texts.createNewTaskAction, name: "task", methodName: "createNewTask");
}

class UnknownAction extends Action {
  UnknownAction() : super(title: Texts.unknownAction, name: "unknown", methodName: "unknown");
}
