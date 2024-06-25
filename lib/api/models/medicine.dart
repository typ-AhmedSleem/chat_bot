// reminder_model.dart

class Medicine {
  final String reminderId;
  final String medicationName;
  final String dosage;
  final MedicineType medicineType;
  final RepeatType repeater;
  final DateTime startDate;
  final DateTime endDate;

  Medicine({
    required this.reminderId,
    required this.medicationName,
    required this.dosage,
    required this.medicineType,
    required this.repeater,
    required this.startDate,
    required this.endDate,
  });

  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      reminderId: json['reminderId'],
      medicationName: json['medication_Name'],
      dosage: json['dosage'],
      medicineType: MedicineType.of(json['medcineType']),
      repeater: RepeatType.of(json['repeater']),
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
    );
  }
}

enum RepeatType {
  once,
  twice,
  threeTimes,
  fourTimes;

  static RepeatType of(int value) {
    switch (value) {
      case 0:
      case 24:
        return RepeatType.once;
      case 1:
      case 12:
        return RepeatType.twice;
      case 2:
      case 6:
        return RepeatType.threeTimes;
      case 3:
      case 4:
        return RepeatType.fourTimes;
      default:
        throw ArgumentError('Invalid repeat type value: $value');
    }
  }
}

enum MedicineType {
  bottle,
  pill,
  syringe,
  tablet;

  static MedicineType of(int value) {
    switch (value) {
      case 0:
        return MedicineType.bottle;
      case 1:
        return MedicineType.pill;
      case 2:
        return MedicineType.syringe;
      case 3:
        return MedicineType.tablet;
      default:
        throw ArgumentError('Invalid medicine type value: $value');
    }
  }
}
