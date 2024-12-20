import 'package:flutter/material.dart';
import 'interests_screen.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register Account")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(decoration: const InputDecoration(labelText: "Username")),
            TextField(decoration: const InputDecoration(labelText: "Email")),
            TextField(decoration: const InputDecoration(labelText: "Date of Birth")),
            TextField(decoration: const InputDecoration(labelText: "Password"), obscureText: true),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const InterestsScreen()),
                );
              },
              child: const Text("Next"),
            ),
          ],
        ),
      ),
    );
  }
}
