import 'package:aieducator/api/quiz_api.dart';
import 'package:aieducator/components/toast.dart';
import 'package:aieducator/models/quiz_model.dart';
import 'package:flutter/material.dart';
import 'package:aieducator/components/spinner.dart';
import 'package:aieducator/api/ai_model_api.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class MCQScreen extends StatefulWidget {
  final String quizTitle;
  final String categoryId;
  final int quizIndex;
  final List<QuizTitle> quizTitles;

  const MCQScreen({
    super.key,
    required this.quizTitle,
    required this.categoryId,
    required this.quizIndex,
    required this.quizTitles,
  });

  @override
  State<MCQScreen> createState() => _MCQScreenState();
}

class _MCQScreenState extends State<MCQScreen> {
  bool _isDisposed = false;
  List<Map<String, dynamic>> questions = [];
  int currentQuestionIndex = 0;
  Map<int, int> selectedAnswers = {};
  bool isLoading = true;
  bool submitLoading = false;
  String? error;
  bool showingResults = false;
  bool showingLecture = true;
  String lecture = "";
  String? token;
  final AiModelApi aiApi = AiModelApi();

  @override
  void initState() {
    super.initState();
    fetchTokenAndData();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> fetchTokenAndData() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('auth_token');

    if (token == null) {
      // Token missing -> show error
      setState(() {
        error = "Authentication error. Please log in again.";
        isLoading = false;
      });
      return;
    }

    // Now token is available
    fetchLectureAndQuestions(); // fetch lecture and questions normally
  }

  Future<void> fetchLectureAndQuestions() async {
    try {
      final lecturePrompt =
          "Generate a lenghty and informative lecture about '${widget.quizTitle}'. Keep it concise but educational.";

      final lectureResponse = await aiApi.getAIResponse(lecturePrompt);

      if (!_isDisposed) {
        setState(() {
          lecture = lectureResponse.trim();
          isLoading = true; // Still fetching questions
        });
      }

      final questionsPrompt =
          "Based on the following lecture about ${widget.quizTitle}:\n\n$lecture\n\n"
          "Generate 5 multiple choice questions that test understanding of key concepts from this lecture. "
          "Each question should have 4 options with exactly one correct answer. "
          "Randomize the correct option position (it should not always be the first). "
          "Format as pure JSON: "
          "[{\"question\": \"Question text\", \"options\": [\"Option A\", \"Option B\", \"Option C\", \"Option D\"], \"correctIndex\": 2}, ...] "
          "Give JSON only. Do not include any explanation or markdown.";

      final questionsResponse = await aiApi.getAIResponse(questionsPrompt);

      final jsonMatch =
          RegExp(r'\[.*\]', dotAll: true).firstMatch(questionsResponse);

      if (jsonMatch != null) {
        final jsonString = jsonMatch.group(0)!;
        final decoded = json.decode(jsonString);

        if (decoded is List && decoded.isNotEmpty) {
          if (!_isDisposed) {
            setState(() {
              questions = List<Map<String, dynamic>>.from(decoded);
              isLoading = false;
              error = null;
            });
          }
        } else {
          throw Exception("Decoded data is not a valid non-empty list.");
        }
      } else {
        throw Exception("No JSON array found in response.");
      }
    } catch (e) {
      print("AI API error: $e");
      if (!_isDisposed) {
        setState(() {
          isLoading = false;
          error =
              "Failed to fetch lecture and questions. Please try again later.";
        });
      }
    }
  }

  void selectAnswer(int optionIndex) {
    setState(() {
      selectedAnswers[currentQuestionIndex] = optionIndex;
    });
  }

