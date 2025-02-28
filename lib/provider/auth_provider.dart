import 'package:aieducator/api/user_api.dart';
import 'package:aieducator/models/user_modal.dart';
import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  bool _splashComplete = false;
  User? _user;

  bool get isAuthenticated => _isAuthenticated;
  bool get splashComplete => _splashComplete;
  User? get user => _user;

  void completeSplash() {
    _splashComplete = true;
    notifyListeners();
  }

  Future<void> login({required String token}) async {
    try {
      print("token: $token");
      _user = await UserApi.getUser(token);
      _isAuthenticated = true;
      print("user: $_user");
    } catch (e) {
      logout();
      print("Login error: $e");      
    } finally {
      notifyListeners();
    }
  }

  void logout() {
    _isAuthenticated = false;
    _user = null;
    notifyListeners();
  }
}
