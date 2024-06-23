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
          relation: raw["relationalityOfThisPatient"],
          familyLatitude: raw["familyLatitude"],
          familyLongitude: raw["familyLongitude"],
          familyPhoneNumber: raw["familyPhoneNumber"],
          descriptionOfPatient: raw["descriptionForPatient"],
          familyAvatarUrl: raw["familyAvatarUrl"],
        );

  @override
  String toString() {
    return 'familyName: $familyName,\n'
        'relation: $relation,\n'
        'familyLatitude: $familyLatitude,\n'
        'familyLongitude: $familyLongitude,\n'
        'familyPhoneNumber: $familyPhoneNumber,\n'
        'descriptionOfPatient: $descriptionOfPatient,\n'
        'familyAvatarUrl: $familyAvatarUrl\n';
  }
}
