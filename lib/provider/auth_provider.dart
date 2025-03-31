import 'package:aieducator/api/user_api.dart';
import 'package:aieducator/components/toast.dart';
import 'package:aieducator/models/user_modal.dart';
import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  bool _splashComplete = false;
  String? _token;
  User? _user;

  bool get isAuthenticated => _isAuthenticated;
  bool get splashComplete => _splashComplete;
  String? get token => _token;
  User? get user => _user;

  void completeSplash() {
    _splashComplete = true;
    notifyListeners();
  }

  Future<void> login({
    required String token,
  }) async {
    try {
      print("token: $token");
      print("is Authencitaed");
      _user = await UserApi.getUser(token);
      showToast(message: "Logged In Sucessfull");
      print("User: $_user");
      _isAuthenticated = true;
    } catch (e) {
      logout();
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
