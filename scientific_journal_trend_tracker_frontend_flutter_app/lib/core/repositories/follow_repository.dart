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

  // BE returns a bare JSON array (e.g. user.follows / user.trackedRuns), but some
  // endpoints may wrap it. Handle both shapes safely.
  List<dynamic> _asList(dynamic data) {
    if (data is List) return data;
    if (data is Map) {
      final inner = data['data'] ?? data['follows'] ?? data['trackedRuns'];
      if (inner is List) return inner;
    }
    return [];
  }

  Future<List<dynamic>> getFollows() async {
    try {
      final response = await _dio.get(ApiConstants.follows);
      return _asList(response.data);
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
      return _asList(response.data);
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

  Future<void> updateTrackedRunNotification(
    String analysisRunId,
    bool notifyEnabled,
  ) async {
    try {
      await _dio.put(
        '${ApiConstants.follows}/tracked-runs/$analysisRunId/notify',
        data: {'notifyEnabled': notifyEnabled},
      );
    } catch (e) {
      rethrow;
    }
  }
}
