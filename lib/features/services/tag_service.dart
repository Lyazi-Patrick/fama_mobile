import '../../core/network/api_client.dart';
import '../../models/tag.dart';

class TagService {
  final _dio = ApiClient.instance.dio;

  Future<List<Tag>> fetchTags() async {
    final response = await _dio.get('/tags');
    final items = response.data as List<dynamic>;
    return items.map((e) => Tag.fromJson(e)).toList();
  }
}
