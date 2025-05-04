import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PersonalInterviewPage extends StatefulWidget {
  const PersonalInterviewPage({super.key});

  @override
  State<PersonalInterviewPage> createState() => _PersonalInterviewPageState();
}

class _PersonalInterviewPageState extends State<PersonalInterviewPage> {
  int _currentQuestionIndex = 0;
  bool _isLoading = false;
  bool _isEvaluating = false;
  List<Map<String, dynamic>> _questions = [];
  List<String> _userAnswers = [];
  bool _showAnswerFeedback = false;
  String _finalFeedback = '';
  final TextEditingController _answerController = TextEditingController();

  final String geminiApiKey = 'AIzaSyCxV8rOYgB3vojVaD0V7fkPJulniZ_3-1s';

  @override
  void initState() {
    super.initState();
    _fetchHRQuestionsFromGemini();
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _fetchHRQuestionsFromGemini() async {
    setState(() {
      _isLoading = true;
    });

    const url =
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

    String prompt =
        "Generate exactly 6 common HR interview questions that test a candidate's personality, soft skills, and work ethic. "
        "Focus on questions about teamwork, problem-solving, leadership, and work experience. "
        "Format each question exactly as: 'Question: [question]' "
        "Example: 'Question: Tell me about a time you had to work with a difficult team member and how you handled the situation.'";

    try {
      final response = await http.post(
        Uri.parse('$url?key=$geminiApiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": prompt},
              ],
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final text = jsonResponse['candidates'][0]['content']['parts'][0]['text'].toString();

        List<Map<String, dynamic>> parsedQuestions = [];
        List<String> questionLines = text.split('\n').where((line) => line.trim().isNotEmpty).toList();

        for (String line in questionLines.take(5)) {
          if (line.contains('Question:')) {
            String question = line.split('Question:')[1].trim();
            parsedQuestions.add({
              'question': question,
            });
          }
        }

        setState(() {
          _questions = parsedQuestions;
          _userAnswers = List.filled(_questions.length, '');
          _isLoading = false;
        });
      } else {
        print("Error: ${response.statusCode} - ${response.body}");
        setState(() {
          _questions = [
            {"question": "Failed to fetch questions. Try again later."},
          ];
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Exception: $e");
      setState(() {
        _questions = [
          {"question": "Failed to fetch questions. Try again later."},
        ];
        _isLoading = false;
      });
    }
  }

  Future<void> _getFinalFeedback() async {
    setState(() {
      _isEvaluating = true;
    });

    const url =
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

    String prompt =
        "I just completed a mock HR interview with these questions and answers:\n\n";

    for (int i = 0; i < _questions.length; i++) {
      prompt += "Question ${i + 1}: ${_questions[i]['question']}\n";
      prompt += "Answer: ${_userAnswers[i]}\n\n";
    }

    prompt += "Please provide constructive feedback on my answers. "
        "Focus on areas for improvement, suggest better ways to phrase responses, "
        "and highlight any missing key points. Keep the feedback concise but actionable.";

    try {
      final response = await http.post(
        Uri.parse('$url?key=$geminiApiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": prompt},
              ],
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final text = jsonResponse['candidates'][0]['content']['parts'][0]['text'].toString();

        setState(() {
          _finalFeedback = text;
          _isEvaluating = false;
          _showCompletionDialog();
        });
      } else {
        setState(() {
          _finalFeedback = "Couldn't generate feedback. Please review your answers carefully.";
          _isEvaluating = false;
          _showCompletionDialog();
        });
      }
    } catch (e) {
      setState(() {
        _finalFeedback = "Error generating feedback. Please try again later.";
        _isEvaluating = false;
        _showCompletionDialog();
      });
    }
  }

  void _submitAnswer() {
    if (_answerController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your answer before submitting'),
        ),
      );
      return;
    }

    setState(() {
      _userAnswers[_currentQuestionIndex] = _answerController.text;
      _showAnswerFeedback = true;
      _answerController.clear();
    });
  }

  void _handleNextQuestion() {
    setState(() {
      _showAnswerFeedback = false;
      if (_currentQuestionIndex < _questions.length - 1) {
        _currentQuestionIndex++;
      } else {
        _getFinalFeedback();
      }
    });
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Interview Complete"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("You've completed all questions.\n\nHere's your feedback:"),
              const SizedBox(height: 16),
              Text(
                _finalFeedback,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("Done"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(),
        title: const Text(
          'HR Interview Practice',
          style: TextStyle(fontSize: 17),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_isLoading) _buildLoadingIndicator(theme),
                if (!_isLoading && _questions.isNotEmpty) ...[
                  _buildQuestionCard(theme),
                  const SizedBox(height: 20),
                  _buildAnswerInput(theme),
                  if (_showAnswerFeedback) _buildFeedbackCard(theme),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: CircularProgressIndicator(color: theme.primaryColor),
      ),
    );
  }

  Widget _buildQuestionCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'QUESTION ${_currentQuestionIndex + 1} OF ${_questions.length}',
            style: const TextStyle(
              color: Colors.indigo,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _questions[_currentQuestionIndex]['question'],
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerInput(ThemeData theme) {
    bool isLastQuestion = _currentQuestionIndex == _questions.length - 1;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Answer',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _answerController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'Type your answer here...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_showAnswerFeedback) {
                  _handleNextQuestion();
                } else {
                  _submitAnswer();
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                _showAnswerFeedback
                    ? (isLastQuestion ? 'Finish' : 'Next')
                    : 'Submit Answer',
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackCard(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.lightGreen[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green),
      ),
      child: const Text(
        "Answer saved! Tap 'Next' to continue.",
        style: TextStyle(
          fontSize: 14,
          color: Colors.green,
        ),
      ),
    );
  }
}