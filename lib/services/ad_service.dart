import '../core/network/api_client.dart';
import '../models/ad.dart';

class AdService {
  final _dio = ApiClient.instance.dio;

  Future<List<AdItem>> fetchAds() async {
    final response = await _dio.get('/ads');
    // /api/ads is a plain array (no pagination), unlike /products or /outlets.
    final items = response.data as List<dynamic>;
    return items.map((e) => AdItem.fromJson(e)).toList();
  }
}
