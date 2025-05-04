import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:r2scareer/template3.dart';
import 'package:r2scareer/template5.dart';
import 'package:r2scareer/template6.dart';
import 'resume_data.dart';
import 'about_section.dart';
import 'education_section.dart';
import 'experience_section.dart';
import 'personal_info_section.dart';
import 'references_section.dart';
import 'skills_section.dart';
import 'template1.dart';
import 'template2.dart';
import 'template4.dart';
import 'certifications_section.dart';
import 'projects_section.dart';
import 'achievements_section.dart';
import 'languages_section.dart';
import 'keywords_section.dart';
import 'package:flutter/foundation.dart';

class ResumeFormScreen extends StatefulWidget {
  final int template;

  const ResumeFormScreen({super.key, required this.template});

  @override
  State<ResumeFormScreen> createState() => _ResumeFormScreenState();
}

class _ResumeFormScreenState extends State<ResumeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final ResumeData _resume = ResumeData();

  // Generate PDF function
  Future<void> _generatePdf() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }
    _formKey.currentState!.save();

    try {
      final pdf = pw.Document();

      // Switch template based on selected template number
      switch (widget.template) {
        case 1:
          pdf.addPage(Template1.build(_resume));
          break;
        case 2:
          pdf.addPage(Template2.build(_resume));
          break;
        case 3:
          pdf.addPage(Template3.build(_resume));
          break; 
        case 4:
          pdf.addPage(Template4.build(_resume));
          break;    
        case 5:
          pdf.addPage(Template5.build(_resume));
          break;  
        case 6:
          pdf.addPage(Template6.build(_resume));
        default:
          pdf.addPage(Template1.build(_resume));
      }

      // Display PDF layout
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF generated successfully!')),
      );
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Error generating PDF: $e');
        print('Stack trace: $stackTrace');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating PDF: ${e.toString()}'),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Card(
      elevation: 6,
      color: Colors.blueGrey.shade50,
      margin: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Removed the Row with Icon
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurpleAccent,
              ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Build Your Resume'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _generatePdf,
            tooltip: 'Generate PDF',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection(
                title: 'Personal Information',
                child: PersonalInfoSection(resume: _resume),
              ),
              _buildSection(
                title: 'About You',
                child: AboutSection(resume: _resume),
              ),
              _buildSection(
                title: 'Education',
                child: EducationSection(resume: _resume, onChanged: () {}),
              ),
              _buildSection(
                title: 'Experience',
                child: ExperienceSection(resume: _resume, onChanged: () {}),
              ),
              _buildSection(
                title: 'Skills',
                child: SkillsSection(resume: _resume),
              ),
              _buildSection(
                title: 'Certifications',
                child: CertificationsSection(resume: _resume, onChanged: () {}),
              ),
              _buildSection(
                title: 'Projects',
                child: ProjectsSection(resume: _resume, onChanged: () {}),
              ),
              _buildSection(
                title: 'Achievements',
                child: AchievementsSection(resume: _resume, onChanged: () {}),
              ),
              _buildSection(
                title: 'Languages',
                child: LanguagesSection(resume: _resume),
              ),
              _buildSection(
                title: 'Keywords',
                child: KeywordsSection(resume: _resume),
              ),
              _buildSection(
                title: 'References',
                child: ReferencesSection(resume: _resume),
              ),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: _generatePdf,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                  ),
                  child: const Text(
                    'Generate PDF',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _generatePdf,
        backgroundColor: Colors.deepPurple,
        tooltip: 'Generate PDF',
        child: const Icon(Icons.picture_as_pdf, color: Colors.white),
      ),
    );
  }
}
