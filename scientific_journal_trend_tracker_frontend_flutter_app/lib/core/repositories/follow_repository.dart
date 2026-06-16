import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/network_provider.dart';
import '../constants/api_constants.dart';

final followRepositoryProvider = Provider<FollowRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return FollowRepository(dio);
});

class FollowRepository {
  final Dio _dio;

  FollowRepository(this._dio);

  Future<List<dynamic>> getFollows() async {
    try {
      final response = await _dio.get(ApiConstants.follows);
      return (response.data['data'] as List?) ?? [];
    } catch (e) {
      rethrow;
    }
  }

  Future<void> follow(String targetType, String targetId) async {
    try {
      await _dio.post(ApiConstants.follows, data: {
        'targetType': targetType,
        'targetId': targetId,
        'notifyEnabled': true,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> unfollow(String targetId) async {
    try {
      await _dio.delete('${ApiConstants.follows}/$targetId');
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getTrackedRuns() async {
    try {
      final response = await _dio.get('${ApiConstants.follows}/tracked-runs');
      return (response.data['data'] as List?) ?? [];
    } catch (e) {
      rethrow;
    }
  }

  Future<void> trackRun(String analysisRunId) async {
    try {
      await _dio.post('${ApiConstants.follows}/tracked-runs/$analysisRunId', data: {
        'notifyEnabled': true,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> untrackRun(String analysisRunId) async {
    try {
      await _dio.delete('${ApiConstants.follows}/tracked-runs/$analysisRunId');
    } catch (e) {
      rethrow;
    }
  }
}
