import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
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

  /// Launches the native Google account picker, gets an ID token, and
  /// exchanges it with the Laravel backend for a FAMA session token.
  /// Requires GOOGLE_WEB_CLIENT_ID in .env (see README.md for the full
  /// Google Cloud Console setup this depends on).
  Future<AppUser> signInWithGoogle() async {
    final serverClientId = dotenv.env['GOOGLE_WEB_CLIENT_ID'];
    if (serverClientId == null || serverClientId.isEmpty) {
      throw StateError(
        'GOOGLE_WEB_CLIENT_ID is not set in .env -- Google Sign-In has not '
        'been configured yet. See fama_mobile/README.md.',
      );
    }

    final googleSignIn = GoogleSignIn(serverClientId: serverClientId);
    final account = await googleSignIn.signIn();
    if (account == null) {
      // User cancelled the picker -- not an error, just no-op.
      throw StateError('Sign-in cancelled');
    }

    final googleAuth = await account.authentication;
    final idToken = googleAuth.idToken;
    if (idToken == null) {
      throw StateError('Google did not return an ID token.');
    }

    final response = await _dio.post('/auth/google', data: {'id_token': idToken});
    await _storage.saveToken(response.data['token']);
    return AppUser.fromJson(response.data['user']);
  }

  Future<String> forgotPassword(String email) async {
    final response = await _dio.post('/forgot-password', data: {'email': email});
    return response.data['message'] as String? ?? 'If that email is registered, a reset link has been sent.';
  }

  Future<AppUser?> currentUser() async {
    final token = await _storage.readToken();
    if (token == null) return null;
    final response = await _dio.get('/me');
    return AppUser.fromJson(response.data);
  }
}
