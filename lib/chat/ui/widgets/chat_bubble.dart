import 'dart:io';

import 'package:chat_bot/api/models/appointment.dart';
import 'package:chat_bot/api/models/family_location.dart';
import 'package:chat_bot/api/models/game_data.dart';
import 'package:chat_bot/api/models/media.dart';
import 'package:chat_bot/api/models/medicine.dart';
import 'package:chat_bot/api/models/patient_profile.dart';
import 'package:chat_bot/api/models/patient_related_member.dart';
import 'package:chat_bot/api/models/recognized_person.dart';
import 'package:chat_bot/api/models/secret_file.dart';
import 'package:chat_bot/chat/ui/widgets/chat_action_announcement_bubble.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/message.dart';

class ChatBubble extends StatelessWidget {
  final Message message;
  final bool showTail;

  const ChatBubble({super.key, required this.message, required this.showTail});

  static ChatBubble ofMessage({required Message msg, required bool showTail}) {
    return ChatBubble(message: msg, showTail: showTail);
  }

  @override
  Widget build(BuildContext context) {
    // * Check if the message is api message
    if (message is APIMessage) {
      final msg = message as APIMessage;
      if (msg.payload is RecognizedPerson) {
        return UserInfoWidget(person: msg.payload as RecognizedPerson);
      } else if (msg.payload is PatientProfile) {
        return PatientProfileCard(patient: msg.payload as PatientProfile);
      } else if (msg.payload is PatientRelatedMember) {
        return PatientRelatedMemberCard(relatedMember: msg.payload as PatientRelatedMember);
      } else if (msg.payload is FamilyLocation) {
        return FamilyLocationCard(location: msg.payload as FamilyLocation);
      } else if (msg.payload is SecretFile) {
        return SecretFileCard(file: msg.payload as SecretFile);
      } else if (msg.payload is Appointment) {
        return AppointmentCard(appointment: msg.payload as Appointment);
      } else if (msg.payload is Medicine) {
        return MedicineBubble(medicine: msg.payload as Medicine);
      } else if (msg.payload is Media) {
        return MediaCard(media: msg.payload as Media);
      } else if (msg.payload is GameData) {
        return GameDataBubble(gameData: msg.payload as GameData);
      } else {
        return Text(msg.payload.toString());
      }
    }
    // * Normal messages
    switch (message.type) {
      case MessageType.text:
        if (message.sender == SenderType.announcement) {
          // Announcement bubble
          return ActionAnnouncementBubble(content: message.content);
        } else {
          // Normal text bubble from user or bot
          return BubbleSpecialThree(
            text: message.content,
            color: message.isMe ? Colors.blue : const Color(0xFFE8E8EE),
            isSender: message.isMe,
            tail: showTail,
            textStyle: TextStyle(color: message.isMe ? Colors.white : Colors.black, fontSize: 15.0),
          );
        }
      case MessageType.image:
        // Image bubble
        return BubbleNormalImage(id: message.content.hashCode.toString(), image: Image.file(File(message.content)));
      default:
        return Container();
    }
  }
}

class UserInfoWidget extends StatelessWidget {
  final RecognizedPerson person;

