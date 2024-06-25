abstract class ApiTarget {
  String prompt;

  ApiTarget(this.prompt);

  static final targets = [
    GetPatientProfileTarget(),
    GetPatientRelatedMembersTarget(),
    GetFamilyLocationTarget(),
    // MarkMedicationReminderTarget(),
    AddSecretFileTarget(),
    AskToSeeSecretFileTarget(),
    // AddGameScoreTarget(),
    GetSecretFileTarget(),
    GetAllAppointmentsTarget(),
    GetAllMedicinesTarget(),
    GetMediaTarget(),
    GetCurrentAndMaxScoreTarget(),
  ];
}

class GetPatientProfileTarget extends ApiTarget {
  GetPatientProfileTarget() : super("عرض الملف الشخصي");
}

class GetPatientRelatedMembersTarget extends ApiTarget {
  GetPatientRelatedMembersTarget() : super("عرض الاقارب");
}

class GetFamilyLocationTarget extends ApiTarget {
  GetFamilyLocationTarget() : super("عرض مكان العائلة");
}

class MarkMedicationReminderTarget extends ApiTarget {
  MarkMedicationReminderTarget() : super("تنبيه الدواء");
}

class AddSecretFileTarget extends ApiTarget {
  AddSecretFileTarget() : super("اضافة ملف محمي");
}

class AskToSeeSecretFileTarget extends ApiTarget {
  AskToSeeSecretFileTarget() : super("طلب عرض ملف محمي");
}

class AddGameScoreTarget extends ApiTarget {
  AddGameScoreTarget() : super("");
}

class GetSecretFileTarget extends ApiTarget {
  GetSecretFileTarget() : super("عرض الملفات المحمية");
}

class GetAllAppointmentsTarget extends ApiTarget {
  GetAllAppointmentsTarget() : super("عرض كل المواعيد");
}

class GetAllMedicinesTarget extends ApiTarget {
  GetAllMedicinesTarget() : super("عرض مواعيد الادوية");
}

class GetMediaTarget extends ApiTarget {
  GetMediaTarget() : super("عرض الوسائط الخاصة بي");
}

class GetCurrentAndMaxScoreTarget extends ApiTarget {
  GetCurrentAndMaxScoreTarget() : super("عرض بيانات الscore خاصتي");
}
