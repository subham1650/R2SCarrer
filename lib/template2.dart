import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'resume_data.dart';

class Template2 {
  static pw.Page build(ResumeData resume) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      build: (pw.Context context) {
        return pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Left Sidebar
            pw.Container(
              width: 180,
              color: PdfColors.blueGrey800,
              padding: pw.EdgeInsets.all(16),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Profile Name and Profession
                  pw.Text(resume.name,
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                      )),
                  pw.Text(resume.profession,
                      style: pw.TextStyle(
                        color: PdfColors.grey300,
                        fontSize: 12,
                      )),
                  pw.Divider(color: PdfColors.grey500),

                  // Sidebar Sections
                  _infographicSection('CONTACT', [
                    'Phone: ${resume.phone}',
                    'Email: ${resume.email}',
                    if (resume.website.isNotEmpty) 'Website: ${resume.website}',
                    if (resume.linkedIn.isNotEmpty) 'LinkedIn: ${resume.linkedIn}',
                    if (resume.portfolio.isNotEmpty) 'Portfolio: ${resume.portfolio}',
                    if (resume.address.isNotEmpty) 'Address: ${resume.address}',
                  ]),
                  _infographicSection('SKILLS', resume.skills),
                  if (resume.languages.any((l) => l.isNotEmpty))
                    _infographicSection('LANGUAGES', resume.languages),
                  if (resume.keywords.any((k) => k.isNotEmpty))
                    _infographicSection('KEYWORDS', resume.keywords),
                ],
              ),
            ),

            // Right Content
            pw.Expanded(
              child: pw.Container(
                padding: pw.EdgeInsets.all(24),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Profile Section
                    _infographicSectionTitle('PROFILE'),
                    pw.Text(resume.about),
                    pw.SizedBox(height: 20),

                    // Experience Section
                    _infographicSectionTitle('EXPERIENCE'),
                    ...resume.experience.map((exp) => pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        _boldText(exp.position),
                        pw.Text('${exp.company} | ${exp.year}', style: _mutedStyle()),
                        pw.Text(exp.description),
                        pw.SizedBox(height: 10),
                      ],
                    )),

                    pw.SizedBox(height: 10),
                    _infographicSectionTitle('EDUCATION'),
                    ...resume.education.map((edu) => pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        _boldText(edu.degree),
                        pw.Text('${edu.university} | ${edu.year}', style: _mutedStyle()),
                        pw.Text(edu.description),
                        pw.SizedBox(height: 10),
                      ],
                    )),

                    // Adding a progress bar for certifications
                    if (resume.certifications.any((c) => c.title.isNotEmpty)) ...[
                      pw.SizedBox(height: 10),
                      _infographicSectionTitle('CERTIFICATIONS'),
                      ...resume.certifications.map((cert) => pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          _boldText(cert.title),
                          pw.Text('${cert.organization} | ${cert.year}', style: _mutedStyle()),
                          _progressBar(70), // Example: Adjust based on data
                          pw.SizedBox(height: 8),
                        ],
                      )),
                    ],

                    // Projects section with icons removed
                    if (resume.projects.any((p) => p.name.isNotEmpty)) ...[
                      pw.SizedBox(height: 10),
                      _infographicSectionTitle('PROJECTS'),
                      ...resume.projects.map((proj) => pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          _boldText(proj.name),
                          pw.Text('Tech: ${proj.techStack}', style: _mutedStyle()),
                          if (proj.link.isNotEmpty) pw.Text('Link: ${proj.link}'),
                          pw.Text(proj.description),
                          pw.SizedBox(height: 8),
                        ],
                      )),
                    ],

                    // Achievements section with progress bars removed
                    if (resume.achievements.any((a) => a.title.isNotEmpty)) ...[
                      pw.SizedBox(height: 10),
                      _infographicSectionTitle('ACHIEVEMENTS'),
                      ...resume.achievements.map((ach) => pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          _boldText(ach.title),
                          pw.Text('${ach.year}', style: _mutedStyle()),
                          pw.Text(ach.description),
                          pw.SizedBox(height: 8),
                        ],
                      )),
                    ],

                    // References Section
                    if (resume.references.isNotEmpty) ...[
                      pw.SizedBox(height: 10),
                      _infographicSectionTitle('REFERENCES'),
                      ...resume.references.map((ref) => pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          _boldText(ref.name),
                          pw.Text(ref.position),
                          pw.Text(ref.contact),
                          pw.SizedBox(height: 8),
                        ],
                      )),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Infographic section with background color for visual appeal
  static pw.Widget _infographicSection(String title, List<String> items) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(height: 16),
        pw.Text(title.toUpperCase(),
            style: pw.TextStyle(
              color: PdfColors.white,
              fontWeight: pw.FontWeight.bold,
              fontSize: 10,
            )),
        pw.SizedBox(height: 6),
        ...items.where((item) => item.isNotEmpty).map((item) =>
            pw.Text(item, style: pw.TextStyle(color: PdfColors.grey300, fontSize: 9))),
      ],
    );
  }

  // Section title style
  static pw.Widget _infographicSectionTitle(String title) {
    return pw.Text(
      title,
      style: pw.TextStyle(
        fontSize: 16,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.blue800,
      ),
    );
  }

  // Muted text style for less important text
  static pw.TextStyle _mutedStyle() {
    return pw.TextStyle(fontSize: 10, color: PdfColors.grey700);
  }

  // Bold text style
  static pw.Widget _boldText(String text) {
    return pw.Text(
      text,
      style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
    );
  }

  // Example progress bar for certifications or skills
  static pw.Widget _progressBar(double progress) {
    return pw.Container(
      width: 100,
      height: 5,
      decoration: pw.BoxDecoration(
        color: PdfColors.grey300,
        borderRadius: pw.BorderRadius.circular(3),
      ),
      child: pw.Container(
        width: progress,
        height: 5,
        color: PdfColors.blue800,
      ),
    );
  }
}
