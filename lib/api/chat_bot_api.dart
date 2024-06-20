// import "dart:convert";
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
}
