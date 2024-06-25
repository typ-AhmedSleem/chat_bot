class PatientRelatedMember {
  final String familyId;
  final String familyName;
  final String relation;
  final String familyDescriptionForPatient;
  final String hisImageUrl;

  PatientRelatedMember({
    required this.familyId,
    required this.familyName,
    required this.relation,
    required this.familyDescriptionForPatient,
    required this.hisImageUrl,
  });

  factory PatientRelatedMember.fromJson(Map<String, dynamic> json) {
    return PatientRelatedMember(
      familyId: json['familyId'],
      familyName: json['familyName'],
      relation: json['relationility'],
      familyDescriptionForPatient: json['familyDescriptionForPatient'],
      hisImageUrl: json['hisImageUrl'],
    );
  }
}
