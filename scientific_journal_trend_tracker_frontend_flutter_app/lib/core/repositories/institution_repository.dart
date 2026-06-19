import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/institution.dart';
import '../providers/network_provider.dart';
import '../constants/api_constants.dart';

final institutionRepositoryProvider = Provider<InstitutionRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return InstitutionRepository(dio);
});

class InstitutionRepository {
  final Dio _dio;

  InstitutionRepository(this._dio);

  Future<List<Institution>> getInstitutions({String? search}) async {
    final response = await _dio.get(
      ApiConstants.institutions,
      queryParameters: search != null && search.isNotEmpty ? {'search': search} : null,
    );

    final data = response.data as List;
    return data
        .map((e) => Institution.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
