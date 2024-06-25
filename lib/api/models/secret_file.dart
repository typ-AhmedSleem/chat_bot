class SecretFile {
  final String secretId;
  final String fileName;
  final String fileDescription;
  final String? documentUrl;
  final String? documentExtension;
  final bool needToConfirm;

  SecretFile({
    required this.secretId,
    required this.fileName,
    required this.fileDescription,
    this.documentUrl,
    this.documentExtension,
    required this.needToConfirm,
  });

  factory SecretFile.fromJson(Map<String, dynamic> json) {
    return SecretFile(
      secretId: json['secretId'],
      fileName: json['fileName'],
      fileDescription: json['file_Description'],
      documentUrl: json['documentUrl'],
      documentExtension: json['documentExtension'],
      needToConfirm: json['needToConfirm'],
    );
  }
}
