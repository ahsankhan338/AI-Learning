import 'package:flutter/material.dart';
import 'ai_screen.dart';
import 'map_screen.dart';

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Learn")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              title: const Text("Learn With AI"),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AIScreen()));
              },
            ),
            ListTile(
              title: const Text("Nearby Institutes"),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const MapScreen()));
              },
            ),
            ListTile(
              title: const Text("Available Courses"),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
