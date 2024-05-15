import "dart:convert";
import "package:chat_bot/logger.dart";
import "package:http/http.dart" as http;
import "chat_bot_api_helper.dart" as helper;


class Auth {

  final logger = Logger("Auth");

  Future<bool> register(String fullName, String username, String email,
      String password, String role, String phoneNumber, int age) async {
    // Make post request
    final response = await http.post(
      // Request url endpoint
      Uri.parse(helper.parseUri("/api/Authentication/Register")),
      // Request headers
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      // Request body
      body: jsonEncode(<String, String>{
        "fullName": fullName,
        "username": username,
        "email": email,
        "password": password,
        "role": role,
        "phoneNumber": phoneNumber,
        "age": age.toString()
      }),
    );

    logger.log(response.body);

    // Return true if request success (code = 200), false otherwise
    return response.statusCode == 200;
  }

  Future<bool> login(String email, String password) async {
    // Make post request
    final response = await http.post(
      // Request url endpoint
      Uri.parse(helper.parseUri("/api/Authentication/Login")),
      // Request headers
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      // Request body
      body: jsonEncode(<String, String>{
        "email": email,
        "password": password,
      }),
    );

    logger.log(response.body);

    // Return true if request success (code = 200), false otherwise
    return response.statusCode == 200;
  }

  Future<bool> confirmEmail(String userId, String token) async {
    throw UnimplementedError("Not yet implemented");
    // Make post request
    final response = await http.get(
        // Request url endpoint
        Uri.parse(helper.parseUri("/api/Authentication/ConfirmEmail")),
        // Request headers
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        });

        logger.log(response.body);

    // Return true if request success (code = 200), false otherwise
    return response.statusCode == 200;
  }

  Future<bool> resetPassword(String email, String token, String newPass,
      String confirmPassword) async {
    // Make post request
    final response = await http.post(
      // Request url endpoint
      Uri.parse(helper.parseUri("/api/Authentication/ResetPassword")),
      // Request headers
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      // Request body
      body: jsonEncode(<String, String>{
        "Email": email,
        "Token": token,
        "NewPassWord": newPass,
        "ConfirmPassword": confirmPassword
      }),
    );

    logger.log(response.body);

    // Return true if request success (code = 200), false otherwise
    return response.statusCode == 200;
  }

  Future<bool> forgetPassword(String email) async {
    throw UnimplementedError("Not yet implemented");
    // Make post request
    final response = await http.post(
      // Request url endpoint
      Uri.parse(helper.parseUri("/api/Authentication/ForgetPassword")),
      // Request headers
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      // Request body
      body: jsonEncode(<String, String>{
        "email": email,
      }),
    );

    logger.log(response.body);

    // Return true if request success (code = 200), false otherwise
    return response.statusCode == 200;
  }

  Future<bool> changePassword(String email, String oldPassword,
      String newPassword, String confirmPassword) async {
    // Make post request
    final response = await http.put(
      // Request url endpoint
      Uri.parse(helper.parseUri("/api/Authentication/ChangePassword")),
      // Request headers
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      // Request body
      body: jsonEncode(<String, String>{
        "email": email,
        "oldPassword": oldPassword,
        "newPassword": newPassword,
        "confirmNewPassword": confirmPassword
      }),
    );

    logger.log(response.body);

    // Return true if request success (code = 200), false otherwise
    return response.statusCode == 200;
  }
}
