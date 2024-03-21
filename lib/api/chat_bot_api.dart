import "dart:convert";
import "package:http/http.dart" as http;
import "chat_bot_api_helper.dart" as helper;

class Auth {
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

    // Return true if request success (code = 200), false otherwise
    return response.statusCode == 200;
  }
}
