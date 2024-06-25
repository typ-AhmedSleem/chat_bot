class FamilyLocation {
  final double latitude;
  final double longitude;

  FamilyLocation({
    required this.latitude,
    required this.longitude,
  });

  factory FamilyLocation.fromJson(Map<String, dynamic> json) {
    return FamilyLocation(
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }
}
