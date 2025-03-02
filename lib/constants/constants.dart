import 'package:flutter/material.dart';

class AppColors {
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment(-0.20, -0.98),
    end: Alignment(0.2, 0.98),
    colors: [Color(0xFF000305), Color(0xFF003A6B)],
  );
}

class AppTextStyles {
  static TextStyle largeTitle() {
    return const TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
    );
  }

  static TextStyle mediumTitle() {
    return const TextStyle(fontSize: 18, color: Colors.white70);
  }

  static TextStyle bodyTitle() {
    return const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
    );
  }

  static TextStyle buttonTextStyles() {
    return const TextStyle(
      color: Colors.black45,
      fontWeight: FontWeight.bold,
    );
  }

  static TextStyle textButtonStyle() {
    return const TextStyle(
      color: Colors.blueAccent,
    );
  }

  static TextStyle textLabelStyle() {
    return const TextStyle(
        color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16);
  }

  static TextStyle textLabelSmallStyle() {
    return const TextStyle(color: Colors.white70, fontWeight: FontWeight.w500);
  }
}
