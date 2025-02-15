import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  bool _splashComplete = false;

  bool get isAuthenticated => _isAuthenticated;
  bool get splashComplete => _splashComplete;

  void completeSplash() {
    _splashComplete = true;
    notifyListeners();
  }

  void login({required String token}) {
    print(token);
    _isAuthenticated = true;
    notifyListeners();
  }

  void logout() {
    _isAuthenticated = false;
    notifyListeners();
  }
}
