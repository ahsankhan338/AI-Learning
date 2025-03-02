import 'package:aieducator/utility/go_router_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('404 - Page Not Found'),
            ElevatedButton(
              onPressed: () => context.goNamed(AppRoutes.home.name),
              child: const Text('Return Home'),
            ),
          ],
        ),
      ),
    );
  }
}
