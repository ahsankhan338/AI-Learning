// splash_screen.dart
import 'package:aieducator/constants/colors.dart';
import 'package:aieducator/provider/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300), // Animation duration
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _controller.forward().then((_) {
      Future.delayed(const Duration(seconds: 2)).then((_) async {
        if (mounted) {
          final authProvider =
              Provider.of<AuthProvider>(context, listen: false);
          authProvider.completeSplash();
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ScaleTransition(
          scale: _animation,
          child: Container(
            decoration:
                const BoxDecoration(gradient: AppColors.backgroundGradient),
            child: Center(
              child: Image.asset('assets/images/splash_image.png', width: 200),
            ),
          ),
        ),
      ),
    );
  }
}
