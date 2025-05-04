import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'resume_data.dart';

class Template1 {
  static pw.Page build(ResumeData resume) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Header with Name and Profession (without image)
            pw.Row(
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      resume.name,
                      style: pw.TextStyle(
                        fontSize: 28,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      resume.profession,
                      style: pw.TextStyle(
                        fontSize: 16,
                        color: PdfColors.grey600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 20),

            // Contact Information
            pw.Wrap(
              spacing: 10,
              children: [
                pw.Text('Phone: ${resume.phone}'),
                pw.Text('Email: ${resume.email}'),
                if (resume.website.isNotEmpty) pw.Text('Website: ${resume.website}'),
                if (resume.linkedIn.isNotEmpty) pw.Text('LinkedIn: ${resume.linkedIn}'),
                if (resume.portfolio.isNotEmpty) pw.Text('Portfolio: ${resume.portfolio}'),
                if (resume.address.isNotEmpty) pw.Text('Address: ${resume.address}'),
              ],
            ),
            pw.Divider(thickness: 2),
            pw.SizedBox(height: 20),

            // About Section
            _sectionTitle('PROFILE'),
            pw.Text(resume.about),
            pw.SizedBox(height: 20),

            // Experience Section
            _sectionTitle('EXPERIENCE'),
            ...resume.experience.map((exp) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _titleWithRightText(exp.position, exp.year),
                pw.Text(exp.company, style: pw.TextStyle(color: PdfColors.grey600)),
                pw.Text(exp.description),
                pw.SizedBox(height: 15),
              ],
            )),
            pw.SizedBox(height: 20),

            // Education Section
            _sectionTitle('EDUCATION'),
            ...resume.education.map((edu) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _titleWithRightText(edu.degree, edu.year),
                pw.Text(edu.university),
                pw.Text(edu.description),
                pw.SizedBox(height: 15),
              ],
            )),
            pw.SizedBox(height: 20),

            // Skills and References Side-by-Side
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _columnSection('SKILLS', resume.skills.map((s) => '- $s').toList()),
                pw.SizedBox(width: 20),
                _referenceSection(resume.references),
              ],
            ),
            pw.SizedBox(height: 20),

            // Certifications
            if (resume.certifications.any((c) => c.title.isNotEmpty))
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _sectionTitle('CERTIFICATIONS'),
                  ...resume.certifications.map((cert) => pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _titleWithRightText(cert.title, cert.year),
                      pw.Text(cert.organization),
                      pw.SizedBox(height: 10),
                    ],
                  )),
                  pw.SizedBox(height: 20),
                ],
              ),

            // Projects
            if (resume.projects.any((p) => p.name.isNotEmpty))
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _sectionTitle('PROJECTS'),
                  ...resume.projects.map((proj) => pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(proj.name, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text('Tech Stack: ${proj.techStack}'),
                      if (proj.link.isNotEmpty) pw.Text('Link: ${proj.link}'),
                      pw.Text(proj.description),
                      pw.SizedBox(height: 10),
                    ],
                  )),
                  pw.SizedBox(height: 20),
                ],
              ),

            // Achievements
            if (resume.achievements.any((a) => a.title.isNotEmpty))
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _sectionTitle('ACHIEVEMENTS'),
                  ...resume.achievements.map((ach) => pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _titleWithRightText(ach.title, ach.year),
                      pw.Text(ach.description),
                      pw.SizedBox(height: 10),
                    ],
                  )),
                ],
              ),

            // Languages and Keywords
            if (resume.languages.any((l) => l.isNotEmpty) || resume.keywords.any((k) => k.isNotEmpty))
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.SizedBox(height: 20),
                  if (resume.languages.any((l) => l.isNotEmpty))
                    _columnSection('LANGUAGES', resume.languages.map((l) => '- $l').toList()),
                  if (resume.keywords.any((k) => k.isNotEmpty))
                    _columnSection('KEYWORDS', resume.keywords.map((k) => '- $k').toList()),
                ],
              ),
          ],
        );
      },
    );
  }

  static pw.Widget _sectionTitle(String title) {
    return pw.Text(
      title,
      style: pw.TextStyle(
        fontSize: 18,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.blue800,
      ),
    );
  }

  static pw.Widget _titleWithRightText(String left, String right) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          left,
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16),
        ),
        pw.Text(right),
      ],
    );
  }

  static pw.Widget _columnSection(String title, List<String> items) {
    return pw.Expanded(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _sectionTitle(title),
          pw.SizedBox(height: 10),
          ...items.map((item) => pw.Text(item)),
        ],
      ),
    );
  }

  static pw.Widget _referenceSection(List<Reference> refs) {
    return pw.Expanded(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _sectionTitle('REFERENCES'),
          pw.SizedBox(height: 10),
          ...refs.map((ref) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(ref.name, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text(ref.position),
              pw.Text(ref.contact),
              pw.SizedBox(height: 10),
            ],
          )),
        ],
      ),
    );
  }
}
