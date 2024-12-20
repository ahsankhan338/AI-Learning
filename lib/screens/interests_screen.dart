import 'package:flutter/material.dart';
import 'home_screen.dart';

class InterestsScreen extends StatelessWidget {
  const InterestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Your Interests")),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Select your interests:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: [
              _interestChip("Programming"),
              _interestChip("Data Science"),
              _interestChip("AI"),
              _interestChip("Design"),
              _interestChip("Marketing"),
              _interestChip("Finance"),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            },
            child: const Text("Start Learning"),
          ),
        ],
      ),
    );
  }

  Widget _interestChip(String label) {
    return Chip(
      label: Text(label),
      backgroundColor: Colors.blueAccent,
    );
  }
}
