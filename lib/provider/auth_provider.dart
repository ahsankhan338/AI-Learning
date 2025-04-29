import 'package:aieducator/api/auth_api.dart';
import 'package:aieducator/api/user_api.dart';
import 'package:aieducator/components/toast.dart';
import 'package:aieducator/models/user_modal.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  bool _splashComplete = false;
  String? _token;
  User? _user;

  // Keys for SharedPreferences
  static const String tokenKey = 'auth_token';
  static const String rememberMeKey = 'remember_me';

  bool get isAuthenticated => _isAuthenticated;
  bool get splashComplete => _splashComplete;
  String? get token => _token;
  User? get user => _user;
  bool _shouldRefreshCertificate = false;
  bool get shouldRefreshCertificate => _shouldRefreshCertificate;

  // Constructor to check for saved credentials on startup
  AuthProvider() {
    _checkSavedCredentials();
  }

  void refreshCertificates() {
    _shouldRefreshCertificate = !_shouldRefreshCertificate; // Just toggle
    notifyListeners(); // Tell GoRouter & screens to refresh
  }

  // Check if we have saved credentials
  Future<void> _checkSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString(tokenKey);
    final rememberMe = prefs.getBool(rememberMeKey) ?? false;

    if (savedToken != null && rememberMe) {
      await login(token: savedToken, shouldSave: false);
    }
  }

  void completeSplash() {
    _splashComplete = true;
    notifyListeners();
  }

  Future<void> login({
    required String token,
    bool shouldSave = true,
    bool rememberMe = false,
  }) async {
    try {
      print("token: $token");
      print("is Authenticated");
      _token = token;
      _user = await UserApi.getUser(token);
      showToast(message: "Logged In Successfully");
      print("User: $_user");
      _isAuthenticated = true;

      // Save credentials if rememberMe is true
      if (shouldSave) {
        await _saveCredentials(token, rememberMe);
      }
    } catch (e) {
      logout();
    } finally {
      notifyListeners();
    }
  }

  Future<void> register({
    required String email,
    required String username,
    required String password,
    required String dateOfBirth,
  }) async {
    try {
      final Authentication auth = Authentication();
      final result = await auth.register(
        email: email,
        username: username,
        password: password,
        dateOfBirth: dateOfBirth,
      );

      final token = result['token'];

      // After successful registration, log the user in
      await login(token: token, rememberMe: true);

      showToast(message: "Registered Successfully");
    } catch (e) {
      showToast(
          message: "Registration failed: ${e.toString()}",
          backgroundColor: Colors.red);
      rethrow; // Rethrow so the UI can handle it
    }
  }

  // Save credentials to SharedPreferences
  Future<void> _saveCredentials(String token, bool rememberMe) async {
    final prefs = await SharedPreferences.getInstance();

    if (rememberMe) {
      await prefs.setString(tokenKey, token);
      await prefs.setBool(rememberMeKey, true);
    } else {
      // Clear saved credentials if rememberMe is false
      await prefs.remove(tokenKey);
      await prefs.setBool(rememberMeKey, false);
    }
  }


  void updateUserNameLocally(String newName) {
  if (_user != null) {
    _user = _user!.copyWith(name: newName);
    notifyListeners();
  }
}

  Future<void> logout() async {
    _isAuthenticated = false;
    _user = null;
    _token = null;

    // Clear saved credentials
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);

    notifyListeners();
  }
}
