import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/network_provider.dart';
import '../constants/api_constants.dart';
import '../models/workspace.dart';
import '../models/paper.dart';

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

  Future<void> addPaperToWorkspace(String id, Paper paper) async {
    try {
      final isMongoId = RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(paper.id);
      if (isMongoId) {
        await _dio.post('${ApiConstants.workspaces}/$id/papers', data: {'paperId': paper.id});
      } else {
        // External paper: clean the payload so Mongoose doesn't choke on
        // non-ObjectId _id values in the root doc or nested author objects.
        final paperJson = paper.toJson();
        paperJson.remove('_id');          // root _id
        paperJson.remove('createdAt');
        paperJson.remove('updatedAt');

        // Clean authors: remove _id if null/invalid ObjectId
        final mongoIdRe = RegExp(r'^[0-9a-fA-F]{24}$');
        if (paperJson['authors'] is List) {
          paperJson['authors'] = (paperJson['authors'] as List).map((a) {
            if (a is Map) {
              final m = Map<String, dynamic>.from(a);
              final authorId = m['_id']?.toString() ?? '';
              if (!mongoIdRe.hasMatch(authorId)) m.remove('_id');
              return m;
            }
            return a;
          }).toList();
        }

        await _dio.post('${ApiConstants.workspaces}/$id/papers', data: {'paper': paperJson});
      }
    } on DioException catch (e) {
      final serverMsg = e.response?.data?['message']?.toString() ?? '';
      switch (e.response?.statusCode) {
        case 403:
          throw Exception('You don\'t have permission to add papers to this workspace.');
        case 409:
          throw Exception('This paper is already in the workspace.');
        default:
          if (serverMsg.contains('E11000') || serverMsg.contains('duplicate key')) {
            throw Exception('This paper already exists in the database. It may have been added from another source.');
          } else if (serverMsg.contains('validation failed')) {
            throw Exception('Could not save this paper — some fields were incompatible. Try a paper from Local Database instead.');
          }
          throw Exception(serverMsg.isNotEmpty ? serverMsg : 'Failed to add paper. Please check your connection.');
      }
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
      final data = <String, dynamic>{'content': content};
      final mongoIdRe = RegExp(r'^[0-9a-fA-F]{24}$');
      if (mongoIdRe.hasMatch(paperId)) data['paperId'] = paperId;
      await _dio.post('${ApiConstants.workspaces}/$id/notes', data: data);
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
