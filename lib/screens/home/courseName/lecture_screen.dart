import 'package:flutter/material.dart';

class LectureScreen extends StatelessWidget {
  final String courseName;
  final String categoryId;
  const LectureScreen({
    super.key, 
    required this.courseName,
    required this.categoryId,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> steps = [
      {"title": "Lecture 1", "completed": true},
      {"title": "Lecture 2", "completed": false},
      {"title": "Lecture 3", "completed": true},
      {"title": "Lecture 4", "completed": true},
      {"title": "Lecture 5", "completed": false},
      {"title": "Lecture 6", "completed": false},
      {"title": "Quiz # 1", "completed": false},
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
      child: ListView.builder(
        itemCount: steps.length,
        itemBuilder: (context, index) {
          bool isLast = index == steps.length - 1;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Icon(
                    steps[index]["completed"]
                        ? Icons.check_circle
                        : Icons.circle_outlined,
                    color: Colors.white,
                    size: 32,
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 50,
                      color: Colors.white,
                    ),
                ],
              ),
              const SizedBox(width: 30),
              Text(
                steps[index]["title"],
                style: const TextStyle(color: Colors.white, fontSize: 24),
              ),
            ],
          );
        },
      ),
    );
  }
}
