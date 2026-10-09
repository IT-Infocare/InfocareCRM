import '../config/api_endpoints.dart';
import '../config/app_config.dart';
import '../models/api_response.dart';
import '../models/file_attachment_model.dart';
import 'api_service.dart';

class FileService {
  final ApiService _apiService;

  FileService(this._apiService);

  Future<ApiResponse<FileAttachmentModel>> uploadFile({
    required String fileName,
    required String fileType,
    required int fileSize,
    List<int>? fileBytes,
  }) async {
    if (AppConfig.enableMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      final mockAttachment = FileAttachmentModel(
        id: 'file_${DateTime.now().millisecondsSinceEpoch}',
        fileName: fileName,
        fileType: fileType,
        fileSize: fileSize,
        url: 'https://example.com/uploads/$fileName',
        uploadedBy: 'Current User',
        uploadedAt: DateTime.now(),
      );
      return ApiResponse<FileAttachmentModel>(
        success: true,
        message: 'File uploaded successfully',
        data: mockAttachment,
      );
    }

    // Phase 1: Request presigned upload instructions
    final presignResponse = await _apiService.post<Map<String, dynamic>>(
      ApiEndpoints.filePresign,
      data: {
        'file_name': fileName,
        'file_type': fileType,
        'file_size': fileSize,
      },
    );

    if (!presignResponse.success || presignResponse.data == null) {
      return ApiResponse<FileAttachmentModel>(
        success: false,
        message: presignResponse.message ?? 'Failed to get upload instructions',
      );
    }

    final fileId = presignResponse.data!['file_id'] as String;

    // Phase 2: Signal completion to backend
    return _apiService.post<FileAttachmentModel>(
      ApiEndpoints.fileComplete,
      data: {'file_id': fileId},
      fromJson: (json) => FileAttachmentModel.fromJson(json as Map<String, dynamic>),
    );
  }
}
