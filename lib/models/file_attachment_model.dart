class FileAttachmentModel {
  final String id;
  final String fileName;
  final String fileType; // 'photo', 'drawing', 'pdf', 'datasheet', 'other'
  final int fileSize;
  final String url;
  final String uploadedBy;
  final DateTime uploadedAt;

  FileAttachmentModel({
    required this.id,
    required this.fileName,
    required this.fileType,
    required this.fileSize,
    required this.url,
    required this.uploadedBy,
    required this.uploadedAt,
  });

  factory FileAttachmentModel.fromJson(Map<String, dynamic> json) {
    return FileAttachmentModel(
      id: json['id'] as String? ?? '',
      fileName: json['file_name'] as String? ?? '',
      fileType: json['file_type'] as String? ?? 'other',
      fileSize: (json['file_size'] as int?) ?? 0,
      url: json['url'] as String? ?? '',
      uploadedBy: json['uploaded_by'] as String? ?? 'System',
      uploadedAt: json['uploaded_at'] != null
          ? DateTime.tryParse(json['uploaded_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'file_name': fileName,
      'file_type': fileType,
      'file_size': fileSize,
      'url': url,
      'uploaded_by': uploadedBy,
      'uploaded_at': uploadedAt.toIso8601String(),
    };
  }
}
