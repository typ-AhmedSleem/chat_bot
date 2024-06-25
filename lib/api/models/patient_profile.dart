class PatientProfile {
  final String patientId;
  final String fullName;
  final int age;
  final String phoneNumber;
  final DateTime diagnosisDate;
  final String message;

  PatientProfile({
    required this.patientId,
    required this.fullName,
    required this.age,
    required this.phoneNumber,
    required this.diagnosisDate,
    required this.message,
  });

  factory PatientProfile.fromJson(Map<String, dynamic> json) {
    return PatientProfile(
      patientId: json['patientId'],
      fullName: json['fullName'],
      age: json['age'],
      phoneNumber: json['phoneNumber'],
      diagnosisDate: DateTime.parse(json['diagnosisDate']),
      message: json['message'],
    );
  }
}