  void nextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
    }
  }

  void previousQuestion() {
    if (currentQuestionIndex > 0) {
      setState(() {
        currentQuestionIndex--;
      });
    }
  }

  void showResults() {
    if (selectedAnswers.length < questions.length) {
      showToast(
          message: "Please answer all questions before submitting.",
          backgroundColor: Colors.black,
          textColor: Colors.red);
      return;
    }
    setState(() {
      showingResults = true;
    });
  }

  void startQuiz() {
    setState(() {
      showingLecture = false;
    });
  }

  int calculateScore() {
    int correctAnswers = 0;
    selectedAnswers.forEach((questionIndex, selectedOptionIndex) {
      if (questions[questionIndex]['correctIndex'] == selectedOptionIndex) {
        correctAnswers++;
      }
    });
    return correctAnswers;
  }

  Future<void> unlockNextQuiz() async {
    setState(() {
      submitLoading = true;
    });

    try {
      final nextQuizIndex = widget.quizIndex + 1;
      final currentQuiz = widget.quizTitles[widget.quizIndex];

      // Always mark the current quiz as passed
      await QuizApi.updateQuizStatus(
        token: token!,
        categoryId: widget.categoryId,
        quizTitle: currentQuiz.title,
        previousTitle: currentQuiz.title,
        previousTitleStatus: "passed",
        status: "passed",
      );

      // Only if there's a next quiz, unlock it
      if (nextQuizIndex < widget.quizTitles.length) {
        final nextQuiz = widget.quizTitles[nextQuizIndex];
        if (nextQuiz.status != 'unlocked') {
          await QuizApi.updateQuizStatus(
            token: token!,
            categoryId: widget.categoryId,
            quizTitle: nextQuiz.title,
            previousTitle: currentQuiz.title,
            previousTitleStatus: "passed",
            status: "unlocked",
          );

          showToast(
            message: "🎉 Next Quiz Unlocked!",
            backgroundColor: Colors.green,
          );
        }
      }

      setState(() {
        submitLoading = false;
      });
    } catch (e) {
      setState(() {
        submitLoading = false;
      });
      print("❌ Failed to update quiz status: $e");
    }
  }

  Widget buildLectureScreen() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.quizTitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            const Text(
              "Lecture",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              lecture
                  .replaceAll('**', '')
                  .replaceAll("###", '')
                  .replaceAll('â€“', '–')
                  .replaceAll('â€”', '—')
                  .replaceAll('â€˜', '\'')
                  .replaceAll('â€™', '\'')
                  .replaceAll('â€œ', '"')
                  .replaceAll('â€�', '"'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: startQuiz,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text("Start Quiz", style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildResultsScreen() {
    final score = calculateScore();
    final totalQuestions = questions.length;
    final percentage = (score / totalQuestions) * 100;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.emoji_events,
            color: Colors.amber,
            size: 80,
          ),
          const SizedBox(height: 24),
          const Text(
            "Quiz Completed!",
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            "Your Score",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            "$score / $totalQuestions",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            "${percentage.toStringAsFixed(0)}%",
            style: TextStyle(
              color: percentage >= 70
                  ? Colors.green
                  : percentage >= 50
                      ? Colors.amber
                      : Colors.red,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  showingResults = false;
                  currentQuestionIndex = 0;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text("Review Questions",
                  style: TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(height: 32),
          submitLoading
              ? const SpinLoader()
              : SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (percentage >= 60) {
                        await unlockNextQuiz();
                        context.pop(
                            true); // 👈 Pass true to tell LectureScreen to refresh
                      } else {
                        showToast(message: "You did not pass the quiz");
                        context.pop(
                            false); // 👈 (Optional) If failed, you can pass false
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                    ),
                    child: const Text("Submit", style: TextStyle(fontSize: 16)),
                  ),
                ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        padding: const EdgeInsets.all(16),
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
                : questions.isEmpty
                    ? const Center(
                        child: Text(
                          "No questions available",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      )
                    : showingLecture
                        ? buildLectureScreen()
                        : showingResults
                            ? buildResultsScreen()
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  LinearProgressIndicator(
                                    value: (currentQuestionIndex + 1) /
                                        questions.length,
                                    backgroundColor: Colors.grey[800],
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                            Colors.blue),
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    "Question ${currentQuestionIndex + 1} of ${questions.length}",
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 16),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    questions[currentQuestionIndex]["question"],
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 24),
                                  Expanded(
                                    child: ListView.builder(
                                      itemCount: questions[currentQuestionIndex]
                                              ["options"]
                                          .length,
                                      itemBuilder: (context, index) {
                                        final bool isSelected = selectedAnswers[
                                                currentQuestionIndex] ==
                                            index;
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 12),
                                          child: InkWell(
                                            onTap: () => selectAnswer(index),
                                            child: Container(
                                              padding: const EdgeInsets.all(16),
                                              decoration: BoxDecoration(
                                                color: isSelected
                                                    ? Colors.blue
                                                    : Colors.grey[850],
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Text(
                                                questions[currentQuestionIndex]
                                                    ["options"][index],
                                                style: TextStyle(
                                                  color: isSelected
                                                      ? Colors.white
                                                      : Colors.grey[300],
                                                  fontSize: 18,
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      ElevatedButton(
                                        onPressed: currentQuestionIndex > 0
                                            ? previousQuestion
                                            : null,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.grey[800],
                                          foregroundColor: Colors.white,
                                        ),
                                        child: const Text("Previous"),
                                      ),
                                      if (currentQuestionIndex ==
                                          questions.length - 1)
                                        ElevatedButton(
                                          onPressed: showResults,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            foregroundColor: Colors.white,
                                          ),
                                          child: const Text("Show Results"),
                                        )
                                      else
                                        ElevatedButton(
                                          onPressed: currentQuestionIndex <
                                                  questions.length - 1
                                              ? nextQuestion
                                              : null,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue,
                                            foregroundColor: Colors.white,
                                          ),
                                          child: const Text("Next"),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
      ),
    );
  }
}
