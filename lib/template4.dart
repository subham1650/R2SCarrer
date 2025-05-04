import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'resume_data.dart';

class Template4 {
  static pw.Page build(ResumeData resume) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      build: (pw.Context context) {
        return pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Sidebar
            pw.Container(
              width: 180,
              color: PdfColors.blueGrey900,
              padding: const pw.EdgeInsets.all(16),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(resume.name,
                      style: pw.TextStyle(
                        fontSize: 22,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      )),
                  pw.SizedBox(height: 4),
                  pw.Text(resume.profession,
                      style: pw.TextStyle(
                        fontSize: 12,
                        color: PdfColors.grey300,
                      )),
                  pw.Divider(color: PdfColors.grey500, thickness: 1),
                  _sidebarSection('CONTACT', [
                    'Phone: ${resume.phone}',
                    'Email: ${resume.email}',
                    if (resume.website.isNotEmpty) 'Website: ${resume.website}',
                    if (resume.linkedIn.isNotEmpty) 'LinkedIn: ${resume.linkedIn}',
                    if (resume.portfolio.isNotEmpty) 'Portfolio: ${resume.portfolio}',
                    if (resume.address.isNotEmpty) 'Address: ${resume.address}',
                  ]),
                  _sidebarSection('SKILLS', resume.skills),
                  if (resume.languages.any((l) => l.isNotEmpty))
                    _sidebarSection('LANGUAGES', resume.languages),
                  if (resume.keywords.any((k) => k.isNotEmpty))
                    _sidebarSection('KEYWORDS', resume.keywords),
                ],
              ),
            ),
            // Main Content
            pw.Expanded(
              child: pw.Padding(
                padding: const pw.EdgeInsets.all(24),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('PROFILE'),
                    pw.Text(resume.about),
                    pw.SizedBox(height: 16),

                    _sectionTitle('EXPERIENCE'),
                    ...resume.experience.map((exp) => pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            _titleWithRightText(exp.position, exp.year),
                            pw.Text(exp.company,
                                style: pw.TextStyle(color: PdfColors.grey600)),
                            pw.Text(exp.description),
                            pw.SizedBox(height: 10),
                          ],
                        )),
                    pw.SizedBox(height: 12),

                    _sectionTitle('EDUCATION'),
                    ...resume.education.map((edu) => pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            _titleWithRightText(edu.degree, edu.year),
                            pw.Text(edu.university),
                            pw.Text(edu.description),
                            pw.SizedBox(height: 10),
                          ],
                        )),
                    pw.SizedBox(height: 12),

                    if (resume.projects.any((p) => p.name.isNotEmpty))
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          _sectionTitle('PROJECTS'),
                          ...resume.projects.map((proj) => pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text(proj.name,
                                      style: pw.TextStyle(
                                          fontWeight: pw.FontWeight.bold)),
                                  pw.Text('Tech Stack: ${proj.techStack}'),
                                  if (proj.link.isNotEmpty)
                                    pw.Text('Link: ${proj.link}'),
                                  pw.Text(proj.description),
                                  pw.SizedBox(height: 10),
                                ],
                              )),
                        ],
                      ),
                    pw.SizedBox(height: 12),

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
                        ],
                      ),
                    pw.SizedBox(height: 12),

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
                    pw.SizedBox(height: 12),

                    if (resume.references.isNotEmpty)
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          _sectionTitle('REFERENCES'),
                          ...resume.references.map((ref) => pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text(ref.name,
                                      style: pw.TextStyle(
                                          fontWeight: pw.FontWeight.bold)),
                                  pw.Text(ref.position),
                                  pw.Text(ref.contact),
                                  pw.SizedBox(height: 10),
                                ],
                              )),
                        ],
                      ),
                  ],
                ),
              ),
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
        fontSize: 16,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.blue900,
      ),
    );
  }

  static pw.Widget _titleWithRightText(String left, String right) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(left, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.Text(right, style: pw.TextStyle(color: PdfColors.grey600)),
      ],
    );
  }

  static pw.Widget _sidebarSection(String title, List<String> items) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(height: 12),
        pw.Text(title,
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            )),
        pw.SizedBox(height: 4),
        ...items.map((item) => pw.Text(
              item,
              style: pw.TextStyle(fontSize: 10, color: PdfColors.grey300),
            )),
      ],
    );
  }
}
