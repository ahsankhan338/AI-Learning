import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CourseName extends StatefulWidget {
  final String name;
  const CourseName({super.key, required this.name});

  @override
  State<CourseName> createState() => _CourseNameState();
}

class _CourseNameState extends State<CourseName> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildOptionButton(
          icon: Icons.lightbulb_outline,
          text: 'Learn With AI',
          onTap: () {
            context.goNamed(
              'lectures',
              pathParameters: {'name': widget.name},
            );
          },
        ),
        const SizedBox(height: 20),
        _buildOptionButton(
          icon: Icons.location_on_outlined,
          text: 'Nearby Institutes',
          onTap: () {
            context.goNamed(
              'nearbyInstitute',
              pathParameters: {'name': widget.name},
            );
          },
        ),
        const SizedBox(height: 20),
        _buildOptionButton(
          icon: Icons.menu_book_outlined,
          text: 'Available Courses',
          onTap: () {
            context.goNamed(
              'availableCourses',
              pathParameters: {'name': widget.name},
            );
          },
        ),
      ],
    );
  }

  Widget _buildOptionButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: 24),
                const SizedBox(width: 15),
                Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
