import 'dart:convert';

class ApiHelper {
  final String baseUrl = "https://electronicmindofalzheimerpatients.azurewebsites.net";
  final String baseAPI;

  ApiHelper(this.baseAPI);

  String endpointLink(String endpoint) {
    return "$baseUrl/$baseAPI/$endpoint";
  }

  Uri resolveEndpoint(String endpoint) {
    return Uri.parse(endpointLink(endpoint));
  }
}

Map<String, dynamic> decodeJsonResponse(String rawJson) {
  final json = rawJson.trim();
  if (json.isEmpty) return <String, dynamic>{};
  return jsonDecode(json) as Map<String, dynamic>;
}
