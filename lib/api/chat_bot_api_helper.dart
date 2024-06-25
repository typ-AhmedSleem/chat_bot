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

List<T> resolveJsonList<T>(List<dynamic> jsons, {required T Function(Map<String, dynamic> json) process}) {
  print("resolveJsonList: type= ${jsons[0].runtimeType}, jsons= $jsons");
  final List<T> list = List.empty(growable: true);
  for (Map<String, dynamic> json in jsons) {
    list.add(process(json));
  }
  return list;
}
