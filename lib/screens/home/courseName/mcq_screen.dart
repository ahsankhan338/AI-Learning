import 'package:flutter/material.dart';
import 'package:aieducator/components/spinner.dart';
import 'package:aieducator/api/ai_model_api.dart';
import 'dart:convert';

class MCQScreen extends StatefulWidget {
  final String quizTitle;
  final String categoryId;

  const MCQScreen({
    super.key,
    required this.quizTitle,
    required this.categoryId,
  });

  @override
  State<MCQScreen> createState() => _MCQScreenState();
}

class _MCQScreenState extends State<MCQScreen> {
  List<Map<String, dynamic>> questions = [];
  int currentQuestionIndex = 0;
  Map<int, int> selectedAnswers = {};
  bool isLoading = true;
  String? error;
  bool showingResults = false;
  final AiModelApi aiApi = AiModelApi();

  @override
  void initState() {
    super.initState();
    fetchQuestions();
  }

  Future<void> fetchQuestions() async {
    try {
      final prompt =
          "Generate 5 multiple choice questions for a quiz titled '${widget.quizTitle}'. "
          "Each question should have 4 options with one correct answer. "
          "Format as JSON: [{\"question\": \"Question text\", \"options\": [\"Option A\", \"Option B\", \"Option C\", \"Option D\"], \"correctIndex\": 0}, ...] "
          "with no explanation. Give pure JSON only.";

      final response = await aiApi.getAIResponse(prompt);

      // Extract JSON array using regex
      final jsonMatch = RegExp(r'\[.*\]', dotAll: true).firstMatch(response);

      if (jsonMatch != null) {
        final jsonString = jsonMatch.group(0)!;
        final decoded = json.decode(jsonString);

        if (decoded is List && decoded.isNotEmpty) {
          setState(() {
            questions = List<Map<String, dynamic>>.from(decoded);
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
        error = "Failed to fetch questions. Please try again later.";
      });
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
    setState(() {
      showingResults = true;
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
          Text(
            "Quiz Completed!",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            "Your Score",
            style: const TextStyle(
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
              color: percentage >= 70 ? Colors.green : percentage >= 50 ? Colors.amber : Colors.red,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              setState(() {
                showingResults = false;
                currentQuestionIndex = 0;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: const Text("Review Questions", style: TextStyle(fontSize: 16)),
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
                    : showingResults
                        ? buildResultsScreen()
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              LinearProgressIndicator(
                                value: (currentQuestionIndex + 1) / questions.length,
                                backgroundColor: Colors.grey[800],
                                valueColor:
                                    const AlwaysStoppedAnimation<Color>(Colors.blue),
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
                                    final bool isSelected =
                                        selectedAnswers[currentQuestionIndex] ==
                                            index;
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: InkWell(
                                        onTap: () => selectAnswer(index),
                                        child: Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? Colors.blue
                                                : Colors.grey[850],
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            questions[currentQuestionIndex]["options"]
                                                [index],
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
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                  if (currentQuestionIndex == questions.length - 1)
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
                                      onPressed:
                                          currentQuestionIndex < questions.length - 1
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
