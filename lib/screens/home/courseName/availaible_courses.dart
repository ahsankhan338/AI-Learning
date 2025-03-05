import 'package:flutter/material.dart';

class AvailaibleCoursesScreen extends StatelessWidget {
  const AvailaibleCoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Card for Python course
          buildCourseCard(
            imagePath:
                "assets/images/languages/python.png", // Replace with a Python icon/image
            courseTitle: 'Python: learn from scratch',
            availability: 'Available on: coursera.com',
            price: 'Paid',
          ),
          const SizedBox(height: 20),

          // Card for Java course
          buildCourseCard(
            imagePath:
                "assets/images/languages/java.png", // Replace with a Java icon/image
            courseTitle: 'JAVA: learn from scratch',
            availability: 'Available on: udemy.com',
            price: 'Free',
          ),
        ],
      ),
    );
  }

  Widget buildCourseCard({
    required String imagePath,
    required String courseTitle,
    required String availability,
    required String price,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.transparent, // Keep it transparent so background shows
        border: Border.all(color: Colors.white, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            
            Image.asset(
              imagePath,
              fit: BoxFit.cover,
              width: 70,
              height: 70,
            ),
            const SizedBox(width: 16),

            // Vertical divider with full height
            Container(
              width: 1,
              color: Colors.white,
              height: double
                  .infinity, // <-- makes the divider fill available height
            ),
            const SizedBox(width: 16),

            // Text on the right
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    courseTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    availability,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    price,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
