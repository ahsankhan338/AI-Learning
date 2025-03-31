import 'package:aieducator/models/course_model.dart';
import 'package:flutter/material.dart';

class AvailaibleCoursesScreen extends StatefulWidget {
  final String categoryId;

  const AvailaibleCoursesScreen({super.key, required this.categoryId});

  @override
  State<AvailaibleCoursesScreen> createState() =>
      _AvailaibleCoursesScreenState();
}

class _AvailaibleCoursesScreenState extends State<AvailaibleCoursesScreen> {
  final ScrollController _scrollController = ScrollController();
  List<Course> _courses = [];
  int _page = 1;
  bool _hasMore = true;
  bool _isLoading = false;
  final int _limit = 10;

  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Text(categoryId.toString()),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
    );
  }
}
