class Appointment {
  final String appointmentId;
  final DateTime date;
  final String location;
  final String notes;
  final String familyNameWhoCreatedAppointment;
  final bool canDeleted;

  Appointment({
    required this.appointmentId,
    required this.date,
    required this.location,
    required this.notes,
    required this.familyNameWhoCreatedAppointment,
    required this.canDeleted,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      appointmentId: json['appointmentId'],
      date: DateTime.parse(json['date']),
      location: json['location'],
      notes: json['notes'],
      familyNameWhoCreatedAppointment: json['familyNameWhoCreatedAppointemnt'],
      canDeleted: json['canDeleted'],
    );
  }
}
