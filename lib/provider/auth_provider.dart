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

  // Constructor to check for saved credentials on startup
  AuthProvider() {
    _checkSavedCredentials();
  }

  // Check if we have saved credentials
  Future<void> _checkSavedCredentials() async {
    final prefs =   await SharedPreferences.getInstance();
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
