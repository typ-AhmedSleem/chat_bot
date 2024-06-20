import 'dart:convert';

import 'package:chat_bot/api/chat_bot_api_helper.dart';
import 'package:chat_bot/chat_bot_errors.dart';
import 'package:chat_bot/helpers/logger.dart';
import 'package:chat_bot/helpers/texts.dart';
import 'package:http/http.dart' as http;

// import "package:http/http.dart" as http;
// import "chat_bot_api_helper.dart" as helper;

class PatientAPI {
  final helper = ApiHelper("Patient");
  final logger = Logger("PatientAPI");

  Future<String> recognizeFaces({required String imagePath}) async {
    // * Resolve the endpoint
    final endpoint = helper.resolveEndpoint("RecognizeFaces");
    // * Create the request
    final request = http.MultipartRequest('POST', endpoint)..files.add(await http.MultipartFile.fromPath('file', imagePath));
    try {
      // * Send the request
      final response = await request.send();
      // * Handle the response
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final jsonResponse = jsonDecode(responseData);
        logger.log("recognizeFaces[SUCCESS]: Response => '$response'");
        logger.log("recognizeFaces[SUCCESS]: DecodedResponse => '$jsonResponse'");
        return jsonResponse;
      } else {
        // * Request failed
        logger.log("recognizeFaces[FAIL]: Response => '${response.statusCode} | ${response.reasonPhrase}'");
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

  Future<String> getPatientProfile(String patientId) async {
    try {
      final response = await http.get(
          // API endpoint
          helper.resolveEndpoint("GetPatientProfile/$patientId"),
          // Headers
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          });
      // * Handle the response
      if (response.statusCode != 200) throw CBError(code: response.statusCode, message: Texts.cantGetPatientProfile);
      // * Return the response body
      return response.body;
    } catch (e) {
      logger.log("getPatientProfile[ERROR]: $e");
      rethrow;
    }
  }

  Future<String> getPatientRelatedMembers(String patientId) async {
    try {
      final response = await http.get(
        // API endpoint
        helper.resolveEndpoint("GetPatientRelatedMembers/$patientId"),
        // Headers
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      // * Handle the response
      if (response.statusCode != 200) throw CBError(code: response.statusCode, message: Texts.errorOccurredWhileDoingAction);
      // * Return the response body
      return response.body;
    } catch (e) {
      logger.log("getPatientRelatedMembers[ERROR]: $e");
      rethrow;
    }
  }

  Future<bool> updatePatientProfile(String phoneNumber, int age, String diagnosisDate, int maximumDistance) async {
    // * Validate if phone number length is > 1
    if (phoneNumber.isEmpty) throw CBError(message: Texts.invalidPhoneNumber);
    // Make post request
    final response = await http.post(
      // API endpoint
      helper.resolveEndpoint("UpdatePatientProfile"),
      // Headers
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
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
    return response.statusCode == 200;
  }

  Future<String> getFamilyLocation(String familyId) async {
    try {
      final response = await http.get(
          // API endpoint
          helper.resolveEndpoint("GetFamilyLocation/$familyId"),
          // Headers
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          });
      // * Handle the response
      if (response.statusCode != 200) throw CBError(code: response.statusCode, message: Texts.errorOccurredWhileDoingAction);
      // * Return the response body
      return response.body;
    } catch (e) {
      logger.log("getFamilyLocation[ERROR]: $e");
      rethrow;
    }
  }

  Future<bool> markMedicationReminder(String medictaionId, bool isTaken) async {
    // Make post request
    final response = await http.post(
      // API endpoint
      helper.resolveEndpoint("MarkMedicationReminder"),
      // Headers
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      // Request body
      body: jsonEncode(<String, Object>{
        "medictaionId": medictaionId,
        "isTaken": isTaken,
      }),
    );
    // * Return true if request success (code = 200), false otherwise
    return response.statusCode == 200;
  }

// todo: AddSecretFile endpoint hasn't yet been implemented

  Future<bool> askToSeeSecretFile({required String videoPath}) async {
    // * Resolve the endpoint
    final endpoint = helper.resolveEndpoint("AskToSeeSecretFile");
    // * Create the request
    final request = http.MultipartRequest('POST', endpoint)..files.add(await http.MultipartFile.fromPath('file', videoPath));
    try {
      // * Send the request
      final response = await request.send();
      // * Handle the response
      return response.statusCode == 200;
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

  Future<bool> addGameScore(int difficultyGame, int patientScore) async {
    // Make post request
    final response = await http.post(
      // API endpoint
      helper.resolveEndpoint("AddGameScore"),
      // Headers
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      // Request body
      body: jsonEncode(<String, Object>{
        "difficultyGame": difficultyGame,
        "patientScore": patientScore,
      }),
    );
    // * Return true if request success (code = 200), false otherwise
    return response.statusCode == 200;
  }

  Future<dynamic> simpleGetRequest({required String endpoint}) async {
    try {
      final response = await http.get(
          // API endpoint
          helper.resolveEndpoint(endpoint),
          // Headers
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          });
      // * Handle the response
      if (response.statusCode != 200) throw CBError(code: response.statusCode, message: Texts.errorOccurredWhileDoingAction);
      // * Return the response body
      return response.body;
    } catch (e) {
      logger.log("$endpoint[ERROR]: $e");
      rethrow;
    }
  }
}
