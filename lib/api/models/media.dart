class Media {
  final String mediaId;
  final DateTime uploadedDate;
  final String caption;
  final String mediaUrl;
  final String mediaExtension;
  final String familyNameWhoUpload;

  Media({
    required this.mediaId,
    required this.uploadedDate,
    required this.caption,
    required this.mediaUrl,
    required this.mediaExtension,
    required this.familyNameWhoUpload,
  });

  factory Media.fromJson(Map<String, dynamic> json) {
    return Media(
      mediaId: json['mediaId'],
      uploadedDate: DateTime.parse(json['uploaded_date']),
      caption: json['caption'],
      mediaUrl: json['mediaUrl'],
      mediaExtension: json['mediaExtension'],
      familyNameWhoUpload: json['familyNameWhoUpload'],
    );
  }
}
