import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/network_provider.dart';
import '../constants/api_constants.dart';
import '../models/workspace.dart';

final workspaceRepositoryProvider = Provider<WorkspaceRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return WorkspaceRepository(dio);
});

class WorkspaceRepository {
  final Dio _dio;

  WorkspaceRepository(this._dio);

  Future<List<Workspace>> getWorkspaces({int page = 1, int limit = 20}) async {
    try {
      final response = await _dio.get('${ApiConstants.workspaces}?page=$page&limit=$limit');
      final data = response.data['data'] as List;
      return data.map((e) => Workspace.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Workspace> createWorkspace(String name, String description, String visibility) async {
    try {
      final response = await _dio.post(ApiConstants.workspaces, data: {
        'name': name,
        'description': description,
        'visibility': visibility,
      });
      return Workspace.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> uploadPaperPdf({
    required String workspaceId,
    required String paperId,
    required File pdfFile,
  }) async {
    try {
      String fileName = pdfFile.path.split('/').last;
      if (!fileName.toLowerCase().endsWith('.pdf')) {
        throw Exception('Only PDF files are allowed');
      }

      FormData formData = FormData.fromMap({
        "pdf": await MultipartFile.fromFile(
          pdfFile.path,
          filename: fileName,
        ),
      });

      final response = await _dio.post(
        '${ApiConstants.workspaces}/$workspaceId/papers/$paperId/pdf',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );
      
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to upload PDF');
      } else {
        throw Exception('Network error while uploading PDF');
      }
    } catch (e) {
      rethrow;
    }
  }
}