  const UserInfoWidget({super.key, required this.person});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipOval(
                child: SizedBox(
                  width: 200,
                  height: 200,
                  child: Image.network(
                    person.familyAvatarUrl,
                    isAntiAlias: true,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              person.familyName,
              style: const TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Relation: ${person.relation}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 2),
            Text(
              'Phone Number: ${person.familyPhoneNumber}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 2),
            Text(
              'Description: ${person.descriptionOfPatient}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'Location:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Latitude: ${person.familyLatitude}',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Longitude: ${person.familyLongitude}',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class PatientProfileCard extends StatelessWidget {
  final PatientProfile patient;

  const PatientProfileCard({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Align(
        alignment: Alignment.centerRight,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 4,
          color: Colors.lightGreen.shade800,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patient.message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Name: ${patient.fullName}',
                  style: const TextStyle(color: Colors.white),
                ),
                Text(
                  'Age: ${patient.age}',
                  style: const TextStyle(color: Colors.white),
                ),
                Text(
                  'Phone Number: ${patient.phoneNumber}',
                  style: const TextStyle(color: Colors.white),
                ),
                Text(
                  'Diagnosis Date: ${DateFormat('dd MMM yyyy').format(patient.diagnosisDate)}',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PatientRelatedMemberCard extends StatelessWidget {
  final PatientRelatedMember relatedMember;

  const PatientRelatedMemberCard({super.key, required this.relatedMember});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Align(
        alignment: Alignment.centerRight,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 4,
          color: Colors.black54,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: ClipOval(
                    child: SizedBox(
                      width: 100,
                      height: 100,
                      child: Image.network(
                        relatedMember.hisImageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  relatedMember.familyName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Relation: ${relatedMember.relation}',
                  style: const TextStyle(color: Colors.white),
                ),
                Text(
                  'Description: ${relatedMember.familyDescriptionForPatient}',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FamilyLocationCard extends StatelessWidget {
  final FamilyLocation location;

  const FamilyLocationCard({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.blue[100],
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Location',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            Text('Latitude: ${location.latitude.toStringAsFixed(7)}'),
            Text('Longitude: ${location.longitude.toStringAsFixed(7)}'),
          ],
        ),
      ),
    );
  }
}

class SecretFileCard extends StatelessWidget {
  final SecretFile file;

  const SecretFileCard({super.key, required this.file});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              file.documentUrl != null
                  ? file.needToConfirm
                      ? const Text(
                          "You can't view this file",
                          style: TextStyle(fontSize: 14, color: Colors.red),
                        )
                      : Image.network(
                          file.documentUrl!,
                          fit: BoxFit.cover,
                          height: 200,
                          width: double.infinity,
                        )
                  : Container(),
              const SizedBox(height: 8),
              Text(
                file.fileName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Description: ${file.fileDescription}',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                'Needs Confirmation: ${file.needToConfirm ? 'Yes' : 'No'}',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;

  const AppointmentCard({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('yyyy-MM-dd HH:mm').format(appointment.date),
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                appointment.location,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                'Notes: ${appointment.notes}',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                'Created by: ${appointment.familyNameWhoCreatedAppointment}',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
              // Text(
              //   'Can be deleted: ${appointment.canDeleted ? 'Yes' : 'No'}',
              //   style: TextStyle(fontSize: 14, color: appointment.canDeleted ? Colors.green : Colors.red),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

class MedicineBubble extends StatelessWidget {
  final Medicine medicine;

  const MedicineBubble({super.key, required this.medicine});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.blue[100],
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Medicine Details',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12.0),
            Text('Medication Name: ${medicine.medicationName}'),
            const SizedBox(height: 8.0),
            Text('Dosage: ${medicine.dosage}'),
            Text('Medicine Type: ${medicine.medicineType.name}'),
            Text('Repeater: ${medicine.repeater.name}'),
            Text('Start Date: ${DateFormat('yyyy-MM-dd HH:mm').format(medicine.startDate)}'),
            Text('End Date: ${DateFormat('yyyy-MM-dd HH:mm').format(medicine.endDate)}'),
          ],
        ),
      ),
    );
  }
}

class MediaCard extends StatelessWidget {
  final Media media;

  const MediaCard({super.key, required this.media});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                media.caption,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                DateFormat('yyyy-MM-dd HH:mm').format(media.uploadedDate),
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                media.familyNameWhoUpload,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
              if (media.mediaExtension == ".jpeg" || media.mediaExtension == ".png")
                Center(
                  child: Image.network(
                    media.mediaUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Text("Failed to load image");
                    },
                  ),
                )
              else
                const Text(
                  "Unsupported media type",
                  style: TextStyle(color: Colors.red),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class GameDataBubble extends StatelessWidget {
  final GameData gameData;

  const GameDataBubble({super.key, required this.gameData});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.blue[100],
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Game Data',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            Text('Current Score: ${gameData.score.currentScore}'),
            Text('Max Score: ${gameData.score.maxScore}'),
            Text('Recommended Difficulty: ${gameData.recommendedGameDifficulty}'),
          ],
        ),
      ),
    );
  }
}
