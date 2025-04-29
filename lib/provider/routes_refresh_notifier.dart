import 'package:flutter/material.dart';

class RoutesRefreshNotifier extends ChangeNotifier {
  void refresh() {
    notifyListeners(); // Triggers screen rebuild when needed
  }
}
