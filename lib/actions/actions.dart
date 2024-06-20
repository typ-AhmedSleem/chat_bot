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

  CreateAlarmAction() : super(title: Texts.createAlarmAtGivenTime, name: "alarm", methodName: Texts.createAlarmAction);
}

class SearchAction extends Action {
  SearchAction() : super(title: Texts.searchForSomeone, name: "search", methodName: Texts.searchForSomeoneAction);
}

class ShowAllTasksAction extends Action {
  ShowAllTasksAction() : super(title: Texts.showAllTasks, name: "show_all_tasks", methodName: Texts.showAllTasksAction);
}

class CreateTaskAction extends Action {
  CreateTaskAction() : super(title: Texts.createNewTask, name: "task", methodName: Texts.createNewTaskAction);
}

class UnknownAction extends Action {
  UnknownAction() : super(title: Texts.unknownAction, name: "unknown", methodName: "unknown");
}
