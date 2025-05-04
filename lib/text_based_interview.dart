import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:r2scareer/interview.dart';

class MockInterviewPage extends StatefulWidget {
  final List<String> skills;
  final String userId;

  const MockInterviewPage({
    super.key,
    required this.skills,
    required this.userId, required Map<String, int> proficiencies,
  });

  @override
  State<MockInterviewPage> createState() => _MockInterviewPageState();
}

class _MockInterviewPageState extends State<MockInterviewPage> {
  int _currentQuestionIndex = 0;
  bool _isLoading = false;
  List<Map<String, dynamic>> _questions = [];
  List<String?> _selectedOptions = [];
  List<bool?> _answerResults = [];
  bool _showAnswerFeedback = false;

  final String geminiApiKey = 'AIzaSyCxV8rOYgB3vojVaD0V7fkPJulniZ_3-1s';

  @override
  void initState() {
    super.initState();
    _fetchQuestionsFromGemini();
  }

  Future<void> _fetchQuestionsFromGemini() async {
    setState(() {
      _isLoading = true;
    });

    const url =
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

    String prompt =
        "Generate exactly 11 unique multiple-choice aptitude questions that test the following skills: ${widget.skills.join(', ')}. "
        "Include two types of questions:\n"
        "1) Numerical problems with 4 numerical options (e.g., 'What is 12 + 20?' with options 23, 32, 45, 43)\n"
        "2) Conceptual questions with text options (e.g., 'Which was not supported in C programming language?' with options: Simplicity, Modularity, Efficiency, OOPs)\n"
        "For each question, provide: 1) The question, 2) Four options (only one correct), 3) The correct answer. "
        "Format each question exactly as: 'Question: [question] | Options: option1, option2, option3, option4 | Answer: correctOption'";
         "IMPORTANT: If an option contains multiple lines, replace the newlines with '\\n' so each option remains on a single line.";

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
        
        for (String line in questionLines.take(11)) {
          try {
            if (line.contains('Question:') && line.contains('Options:') && line.contains('Answer:')) {
              String question = line.split('Question:')[1].split('|')[0].trim();
              String optionsPart = line.split('Options:')[1].split('|')[0].trim();
              String answer = line.split('Answer:')[1].trim();
              
              List<String> options = optionsPart.split(',').map((e) => e.trim()).toList();
              
              parsedQuestions.add({
                'question': question,
                'options': options,
                'correct_answer': answer,
              });
            }
          } catch (e) {
            print("Error parsing question: $e");
          }
        }

        setState(() {
          _questions = parsedQuestions;
          _selectedOptions = List.filled(_questions.length, null);
          _answerResults = List.filled(_questions.length, null);
          _isLoading = false;
        });
      } else {
        print("Error: ${response.statusCode} - ${response.body}");
        setState(() {
          _questions = [{
            "question": "Failed to fetch questions. Try again later.",
            "options": ["Retry", "Exit", "Continue", "Ignore"],
            "correct_answer": "Retry"
          }];
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Exception: $e");
      setState(() {
        _questions = [{
          "question": "Failed to fetch questions. Try again later.",
          "options": ["Retry", "Exit", "Continue", "Ignore"],
          "correct_answer": "Retry"
        }];
        _isLoading = false;
      });
    }
  }

  void _checkAnswer() {
    if (_selectedOptions[_currentQuestionIndex] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an answer before submitting'),
        ),
      );
      return;
    }

    bool isCorrect = _selectedOptions[_currentQuestionIndex] == 
        _questions[_currentQuestionIndex]['correct_answer'];

    setState(() {
      _answerResults[_currentQuestionIndex] = isCorrect;
      _showAnswerFeedback = true;
    });
  }

  void _handleNextQuestion() {
    setState(() {
      _showAnswerFeedback = false;
      if (_currentQuestionIndex < _questions.length - 1) {
        _currentQuestionIndex++;
      } else {
        _saveAnswersToFirestore();
        _showCompletionDialog();
      }
    });
  }

  Future<void> _saveAnswersToFirestore() async {
    try {
      await FirebaseFirestore.instance
          .collection('Feedback')
          .doc(widget.userId)
          .set({
            'questions': _questions.map((q) => q['question']).toList(),
            'selected_options': _selectedOptions,
            'correct_answers': _questions.map((q) => q['correct_answer']).toList(),
            'answer_results': _answerResults,
            'timestamp': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
    } catch (e) {
      print("Error saving answers to Firestore: $e");
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Interview Complete"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("You've completed all questions."),
            const SizedBox(height: 16),
            Text(
              "Score: ${_answerResults.where((r) => r == true).length}/${_questions.length}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
            Navigator.pop(context); 
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) =>  SkillSelectionPage()), 
            );
          },
            child: const Text("OK"),
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
          'AI Aptitude Test',
          style: TextStyle(
           fontSize: 17
          ),
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
                  _buildMCQCard(theme),
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

  Widget _buildMCQCard(ThemeData theme) {
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
            'Select an Answer',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(height: 12),
          Column(
            children: _questions[_currentQuestionIndex]['options']
                .map<Widget>((option) => RadioListTile<String>(
                      title: Text(option),
                      value: option,
                      groupValue: _selectedOptions[_currentQuestionIndex],
                      onChanged: (value) {
                        setState(() {
                          _selectedOptions[_currentQuestionIndex] = value;
                          if (_showAnswerFeedback) {
                            _showAnswerFeedback = false;
                          }
                        });
                      },
                      activeColor: Colors.deepPurple,
                      contentPadding: EdgeInsets.zero,
                    ))
                .toList(),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: _showAnswerFeedback 
                    ? (_answerResults[_currentQuestionIndex] == true 
                        ? Colors.green 
                        : Colors.red)
                    : Colors.deepPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: _showAnswerFeedback ? _handleNextQuestion : _checkAnswer,
              child: Text(
                _showAnswerFeedback 
                    ? (isLastQuestion ? 'Finish Interview' : 'Next Question')
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
    bool isCorrect = _answerResults[_currentQuestionIndex] == true;
    String correctAnswer = _questions[_currentQuestionIndex]['correct_answer'];

    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        color: isCorrect ? Colors.green[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCorrect ? Colors.green : Colors.red,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle : Icons.error,
                color: isCorrect ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 8),
              Text(
                isCorrect ? 'Correct Answer!' : 'Incorrect Answer',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isCorrect ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (!isCorrect) ...[
            const Text(
              'The correct answer is:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Text(
              correctAnswer,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            isCorrect 
                ? 'Great job! You got it right.'
                : 'Review this question for better understanding.',
            style: const TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}