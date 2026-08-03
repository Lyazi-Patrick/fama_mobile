import 'dart:io';
import 'package:dio/dio.dart';
import '../core/network/api_client.dart';
import '../models/marketplace.dart';

class MarketplaceService {
  final _dio = ApiClient.instance.dio;

  Future<List<Product>> fetchProducts({String? search, String? tag}) async {
    final response = await _dio.get('/products', queryParameters: {
      if (search != null && search.isNotEmpty) 'search': search,
      if (tag != null && tag.isNotEmpty) 'tag': tag,
    });
    final items = response.data['data'] as List<dynamic>;
    return items.map((e) => Product.fromJson(e)).toList();
  }

  Future<List<Outlet>> fetchOutlets({double? lat, double? lng}) async {
    final response = await _dio.get('/outlets', queryParameters: {
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
    });
    final items = response.data['data'] as List<dynamic>;
    return items.map((e) => Outlet.fromJson(e)).toList();
  }

  /// GET /api/products/{id} -- unlike the list endpoint, this returns the
  /// raw product object directly (not wrapped in a paginated 'data' key).
  Future<Product> fetchProduct(int id) async {
    final response = await _dio.get('/products/$id');
    return Product.fromJson(response.data);
  }

  /// GET /api/outlets/{id} -- includes the outlet's own products + tags.
  Future<Outlet> fetchOutlet(int id) async {
    final response = await _dio.get('/outlets/$id');
    return Outlet.fromJson(response.data);
  }

  // ---- Dealer management (My Outlets / Add Product) ----

  Future<List<Outlet>> fetchMyOutlets() async {
    final response = await _dio.get('/my-outlets');
    final items = response.data as List<dynamic>;
    return items.map((e) => Outlet.fromJson(e)).toList();
  }

  Future<Outlet> createOutlet({
    required String name,
    String? description,
    required double latitude,
    required double longitude,
    String? contact,
    String? email,
  }) async {
    final response = await _dio.post('/outlets', data: {
      'name': name,
      if (description != null) 'description': description,
      'latitude': latitude,
      'longitude': longitude,
      if (contact != null) 'contact': contact,
      if (email != null) 'email': email,
    });
    return Outlet.fromJson(response.data);
  }

  Future<Outlet> updateOutlet(
    int id, {
    String? name,
    String? description,
    double? latitude,
    double? longitude,
    String? contact,
    String? email,
  }) async {
    final response = await _dio.put('/outlets/$id', data: {
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (contact != null) 'contact': contact,
      if (email != null) 'email': email,
    });
    return Outlet.fromJson(response.data);
  }

  Future<void> deleteOutlet(int id) => _dio.delete('/outlets/$id');

  Future<Product> createProduct({
    required int outletId,
    required String name,
    String? description,
    required double price,
    File? image,
    List<int> tagIds = const [],
  }) async {
    final formData = FormData.fromMap({
      'name': name,
      if (description != null) 'description': description,
      'price': price,
      if (tagIds.isNotEmpty) 'tags[]': tagIds,
      if (image != null) 'image': await MultipartFile.fromFile(image.path),
    });
    final response = await _dio.post('/outlets/$outletId/products', data: formData);
    return Product.fromJson(response.data);
  }

  Future<Product> updateProduct(
    int id, {
    String? name,
    String? description,
    double? price,
    File? image,
    List<int>? tagIds,
  }) async {
    final formData = FormData.fromMap({
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (price != null) 'price': price,
      if (tagIds != null) 'tags[]': tagIds,
      if (image != null) 'image': await MultipartFile.fromFile(image.path),
    });
    // Laravel doesn't parse multipart bodies on PUT -- use POST + _method
    // override, the standard Laravel-recognized way to multipart-update.
    formData.fields.add(const MapEntry('_method', 'PUT'));
    final response = await _dio.post('/products/$id', data: formData);
    return Product.fromJson(response.data);
  }

  Future<void> deleteProduct(int id) => _dio.delete('/products/$id');
}
