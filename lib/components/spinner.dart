import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class SpinLoader extends StatelessWidget {
  const SpinLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return const SpinKitSpinningLines(size: 50, color: Colors.grey);
  }
}
