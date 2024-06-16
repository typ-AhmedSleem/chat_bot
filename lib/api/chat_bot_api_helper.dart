class ApiHelper {
  static const String baseUrl =
      "https://electronicmindofalzheimerpatients.azurewebsites.net";

  static String parseUri(String endpoint) {
    return "$baseUrl/$endpoint";
  }
}

const String baseUrl =
    "https://electronicmindofalzheimerpatients.azurewebsites.net";

String parseUri(String endpoint) {
  return "$baseUrl$endpoint";
}
