import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../models/user.dart';
import '../../services/auth_service.dart';

/// Turns a DioException into a message that actually tells you what
/// happened, instead of a generic "check your details" catch-all.
String _describeError(Object e) {
  if (e is DioException) {
    switch (e.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
        return 'Could not reach the server. Check API_BASE_URL in .env '
            'matches your computer\'s IP, that php artisan serve is running '
            'with --host=0.0.0.0, and that your phone is on the same Wi-Fi.';
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return 'Server took too long to respond. Is php artisan serve still running?';
      default:
        final status = e.response?.statusCode;
        final data = e.response?.data;
        if (status == 422 && data is Map && data['errors'] != null) {
          final errors = (data['errors'] as Map).values.expand((v) => v as List).join('\n');
          return errors;
        }
        if (data is Map && data['message'] != null) {
          return '${data['message']} (HTTP $status)';
        }
        return 'Server error (HTTP $status).';
    }
  }
  return e.toString();
}

enum AuthStatus { unknown, authenticated, unauthenticated }

/// App-wide auth state. Wrap MaterialApp with a ChangeNotifierProvider of
/// this class (see main.dart) so any screen can read `context.watch<AuthProvider>()`.
class AuthProvider extends ChangeNotifier {
  final _authService = AuthService();

  AuthStatus status = AuthStatus.unknown;
  AppUser? user;
  String? errorMessage;
  bool isLoading = false;

  Future<void> bootstrap() async {
    try {
      final result = await _authService.currentUser();
      user = result;
      status = result != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
    } catch (_) {
      status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      user = await _authService.login(email, password);
      status = AuthStatus.authenticated;
      return true;
    } catch (e) {
      errorMessage = _describeError(e);
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      user = await _authService.register(name: name, email: email, password: password);
      status = AuthStatus.authenticated;
      return true;
    } catch (e) {
      errorMessage = _describeError(e);
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    user = null;
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
