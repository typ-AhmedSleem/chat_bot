class ApiHelper {
  static const String baseUrl = "https://CHATBOT.io/";
  static String parseUri(String endpoint) {
    return "$baseUrl/$endpoint";
  }
}

const String baseUrl = "https://CHATBOT.io/";
String parseUri(String endpoint) {
  return "$baseUrl$endpoint";
}
