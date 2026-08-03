import '../core/network/api_client.dart';
import '../models/plan.dart';

class SubscriptionService {
  final _dio = ApiClient.instance.dio;

  Future<List<Plan>> fetchPlans() async {
    final response = await _dio.get('/plans');
    final items = response.data as List<dynamic>;
    return items.map((e) => Plan.fromJson(e)).toList();
  }

  Future<List<SubscriptionItem>> fetchMySubscriptions() async {
    final response = await _dio.get('/subscriptions/mine');
    final items = response.data as List<dynamic>;
    return items.map((e) => SubscriptionItem.fromJson(e)).toList();
  }

  Future<SubscriptionItem> subscribe({required int planId, required String phoneNumber}) async {
    final response = await _dio.post('/subscriptions', data: {
      'plan_id': planId,
      'phone_number': phoneNumber,
    });
    return SubscriptionItem.fromJson(response.data);
  }
}
