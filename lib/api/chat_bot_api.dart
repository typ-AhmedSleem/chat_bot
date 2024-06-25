import 'dart:convert';
import 'dart:io';

import 'package:chat_bot/api/chat_bot_api_helper.dart';
import 'package:chat_bot/api/models/appointment.dart';
import 'package:chat_bot/api/models/game_data.dart';
import 'package:chat_bot/api/models/patient_profile.dart';
import 'package:chat_bot/api/models/recognized_person.dart';
import 'package:chat_bot/chat_bot_errors.dart';
import 'package:chat_bot/helpers/logger.dart';
import 'package:chat_bot/helpers/texts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'models/family_location.dart';
import 'models/media.dart';
import 'models/medicine.dart';
import 'models/patient_related_member.dart';
import 'models/secret_file.dart';

class PatientAPI {
  final helper = ApiHelper("Patient");
  final logger = Logger("PatientAPI");
  late final String _token;

  PatientAPI({required String token}) {
    _token = token;
  }

  Future<dynamic> simpleGetRequest({required String endpoint}) async {
    try {
      final response = await http.get(
          // API endpoint
          helper.resolveEndpoint(endpoint),
          // Headers
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            "Authorization": _token,
          });
      // * Handle the response
      if (response.statusCode != 200) throw CBError(code: response.statusCode, message: Texts.errorOccurredWhileDoingAction);
      // * Return the response body
      return jsonDecode(response.body);
    } catch (e) {
      logger.log("$endpoint[ERROR]: $e");
      rethrow;
    }
  }

  Future<List<RecognizedPerson>> recognizeFaces(String imagePath) async {
    // * Resolve the endpoint
    final endpoint = helper.resolveEndpoint("RecognizeFaces");
    // * Create the request
    final request = http.MultipartRequest('POST', endpoint)..files.add(await http.MultipartFile.fromPath('Image', imagePath));
    request.headers[HttpHeaders.authorizationHeader] = _token;
    try {
      // * Send the request
      final response = await request.send();
      // * Handle the response
      final responseData = await response.stream.bytesToString();
      logger.log("code: ${response.statusCode}, rawResponse: '${responseData.trim()}'");
      final jsonResponse = decodeJsonResponse(responseData);
      if (response.statusCode == 200) {
        final List<RecognizedPerson> recognizedPersons = List.empty(growable: true);
        for (Map<String, dynamic> rawPerson in jsonResponse["personsInImage"]) {
          try {
            recognizedPersons.add(RecognizedPerson.fromJson(rawPerson));
          } catch (e) {
            logger.log("Resolve person failed with error: $e");
            continue;
          }
        }
        logger.log("Recognized ${recognizedPersons.length} person in the photo.");
        return recognizedPersons;
      } else {
        // * Request failed
        if (response.statusCode == 401) {
          // 401 means: Server refused the request because it's 'Unauthorized'
          throw CBError(message: Texts.serverRefusedTheRequest);
        }
        // Other status codes
        throw CBError(message: Texts.serverFailedToRecognizeFaces);
      }
    } on http.ClientException catch (e) {
      // * Error uploading
      logger.log("recognizeFaces[ERROR]: No internet found. $e");
      throw CBError(message: Texts.noInternetConnection);
    } catch (e) {
      // * Error uploading
      logger.log("recognizeFaces[ERROR]: $e");
      rethrow;
    }
  }

  Future<PatientProfile> getPatientProfile() async {
    try {
      final response = await http.get(
          // API endpoint
          helper.resolveEndpoint("GetPatientProfile"),
          // Headers
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            HttpHeaders.authorizationHeader: _token,
          });
      // * Handle the response
      if (response.statusCode != 200) {
        throw CBError(code: response.statusCode, message: response.body);
      }
      // * Return the response body
      return PatientProfile.fromJson(decodeJsonResponse(response.body));
    } catch (e) {
      logger.log("getPatientProfile[ERROR]: $e");
      rethrow;
    }
  }

  Future<List<PatientRelatedMember>> getPatientRelatedMembers() async {
    try {
      final response = await http.get(
        // API endpoint
        helper.resolveEndpoint("GetPatientRelatedMembers"),
        // Headers
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          HttpHeaders.authorizationHeader: _token,
        },
      );
      // * Handle the response
      if (response.statusCode != 200) throw CBError(code: response.statusCode, message: Texts.errorOccurredWhileDoingAction);
      // * Return the response body
      return resolveJsonList<PatientRelatedMember>(jsonDecode(response.body), process: (json) {
        return PatientRelatedMember.fromJson(json);
      });
    } catch (e) {
      logger.log("getPatientRelatedMembers[ERROR]: $e");
      rethrow;
    }
  }

  Future<String> updatePatientProfile(String phoneNumber, int age, String diagnosisDate, int maximumDistance) async {
    // * Validate if phone number length is > 1
    if (phoneNumber.isEmpty) throw CBError(message: Texts.invalidPhoneNumber);
    // Make post request
    final response = await http.put(
      // API endpoint
      helper.resolveEndpoint("UpdatePatientProfile"),
      // Headers
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: _token,
      },
      // Request body
      body: jsonEncode(<String, Object>{
        "phoneNumber": phoneNumber,
        "age": age,
        "diagnosisDate": diagnosisDate,
        "maximumDistance": maximumDistance,
      }),
    );
    // * Return true if request success (code = 200), false otherwise
    final decodedResponse = decodeJsonResponse(response.body);
    if ((response.statusCode == 200)) {
      return decodedResponse["message"];
    } else {
      return decodedResponse["title"];
    }
  }

  Future<FamilyLocation> getFamilyLocation(String familyId) async {
    try {
      final response = await http.get(
          // API endpoint
          helper.resolveEndpoint("GetFamilyLocation/$familyId"),
          // Headers
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            HttpHeaders.authorizationHeader: _token,
          });
      // * Handle the response
      if (response.statusCode != 200) throw CBError(code: response.statusCode, message: response.body);
      // * Return the response body
      return FamilyLocation.fromJson(decodeJsonResponse(response.body)); // todo: double check the json fields.
    } catch (e) {
      logger.log("getFamilyLocation[ERROR]: $e");
      rethrow;
    }
  }

  Future<String> markMedicationReminder(String medictaionId, bool isTaken) async {
    // Make post request
    final response = await http.post(
      // API endpoint
      helper.resolveEndpoint("MarkMedicationReminder"),
      // Headers
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: _token,
      },
      // Request body
      body: jsonEncode(<String, Object>{
        "medictaionId": medictaionId,
        "isTaken": isTaken,
      }),
    );
    // * Return true if request success (code = 200), false otherwise
    if (response.statusCode != 200) {
      return response.body;
    }
    return response.body;
    final decodedResponse = decodeJsonResponse(response.body);
    return decodedResponse["?"]; // ? don't know that success response json look like.
  }

  Future<String> addSecretFile({required String filePath, String? fileDescription}) async {
    final XFile file = XFile(filePath);
    // * Resolve the endpoint
    final endpoint = helper.resolveEndpoint("AddSecretFile");
    // * Create the request
    final request = http.MultipartRequest('POST', endpoint)..files.add(await http.MultipartFile.fromPath('File', filePath));
    request.headers[HttpHeaders.authorizationHeader] = _token;
    request.fields["FileName"] = file.name;
    request.fields["File_Description"] = fileDescription ?? file.name;
    try {
      // * Send the request
      final response = await request.send();
      final rawResponse = await response.stream.bytesToString();
      // * Handle the response
      return rawResponse;
    } on http.ClientException catch (e) {
      // * Error uploading
      logger.log("addSecretFile[ERROR]: No internet found. $e");
      throw CBError(message: Texts.noInternetConnection);
    } catch (e) {
      // * Error uploading
      logger.log("addSecretFile[ERROR]: $e");
      rethrow;
    }
  }

  Future<String> askToSeeSecretFile({required String videoPath}) async {
    // * Resolve the endpoint
    final endpoint = helper.resolveEndpoint("AskToSeeSecretFile");
    // * Create the request
    final request = http.MultipartRequest('POST', endpoint)..files.add(await http.MultipartFile.fromPath('Video', videoPath));
    request.headers[HttpHeaders.authorizationHeader] = _token;
    try {
      // * Send the request
      final response = await request.send();
      // * Handle the response
      return response.stream.bytesToString();
    } on http.ClientException catch (e) {
      // * Error uploading
      logger.log("askToSeeSecretFile[ERROR]: No internet found. $e");
      throw CBError(message: Texts.noInternetConnection);
    } catch (e) {
      // * Error uploading
      logger.log("askToSeeSecretFile[ERROR]: $e");
      rethrow;
    }
  }

  Future<String> addGameScore(int difficultyGame, int patientScore) async {
    // Make post request
    final response = await http.post(
      // API endpoint
      helper.resolveEndpoint("AddGameScore"),
      // Headers
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: _token,
      },
      // Request body
      body: jsonEncode(<String, Object>{
        "difficultyGame": difficultyGame,
        "patientScore": patientScore,
      }),
    );
    // * Return true if request success (code = 200), false otherwise
    final decoded = jsonDecode(response.body);
    if (response.statusCode == 200) return decoded["message"];
    return decoded["title"];
  }

  Future<List<SecretFile>> getSecretFile() async {
    final jsons = (await simpleGetRequest(endpoint: "GetSecretFile"))["secretFiles"];
    return resolveJsonList<SecretFile>(jsons, process: (json) {
      return SecretFile.fromJson(json);
    });
  }

  Future<List<Appointment>> getAllAppointments() async {
    final jsons = await simpleGetRequest(endpoint: "GetAllAppointments");
    return resolveJsonList<Appointment>(jsons, process: (json) {
      return Appointment.fromJson(json);
    });
  }

  Future<List<Medicine>> getAllMedicines() async {
    final jsons = await simpleGetRequest(endpoint: "GetAllMedicines");
    return resolveJsonList<Medicine>(jsons, process: (json) {
      return Medicine.fromJson(json);
    });
  }

  Future<List<Media>> getMedia() async {
    final jsons = await simpleGetRequest(endpoint: "GetMedia");
    return resolveJsonList<Media>(jsons, process: (json) {
      return Media.fromJson(json);
    });
  }

  Future<Map<String, dynamic>> getAllGameScores() async {
    // ! Has no class and no UI
    return await simpleGetRequest(endpoint: "GetAllGameScores");
  }

  Future<GameData> getCurrentAndMaxScore() async {
    final json = await simpleGetRequest(endpoint: "GetCurrentAndMaxScore");
    return GameData.fromJson(json);
  }
}

class ApiRunner {
  static Future<void> run<T>({String? name, Function? onStart, required Future<T> Function() runner, required Function(T) onSuccess, required Function(CBError) onFail, Function? onFinish}) async {
    try {
      if (onStart != null) await onStart();
      await onSuccess(await runner());
    } catch (e) {
      print("Error while running api '${name ?? ""}': ${e is! CBError ? CBError(message: e.toString()) : e}");
      await onFail(CBError(message: Texts.errorOccurredWhileDoingAction));
    } finally {
      if (onFinish != null) await onFinish();
    }
  }
}
