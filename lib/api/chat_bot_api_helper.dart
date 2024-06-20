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
