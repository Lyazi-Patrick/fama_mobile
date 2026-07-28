import '../core/network/api_client.dart';
import '../core/storage/secure_storage.dart';
import '../models/user.dart';

class AuthService {
  final _dio = ApiClient.instance.dio;
  final _storage = SecureStorage();

  Future<AppUser> login(String email, String password) async {
    final response = await _dio.post('/login', data: {
      'email': email,
      'password': password,
    });
    await _storage.saveToken(response.data['token']);
    return AppUser.fromJson(response.data['user']);
  }

  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
    double? latitude,
    double? longitude,
  }) async {
    final response = await _dio.post('/register', data: {
      'name': name,
      'email': email,
      'password': password,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    });
    await _storage.saveToken(response.data['token']);
    return AppUser.fromJson(response.data['user']);
  }

  Future<void> logout() async {
    try {
      await _dio.post('/logout');
    } finally {
      await _storage.clearToken();
    }
  }

  Future<AppUser?> currentUser() async {
    final token = await _storage.readToken();
    if (token == null) return null;
    final response = await _dio.get('/me');
    return AppUser.fromJson(response.data);
  }
}
