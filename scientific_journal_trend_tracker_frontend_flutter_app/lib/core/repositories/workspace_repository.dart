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

  Future<Map<String, dynamic>> getWorkspaceDetails(String id) async {
    try {
      final response = await _dio.get('${ApiConstants.workspaces}/$id');
      return response.data['data'];
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getWorkspacePapers(String id, {int page = 1, int limit = 20}) async {
    try {
      final response = await _dio.get('${ApiConstants.workspaces}/$id/papers?page=$page&limit=$limit');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addPaperToWorkspace(String id, String paperId) async {
    try {
      await _dio.post('${ApiConstants.workspaces}/$id/papers', data: {'paper': paperId});
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addWorkspaceMember(String id, String email, String role) async {
    try {
      await _dio.post('${ApiConstants.workspaces}/$id/members', data: {'email': email, 'role': role});
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getWorkspaceNotes(String id) async {
    try {
      final response = await _dio.get('${ApiConstants.workspaces}/$id/notes');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createWorkspaceNote(String id, String paperId, String content) async {
    try {
      await _dio.post('${ApiConstants.workspaces}/$id/notes', data: {'paperId': paperId, 'content': content});
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getWorkspaceAlerts(String id) async {
    try {
      final response = await _dio.get('${ApiConstants.workspaces}/$id/alerts');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createWorkspaceAlert(String id, String query, String frequency) async {
    try {
      await _dio.post('${ApiConstants.workspaces}/$id/alerts', data: {'query': query, 'frequency': frequency});
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
