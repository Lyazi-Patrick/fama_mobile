import 'dart:io';
import 'package:dio/dio.dart';
import '../core/network/api_client.dart';
import '../models/service.dart';

class ServiceApiService {
  final _dio = ApiClient.instance.dio;

  Future<List<ServiceItem>> fetchServices({String? search}) async {
    final response = await _dio.get('/services', queryParameters: {
      if (search != null && search.isNotEmpty) 'search': search,
    });
    final items = response.data['data'] as List<dynamic>;
    return items.map((e) => ServiceItem.fromJson(e)).toList();
  }

  /// GET /api/my-services -- all of the caller's own services, any status.
  Future<List<ServiceItem>> fetchMyServices() async {
    final response = await _dio.get('/my-services');
    final items = response.data as List<dynamic>;
    return items.map((e) => ServiceItem.fromJson(e)).toList();
  }

  Future<ServiceItem> createService({
    required String name,
    String? description,
    File? image,
    List<int> tagIds = const [],
  }) async {
    final formData = FormData.fromMap({
      'name': name,
      if (description != null) 'description': description,
      if (tagIds.isNotEmpty) 'tags[]': tagIds,
      if (image != null) 'image': await MultipartFile.fromFile(image.path),
    });
    final response = await _dio.post('/services', data: formData);
    return ServiceItem.fromJson(response.data);
  }

  Future<ServiceItem> updateService(
    int id, {
    String? name,
    String? description,
    File? image,
    List<int>? tagIds,
  }) async {
    final formData = FormData.fromMap({
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (tagIds != null) 'tags[]': tagIds,
      if (image != null) 'image': await MultipartFile.fromFile(image.path),
      '_method': 'PUT',
    });
    final response = await _dio.post('/services/$id', data: formData);
    return ServiceItem.fromJson(response.data);
  }

  Future<void> deleteService(int id) => _dio.delete('/services/$id');
}
