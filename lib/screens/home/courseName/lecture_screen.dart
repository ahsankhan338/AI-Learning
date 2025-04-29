import 'package:aieducator/api/ai_model_api.dart';
import 'package:aieducator/api/certificates_api.dart';
import 'package:aieducator/api/quiz_api.dart';
import 'package:aieducator/components/spinner.dart';
import 'package:aieducator/components/toast.dart';
import 'package:aieducator/models/quiz_model.dart';
import 'package:aieducator/provider/auth_provider.dart';
import 'package:aieducator/provider/routes_refresh_notifier.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
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
  List<QuizTitle> quizTitles = [];
  bool isLoading = true;
  bool generateQuizLoader = false;
  bool hasCertificate = false;
  bool checkingCertificate = false;
  String? token;
  final AiModelApi aiApi = AiModelApi();
  final certificatesApi = CertificatesApi();

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      token = authProvider.token;

      if (token == null) {
        setState(() => isLoading = false);
        showToast(message: "Authentication error. Please login again.");
        return;
      }

      await fetchQuizTitles();
    } catch (e) {
      setState(() => isLoading = false);
      showToast(message: "Unexpected error initializing screen.");
      debugPrint("Init Error: $e");
    }
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
          await checkCertificateEligibility();
        }
      } else {
        await generateAndSaveQuizTitles();
      }
    } catch (e) {
      setState(() => isLoading = false);
      showToast(message: "Failed to load saved quizzes.");
      debugPrint("fetchQuizTitles Error: $e");
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
          final titles =
              decoded.map((item) => QuizTitle.fromJson(item)).toList();

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

          return;
        }
      }

      showToast(message: "AI returned invalid data.");
    } catch (e) {
      setState(() => isLoading = false);
      showToast(message: "Error generating quiz titles.");
      debugPrint("generateAndSaveQuizTitles Error: $e");
    }
  }

  Future<void> checkCertificateEligibility() async {
    try {
      setState(() => checkingCertificate = true);

      final eligible = await certificatesApi.checkCertificateEligibility(
        token: token!,
        categoryId: widget.categoryId,
      );

      if (mounted) {
        setState(() {
          hasCertificate = eligible;
          checkingCertificate = false;
        });
      }
    } catch (e) {
      setState(() => checkingCertificate = false);
      showToast(message: "Failed to check certificate status.");
      debugPrint("checkCertificateEligibility Error: $e");
    }
  }

  Future<void> generateCertificate() async {
    try {
      setState(() => generateQuizLoader = true);

      final success = await certificatesApi.generateCertificate(
        token: token!,
        courseName: widget.courseName,
        categoryId: widget.categoryId,
      );

      if (success) {
        showToast(message: "Certificate generated!");
        if (mounted) {
          setState(() => hasCertificate = true);
          context.read<RoutesRefreshNotifier>().refresh();
        }
      } else {
        showToast(message: "Failed to generate certificate");
      }
    } catch (e) {
      showToast(message: "Error generating certificate.");
      debugPrint("generateCertificate Error: $e");
    } finally {
      if (mounted) {
        setState(() => generateQuizLoader = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoading && quizTitles.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Failed to load quizzes.",
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: fetchQuizTitles,
              child: const Text("Retry"),
            ),
          ],
        ),
      );
    }
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
                                color: const Color(0xFF3D3CFF),
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
                                  onPressed: generateCertificate,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF3D3CFF),
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
