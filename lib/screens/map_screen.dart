import 'package:flutter/material.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nearby Institutes")),
      body: const Center(
        child: Text("Map Placeholder - Integrate Google Maps API"),
      ),
    );
  }
}
