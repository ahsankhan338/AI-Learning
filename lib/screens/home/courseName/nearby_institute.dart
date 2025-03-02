import 'package:aieducator/constants/constants.dart';
import 'package:flutter/material.dart';

class NearbyInstituteScreen extends StatelessWidget {
  final String courseName;
  const NearbyInstituteScreen({super.key, required this.courseName});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Container(
            height: 475,
            width: double.infinity,
            decoration: BoxDecoration(
                border: Border.all(width: 2, color: Colors.grey),
                borderRadius: BorderRadius.circular(25)),
          ),
          SizedBox(
            height: 20,
          ),
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
                border: Border.all(width: 2, color: Colors.grey),
                borderRadius: BorderRadius.circular(25)),
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  courseName,
                  style: AppTextStyles.textLabelStyle(),
                ),
                Text(
                  "Bahria University Islamabad",
                  style: AppTextStyles.textLabelStyle()
                      .copyWith(color: Colors.white70),
                ),
                Text(
                  "E-8, Islamabad",
                  style: AppTextStyles.textLabelSmallStyle(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
