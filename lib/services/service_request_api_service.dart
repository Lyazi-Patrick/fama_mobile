import '../core/network/api_client.dart';
import '../models/service_request.dart';

class ServiceRequestApiService {
  final _dio = ApiClient.instance.dio;

  Future<List<ServiceRequestItem>> fetchMine() async {
    final response = await _dio.get('/service-requests/mine');
    final items = response.data['data'] as List<dynamic>;
    return items.map((e) => ServiceRequestItem.fromJson(e)).toList();
  }

  Future<List<ServiceRequestItem>> fetchIncoming() async {
    final response = await _dio.get('/service-requests/incoming');
    final items = response.data['data'] as List<dynamic>;
    return items.map((e) => ServiceRequestItem.fromJson(e)).toList();
  }

  Future<ServiceRequestItem> create({
    required int extensionWorkerId,
    required String description,
  }) async {
    final response = await _dio.post('/service-requests', data: {
      'extension_worker_id': extensionWorkerId,
      'description': description,
    });
    return ServiceRequestItem.fromJson(response.data);
  }

  /// action: 'accept' | 'decline' | 'complete' | 'refer'
  Future<ServiceRequestItem> respond({
    required int requestId,
    required String action,
    String? responseMessage,
    int? referredToId,
  }) async {
    final response = await _dio.patch('/service-requests/$requestId/respond', data: {
      'action': action,
      if (responseMessage != null && responseMessage.isNotEmpty) 'response_message': responseMessage,
      if (referredToId != null) 'referred_to_id': referredToId,
    });
    return ServiceRequestItem.fromJson(response.data);
  }
}
