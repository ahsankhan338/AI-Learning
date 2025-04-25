import 'package:aieducator/api/ai_model_api.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class LectureScreen extends StatefulWidget {
  final String courseName;
  final String categoryId;

  const LectureScreen({
    super.key,
    required this.courseName,
    required this.categoryId,
  });

  @override
  State<LectureScreen> createState() => _LectureScreenState();
}

class _LectureScreenState extends State<LectureScreen> {
  List<Map<String, dynamic>> steps = [];
  bool isLoading = true;
  String? error;
  final AiModelApi aiApi = AiModelApi();

  @override
  void initState() {
    super.initState();
    fetchLectureSteps();
  }

  Future<void> fetchLectureSteps() async {
    try {
      final prompt =
          "Give me a list of only 7 quiz titles with completion status in pure JSON format for the course '${widget.courseName}'. "
          "The format should be: [{\"title\": \"Quiz 1\", \"completed\": false}, ...] with no explanation.";

      final response = await aiApi.getAIResponse(prompt);

      // 🔍 Extract JSON array using regex
      final jsonMatch = RegExp(r'\[.*\]', dotAll: true).firstMatch(response);

      if (jsonMatch != null) {
        final jsonString = jsonMatch.group(0)!;
        final decoded = json.decode(jsonString);

        if (decoded is List && decoded.isNotEmpty) {
          setState(() {
            steps = List<Map<String, dynamic>>.from(decoded);
            isLoading = false;
            error = null;
          });
        } else {
          throw Exception("Decoded data is not a valid non-empty list.");
        }
      } else {
        throw Exception("No JSON array found in response.");
      }
    } catch (e) {
      print("AI API error: $e");
      setState(() {
        isLoading = false;
        error = "Failed to fetch quiz data. Please try again later.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Text(
                    error!,
                    style: const TextStyle(color: Colors.red, fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.builder(
                  itemCount: steps.length,
                  itemBuilder: (context, index) {
                    bool isLast = index == steps.length - 1;
                    return InkWell(
                      onTap: () {
                        print(steps[index]["title"]);
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              Icon(
                                steps[index]["completed"] == true
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
                          Expanded(
                            child: Text(
                              steps[index]["title"],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
