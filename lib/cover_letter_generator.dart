import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'cover_letter_result_page.dart';

class CoverLetterPage extends StatefulWidget {
  const CoverLetterPage({Key? key}) : super(key: key);

  @override
  State<CoverLetterPage> createState() => _CoverLetterPageState();
}

class _CoverLetterPageState extends State<CoverLetterPage> {
  final _formKey = GlobalKey<FormState>();

  // Basic Info Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _portfolioController = TextEditingController();
  final _dateController = TextEditingController();

  // Recipient Info
  final _managerNameController = TextEditingController();
  final _managerTitleController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _companyAddressController = TextEditingController();
  final _jobTitleController = TextEditingController();
  final _platformController = TextEditingController();

  // Additional Experience Info
  final _experienceController = TextEditingController();
  final _industryController = TextEditingController();
  final _expertiseAreasController = TextEditingController();
  final _skillsController = TextEditingController();
  final _otherSkillsController = TextEditingController();
  final _jobDescController = TextEditingController();

  // Personalization
  final _toneController = TextEditingController();
  final _languageController = TextEditingController();
  final _keywordsController = TextEditingController();
  final _achievementsController = TextEditingController();

  bool _isLoading = false;

  Future<String> generateCoverLetter() async {
    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=AIzaSyCxV8rOYgB3vojVaD0V7fkPJulniZ_3-1s',
    );

    final prompt = '''
Generate a professional cover letter using the following details:

Full Name: ${_nameController.text}
Address: ${_addressController.text}
Phone Number: ${_phoneController.text}
Email: ${_emailController.text}
Date: ${_dateController.text}
LinkedIn: ${_linkedinController.text}
Portfolio: ${_portfolioController.text}

Hiring Manager Name: ${_managerNameController.text}
Hiring Manager Position: ${_managerTitleController.text}
Job Title: ${_jobTitleController.text}
Company Name: ${_companyNameController.text}
Company Address: ${_companyAddressController.text}
Platform where job was posted: ${_platformController.text}

Years of Experience: ${_experienceController.text}
Industry: ${_industryController.text}
Key Expertise: ${_expertiseAreasController.text}
Core Skills: ${_skillsController.text}
Other Relevant Skills: ${_otherSkillsController.text}
Job Description: ${_jobDescController.text}

Tone: ${_toneController.text}
Language: ${_languageController.text}
Keywords: ${_keywordsController.text}
Achievements: ${_achievementsController.text}

IMPORTANT INSTRUCTIONS:
- Start with full basic information (name, email, phone, etc.) in the first paragraph one by one.
- Hiring manager name, position and company name one below one
=== OPENING PARAGRAPH (Why you're writing) ===
- State the specific position you're applying for (${_jobTitleController.text} at ${_companyNameController.text})
- Briefly mention where you found the opportunity (${_platformController.text})
- Express genuine enthusiasm about the role/company
- Keep concise (3-4 sentences max)

- if user not input any field donot show it like[LinkedIn] etc.
- Use a professional tone throughout.
- Paragraph contain maximum 250 word.
- Personalize the letter based on the experience, industry, expertise, skills, job description, and achievements.
- DO NOT use placeholders like [Your Name] or [Phone Number].
- ONLY return the final cover letter. DONOT bullet points, comments.
- paragraph Donot placeholder like [company name] or explanations.
- Only return the final polished cover letter text, ready to be sent.
- End properly with "Sincerely," and full name.

''';

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': prompt}
            ]
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['candidates'][0]['content']['parts'][0]['text'];
    } else {
      throw Exception('Failed to generate cover letter');
    }
  }

  void _onGeneratePressed() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final letter = await generateCoverLetter();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CoverLetterResultPage(letterContent: letter),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: const Color(0xFFF4F7FE),
      appBar: AppBar(
        centerTitle: true,
        title: const Text(' Cover Letter Generator', style: TextStyle(fontSize: 17),),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildSectionHeader('Basic Information'),
              _buildCard(
                children: [
                  _buildTextField(_nameController, 'Full Name', Icons.person),
                  _buildTextField(_emailController, 'Email', Icons.email),
                  _buildTextField(_phoneController, 'Phone', Icons.phone),
                  _buildTextField(_addressController, 'Address', Icons.home),
                  _buildTextField(_linkedinController, 'LinkedIn (optional)', Icons.link),
                  _buildTextField(_portfolioController, 'Portfolio/Website (optional)', Icons.web),
                  _buildTextField(_dateController, 'Date (e.g. April 26, 2025)', Icons.date_range),
                ],
              ),

              const SizedBox(height: 20),
              _buildSectionHeader('Hiring Manager / Company Information'),
              _buildCard(
                children: [
                  _buildTextField(_managerNameController, 'Hiring Manager\'s Name', Icons.person_add_alt),
                  _buildTextField(_managerTitleController, 'Hiring Manager\'s Position (optional)', Icons.badge),
                  _buildTextField(_companyNameController, 'Company Name', Icons.business),
                  _buildTextField(_companyAddressController, 'Company Address (optional)', Icons.location_on),
                  _buildTextField(_jobTitleController, 'Job Title Applied For', Icons.work),
                  _buildTextField(_platformController, 'Platform where job was posted', Icons.web_asset),
                ],
              ),

              const SizedBox(height: 20),
              _buildSectionHeader('Experience and Skills'),
              _buildCard(
                children: [
                  _buildTextField(_experienceController, 'Years of Experience', Icons.timeline),
                  _buildTextField(_industryController, 'Industry', Icons.apartment),
                  _buildTextField(_expertiseAreasController, 'Key Expertise Areas', Icons.psychology),
                  _buildTextField(_skillsController, 'Core Skills', Icons.build),
                  _buildTextField(_otherSkillsController, 'Other Relevant Skills', Icons.extension),
                  _buildTextField(_jobDescController, 'Job Description Highlights', Icons.assignment),
                ],
              ),

              const SizedBox(height: 20),
              _buildSectionHeader('Personalization'),
              _buildCard(
                children: [
                  _buildTextField(_toneController, 'Tone Preference (e.g. Professional)', Icons.format_bold),
                  _buildTextField(_languageController, 'Language (e.g. English)', Icons.language),
                  _buildTextField(_keywordsController, 'Important Keywords (optional)', Icons.search),
                  _buildTextField(_achievementsController, 'Achievements/Metrics to Highlight', Icons.star),
                ],
              ),

              const SizedBox(height: 30),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _onGeneratePressed,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Generate Cover Letter',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.deepPurple.shade800,
        ),
      ),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Card(
      elevation: 5,
      shadowColor: Colors.deepPurple,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.deepPurple),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.deepPurple),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.deepPurple, width: 2),
          ),
        ),
        validator: (value) => (label.contains('(optional)') || value!.isNotEmpty) ? null : 'Required',
      ),
    );
  }
}
