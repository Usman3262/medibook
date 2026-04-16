import 'package:dio/dio.dart';
import '../error/exceptions.dart';

class CloudflareR2Client {
  late final Dio _dio;
  final String accountId;
  final String accessKeyId;
  final String secretAccessKey;
  final String bucketName;

  CloudflareR2Client({
    required this.accountId,
    required this.accessKeyId,
    required this.secretAccessKey,
    required this.bucketName,
  }) {
    final baseUrl = 'https://$accountId.r2.cloudflarestorage.com';
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );
  }

  /// Upload file to R2
  Future<String> uploadFile({
    required String filePath,
    required List<int> fileBytes,
    required String fileName,
    String? contentType,
  }) async {
    try {
      final response = await _dio.put(
        '/$bucketName/$filePath',
        data: fileBytes,
        options: Options(
          headers: {
            'Authorization': _buildAuthHeader('PUT', filePath),
            'Content-Type': contentType ?? 'application/octet-stream',
          },
        ),
      );

      if (response.statusCode == 200) {
        return _buildFileUrl(filePath);
      } else {
        throw ServerException(
          message: 'Failed to upload file: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Download file from R2
  Future<List<int>> downloadFile(String filePath) async {
    try {
      final response = await _dio.get<List<int>>(
        '/$bucketName/$filePath',
        options: Options(
          headers: {
            'Authorization': _buildAuthHeader('GET', filePath),
          },
          responseType: ResponseType.bytes,
        ),
      );

      if (response.statusCode == 200) {
        return response.data ?? [];
      } else {
        throw ServerException(
          message: 'Failed to download file: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Delete file from R2
  Future<void> deleteFile(String filePath) async {
    try {
      final response = await _dio.delete(
        '/$bucketName/$filePath',
        options: Options(
          headers: {
            'Authorization': _buildAuthHeader('DELETE', filePath),
          },
        ),
      );

      if (response.statusCode != 204) {
        throw ServerException(
          message: 'Failed to delete file: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get public URL for file
  String getPublicUrl(String filePath) {
    return _buildFileUrl(filePath);
  }

  String _buildFileUrl(String filePath) {
    return 'https://$bucketName.example.r2.dev/$filePath';
  }

  String _buildAuthHeader(String method, String filePath) {
    // Note: This is a simplified version. For production, use AWS Signature v4
    // with proper date and host headers
    return 'AWS4-HMAC-SHA256 Credential=$accessKeyId, SignedHeaders=host;x-amz-date, Signature=...';
  }

  AppException _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException(message: 'Connection timeout');
      case DioExceptionType.badResponse:
        return ServerException(
          message: 'Server error: ${error.response?.statusCode}',
        );
      case DioExceptionType.cancel:
        return ServerException(message: 'Request cancelled');
      default:
        return UnexpectedException(message: 'Unexpected error: ${error.message}');
    }
  }
}
