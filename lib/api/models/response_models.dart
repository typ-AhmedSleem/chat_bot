class RecognizedPerson {
  final String familyName;
  final String relation;
  final double familyLatitude;
  final double familyLongitude;
  final String familyPhoneNumber;
  final String descriptionOfPatient;
  final String familyAvatarUrl;

  RecognizedPerson(
      {required this.familyName,
      required this.relation,
      required this.familyLatitude,
      required this.familyLongitude,
      required this.familyPhoneNumber,
      required this.descriptionOfPatient,
      required this.familyAvatarUrl});

  RecognizedPerson.fromJson(Map<String, dynamic> raw)
      : this(
          familyName: raw["familyName"],
          relation: raw["relation"],
          familyLatitude: raw["familyLatitude"],
          familyLongitude: raw["familyLongitude"],
          familyPhoneNumber: raw["familyPhoneNumber"],
          descriptionOfPatient: raw["descriptionOfPatient"],
          familyAvatarUrl: raw["familyAvatarUrl"],
        );

  @override
  String toString() {
    return "Name: $familyName\n";
  }
}
