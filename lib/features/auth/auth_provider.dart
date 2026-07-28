import 'package:flutter/foundation.dart';
import '../../models/user.dart';
import '../../services/auth_service.dart';

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
      errorMessage = 'Invalid email or password.';
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
      errorMessage = 'Could not create account. Check your details and try again.';
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
