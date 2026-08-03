import 'dart:io';
import 'package:dio/dio.dart';
import '../core/network/api_client.dart';
import '../models/provider.dart';

class ProviderService {
  final _dio = ApiClient.instance.dio;

  Future<List<ProviderItem>> fetchProviders({
    String? search,
    String? extensionService,
    double? lat,
    double? lng,
  }) async {
    final response = await _dio.get('/providers', queryParameters: {
      if (search != null && search.isNotEmpty) 'search': search,
      if (extensionService != null && extensionService.isNotEmpty) 'extension_service': extensionService,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
    });
    final items = response.data['data'] as List<dynamic>;
    return items.map((e) => ProviderItem.fromJson(e)).toList();
  }

  /// GET /api/extension-services -- reference data for the filter chips,
  /// same list Admin\ExtensionServiceManager.php manages on the web.
  Future<List<String>> fetchExtensionServiceNames() async {
    final response = await _dio.get('/extension-services');
    final items = response.data as List<dynamic>;
    return items.map((e) => e['name'].toString()).toList();
  }

  Future<ProviderItem> fetchProvider(int id) async {
    final response = await _dio.get('/providers/$id');
    return ProviderItem.fromJson(response.data);
  }

  /// GET /api/my-worker-profile -- null if the user hasn't set one up yet.
  Future<ProviderItem?> fetchMyProfile() async {
    final response = await _dio.get('/my-worker-profile');
    if (response.data == null) return null;
    // Backend doesn't nest 'user' on this endpoint the way /providers/{id}
    // does, so re-wrap it in the shape ProviderItem.fromJson expects.
    return ProviderItem.fromJson({...response.data as Map<String, dynamic>, 'user': null});
  }

  Future<ProviderItem> updateMyProfile({
    String? bio,
    String? briefProfile,
    String? extensionService,
    String? whatsappNumber,
    File? image,
    List<int>? tagIds,
  }) async {
    final formData = FormData.fromMap({
      if (bio != null) 'bio': bio,
      if (briefProfile != null) 'brief_profile': briefProfile,
      if (extensionService != null) 'extension_service': extensionService,
      if (whatsappNumber != null) 'whatsapp_number': whatsappNumber,
      if (tagIds != null) 'tags[]': tagIds,
      if (image != null) 'image': await MultipartFile.fromFile(image.path),
      '_method': 'PUT',
    });
    // PHP doesn't populate $_POST/$_FILES for PUT requests with multipart
    // bodies, so this rides in as POST with a Laravel _method override,
    // same pattern as the other multipart update calls in this app.
    final response = await _dio.post('/my-worker-profile', data: formData);
    return ProviderItem.fromJson({...response.data as Map<String, dynamic>, 'user': null});
  }
}
