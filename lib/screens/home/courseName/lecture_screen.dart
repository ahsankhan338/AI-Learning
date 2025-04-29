import 'package:aieducator/api/ai_model_api.dart';
import 'package:aieducator/api/quiz_api.dart';
import 'package:aieducator/components/spinner.dart';
import 'package:aieducator/components/toast.dart';
import 'package:aieducator/models/quiz_model.dart';
import 'package:aieducator/provider/routes_refresh_notifier.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
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
  bool generateQuizLoader = false;
  bool hasCertificate = false;
  bool checkingCertificate = false;
  String? token;
  final AiModelApi aiApi = AiModelApi();

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('auth_token');
    if (token == null) {
      setState(() {
        isLoading = false;
      });
      showToast(message: "Authentication error. Please login again.");
      return;
    }
    await fetchQuizTitles();
  }

  bool allQuizzesPassed() {
    return quizTitles.isNotEmpty &&
        quizTitles.every((quiz) => quiz.status == 'passed');
  }

  Future<void> fetchQuizTitles() async {
    try {
      final savedTitles = await QuizApi.getQuizTitles(
        token: token!,
        categoryId: widget.categoryId,
      );

      if (!mounted) return;

      if (savedTitles != null && savedTitles.isNotEmpty) {
        setState(() {
          quizTitles = savedTitles;
          isLoading = false;
        });

        if (allQuizzesPassed()) {
          checkCertificateEligibility();
        }
      } else {
        await generateAndSaveQuizTitles();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      showToast(message: "Failed to load quiz data.");
    }
  }

  Future<void> generateAndSaveQuizTitles() async {
    try {
      final prompt =
          "Generate exactly 7 quiz titles for the course '${widget.courseName}' in pure JSON format. "
          "Only the first quiz should have status 'unlocked', and the remaining 6 quizzes should have status 'locked'. "
          "The format should be like this: "
          "[{\"title\": \"Quiz 1: [Quiz title]\", \"status\": \"unlocked\"}, "
          "{\"title\": \"Quiz 2: [Quiz title]\", \"status\": \"locked\"}, "
          "{\"title\": \"Quiz 3: [Quiz title]\", \"status\": \"locked\"}, "
          "{\"title\": \"Quiz 4: [Quiz title]\", \"status\": \"locked\"}, "
          "{\"title\": \"Quiz 5: [Quiz title]\", \"status\": \"locked\"}, "
          "{\"title\": \"Quiz 6: [Quiz title]\", \"status\": \"locked\"}, "
          "{\"title\": \"Quiz 7: [Quiz title]\", \"status\": \"locked\"}] "
          "No explanation. Just pure JSON array.";

      final response = await aiApi.getAIResponse(prompt);
      final jsonMatch = RegExp(r'\[.*\]', dotAll: true).firstMatch(response);

      if (jsonMatch != null) {
        final jsonString = jsonMatch.group(0)!;
        final decoded = json.decode(jsonString);

        if (decoded is List && decoded.isNotEmpty) {
          final titles = (decoded as List)
              .map((item) => QuizTitle.fromJson(item))
              .toList();

          await QuizApi.saveQuizTitles(
            token: token!,
            categoryId: widget.categoryId,
            quizTitles: titles,
          );

          if (!mounted) return;
          setState(() {
            quizTitles = titles;
            isLoading = false;
          });
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      showToast(message: "Error generating quiz titles.");
    }
  }

  Future<void> checkCertificateEligibility() async {
    setState(() {
      checkingCertificate = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
            'http://10.0.2.2:3001/certificates/eligibility/${widget.categoryId}'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            hasCertificate = result['hasCertificate'] == true;
          });
        }
      }
    } catch (e) {
      print("Certificate eligibility check failed: $e");
    } finally {
      if (mounted) {
        setState(() {
          checkingCertificate = false;
        });
      }
    }
  }

  Future<void> generateCertificate() async {
    setState(() {
      generateQuizLoader = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3001/certificates/generate'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'courseName': widget.courseName,
          'categoryId': widget.categoryId,
        }),
      );

      if (response.statusCode == 201) {
        showToast(message: "Certificate generated!");
        if (mounted) {
          setState(() {
            hasCertificate = true;
          });
        }
      } else {
        showToast(message: "Failed to generate certificate");
      }
    } catch (e) {
      showToast(message: "Network error");
    } finally {
      if (mounted) {
        setState(() {
          generateQuizLoader = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
      child: isLoading
          ? const Center(child: SpinLoader())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: quizTitles.length,
                    itemBuilder: (context, index) {
                      final quiz = quizTitles[index];
                      final bool isLast = index == quizTitles.length - 1;
                      return InkWell(
                        onTap: quiz.status == 'locked'
                            ? null
                            : () async {
                                final result = await context.push(
                                  '/home/course/${widget.courseName}/${widget.categoryId}/lectures/mcq',
                                  extra: {
                                    'quizTitle': quiz.title,
                                    'categoryId': widget.categoryId,
                                    'quizIndex': index,
                                    'quizTitles': quizTitles,
                                  },
                                );
                                if (result == true) {
                                  fetchQuizTitles();
                                }
                              },
                        child: Opacity(
                          opacity: quiz.status == 'locked' ? 0.5 : 1.0,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                children: [
                                  Icon(
                                    quiz.status == 'passed'
                                        ? Icons.check_circle
                                        : quiz.status == 'locked'
                                            ? Icons.lock
                                            : Icons.circle_outlined,
                                    color: quiz.status == 'passed'
                                        ? Colors.green
                                        : Colors.white,
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
                                  quiz.title,
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
                ),
                if (allQuizzesPassed()) const SizedBox(height: 20),
                if (allQuizzesPassed())
                  checkingCertificate
                      ? const SpinLoader()
                      : hasCertificate
                          ? Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(
                                child: Text(
                                  "🎓 Certificate already generated!",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            )
                          : (generateQuizLoader
                              ? const SpinLoader()
                              : ElevatedButton(
                                  onPressed: () async {
                                    await generateCertificate();
                                    Provider.of<RoutesRefreshNotifier>(context,
                                            listen: false)
                                        .refresh();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 32, vertical: 16),
                                  ),
                                  child: const Text(
                                    "Generate Certificate",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                )),
              ],
            ),
    );
  }
}
