import '../core/network/api_client.dart';
import '../models/marketplace.dart';

class MarketplaceService {
  final _dio = ApiClient.instance.dio;

  Future<List<Product>> fetchProducts({String? search}) async {
    final response = await _dio.get('/products', queryParameters: {
      if (search != null && search.isNotEmpty) 'search': search,
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
}
