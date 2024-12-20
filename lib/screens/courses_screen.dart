import 'package:flutter/material.dart';

class CoursesScreen extends StatelessWidget {
  const CoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Courses")),
      body: ListView(
        children: const [
          ListTile(
            title: Text("Python: Learn from Scratch"),
            subtitle: Text("Programming"),
          ),
          ListTile(
            title: Text("Java: Master Basics"),
            subtitle: Text("Programming"),
          ),
        ],
      ),
    );
  }
}
