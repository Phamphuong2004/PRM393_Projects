import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../network/dio_client.dart';

final dioProvider = Provider<Dio>((ref) {
  final storage = const FlutterSecureStorage();
  final dioClient = DioClient(storage);
  return dioClient.dio;
});
