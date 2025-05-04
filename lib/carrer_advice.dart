import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CareerAdviceApp extends StatelessWidget {
  const CareerAdviceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Career Advisor',
    
      theme: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
      
        useMaterial3: true,
      ),
      home: const AdviceScreen(),
    );
  }
}

class GeminiService {
  static const String _apiKey = 'AIzaSyCxV8rOYgB3vojVaD0V7fkPJulniZ_3-1s';
  static const String _apiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

  static Future<String> getCareerAdvice(String skills) async {
    try {
      final response = await http.post(
        Uri.parse('$_apiUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {
                  "text": "Provide detailed career advice for someone with these skills: $skills.\n\n"
                      "Include:\n"
                      "1. Potential career paths\n"
                      "2. In-demand job fields\n"
                      "3. Market trends and salary insights\n"
                      "4. Recommended courses or certifications\n"
                      "5. Pro tips for growth\n\n"
                      "Format it with plain numbered points only. Avoid special characters like asterisks or markdown formatting."
                }
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['candidates'][0]['content']['parts'][0]['text'];
      }
      throw Exception('API Error: ${response.statusCode}');
    } catch (e) {
      throw Exception('Failed to get advice: $e');
    }
  }
}

class AdviceScreen extends StatefulWidget {
  const AdviceScreen({super.key});

  @override
  State<AdviceScreen> createState() => _AdviceScreenState();
}

class _AdviceScreenState extends State<AdviceScreen> {
  final TextEditingController _skillsController = TextEditingController();
  String _advice = '';
  bool _isLoading = false;

  Future<void> _getAdvice() async {
    FocusScope.of(context).unfocus();
    if (_skillsController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter some skills')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _advice = '';
    });

    try {
      final advice =
          await GeminiService.getCareerAdvice(_skillsController.text);
      setState(() => _advice = advice);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Career Advisor'),
        elevation: 4,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _skillsController,
                      decoration: InputDecoration(
                        labelText: 'Enter your skills',
                        hintText: 'e.g. programming, design, writing',
                        prefixIcon: const Icon(Icons.work_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _getAdvice,
                        icon: const Icon(Icons.auto_graph),
                        label: _isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Get Career Advice'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          textStyle: const TextStyle(fontSize: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: _advice.isEmpty
                  ? Center(
                      child: _isLoading
                          ? const Text('Generating advice...')
                          : const Text('Results will appear here.'),
                    )
                  : Scrollbar(
                      child: SingleChildScrollView(
                        child: Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              _advice,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
