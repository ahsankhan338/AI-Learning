import 'package:aieducator/api/ai_model_api.dart';
import 'package:aieducator/api/quiz_api.dart';
import 'package:aieducator/components/spinner.dart';
import 'package:aieducator/models/quiz_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

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
  List<QuizTitle> quizTitles = [];
  bool isLoading = true;
  String? error;
  final AiModelApi aiApi = AiModelApi();
  String? token;

  @override
  void initState() {
    super.initState();
    _initializeToken();
  }

  Future<void> _initializeToken() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('auth_token');
    fetchQuizTitles();
  }

  Future<void> fetchQuizTitles() async {
    if (token == null) {
      setState(() {
        error = "Authentication error. Please log in again.";
        isLoading = false;
      });
      return;
    }

    try {
      // Try to get stored quiz titles from the backend first
      final savedTitles = await QuizApi.getQuizTitles(
        token: token!,
        categoryId: widget.categoryId,
      );

      if (savedTitles != null && savedTitles.isNotEmpty) {
        // Use the stored quiz titles
        setState(() {
          quizTitles = savedTitles;
          isLoading = false;
        });
      } else {
        // If no stored quiz titles, generate them with AI and save to backend
        await generateAndSaveQuizTitles();
      }
    } catch (e) {
      print("Error fetching quiz titles: $e");
      setState(() {
        isLoading = false;
        error = "Failed to load quiz data. Please try again later.";
      });
    }
  }

  Future<void> generateAndSaveQuizTitles() async {
    try {
      final prompt =
          "Give me a list of only 7 quiz titles with status in pure JSON format for the course '${widget.courseName}'. "
          "The format should be: [{\"title\": \"Quiz 1: [Actual Quiz Title]\", \"status\": \"unlocked\"}, ...] with no explanation. "
          "The first quiz should have status 'unlocked', the rest should have status 'locked'";

      final response = await aiApi.getAIResponse(prompt);

      // Extract JSON array using regex
      final jsonMatch = RegExp(r'\[.*\]', dotAll: true).firstMatch(response);

      if (jsonMatch != null) {
        final jsonString = jsonMatch.group(0)!;
        final decoded = json.decode(jsonString);

        if (decoded is List && decoded.isNotEmpty) {
          // Convert the JSON to QuizTitle objects
          final titles = (decoded as List)
              .map((item) => QuizTitle.fromJson(item))
              .toList();

          // Save the generated quiz titles to the backend
          await QuizApi.saveQuizTitles(
            token: token!,
            categoryId: widget.categoryId,
            quizTitles: titles,
          );

          setState(() {
            quizTitles = titles;
            isLoading = false;
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
          ? const Center(child: SpinLoader())
          : error != null
              ? Center(
                  child: Text(
                    error!,
                    style: const TextStyle(color: Colors.red, fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.builder(
                  itemCount: quizTitles.length,
                  itemBuilder: (context, index) {
                    bool isLast = index == quizTitles.length - 1;
                    bool isLocked = quizTitles[index].status == 'locked';
                    bool isPassed = quizTitles[index].status == 'passed';

                    return InkWell(
                      onTap: isLocked
                          ? null
                          : () async {
                              final result = await context.push(
                                '/home/course/${widget.courseName}/${widget.categoryId}/lectures/mcq',
                                extra: {
                                  'quizTitle': quizTitles[index].title,
                                  'categoryId': widget.categoryId,
                                  'quizIndex': index,
                                  'quizTitles': quizTitles,
                                },
                              );

                              // 🚀 If MCQScreen returns true, refresh quiz titles
                              if (result == true) {
                                fetchQuizTitles(); // 👈 Re-fetch the quiz status from server
                              }
                            },
                      child: Opacity(
                        opacity: isLocked ? 0.5 : 1.0,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              children: [
                                Icon(
                                  isPassed
                                      ? Icons.check_circle
                                      : isLocked
                                          ? Icons.lock
                                          : Icons.circle_outlined,
                                  color: isPassed ? Colors.green : Colors.white,
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
                                quizTitles[index].title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
