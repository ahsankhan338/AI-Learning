import 'package:flutter/material.dart';

class AIScreen extends StatelessWidget {
  const AIScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Personal Trainer")),
      body: ListView.builder(
        itemCount: 6,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text("Lecture ${index + 1}"),
          );
        },
      ),
    );
  }
}
