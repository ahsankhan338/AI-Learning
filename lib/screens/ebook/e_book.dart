import 'package:aieducator/utility/data.dart';
import 'package:flutter/material.dart';

class EbookScreen extends StatelessWidget {
  const EbookScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Two items per row
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.8, // Adjust to fit text and image properly
        ),
        itemCount: ebookData.length,
        itemBuilder: (context, index) {
          return LanguageCard(language: ebookData[index]);
        },
      ),
    );
  }
}

class LanguageCard extends StatelessWidget {
  final Map<String, String> language;

  const LanguageCard({super.key, required this.language});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.transparent,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Image.asset(language["image_path"]!, fit: BoxFit.contain),
            ),
            const SizedBox(height: 10),
            Text(
              language["title"]!,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              language["level"]!,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
