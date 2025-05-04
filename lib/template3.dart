import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'resume_data.dart';

class Template3 {
  static pw.Page build(ResumeData resume) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.all(24),
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Header Section: Name and Profession
            pw.Container(
              width: double.infinity,
              padding: pw.EdgeInsets.symmetric(vertical: 24),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text(
                    resume.name,
                    style: pw.TextStyle(
                      fontSize: 28,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.black,
                    ),
                  ),
                  pw.Text(
                    resume.profession,
                    style: pw.TextStyle(
                      fontSize: 16,
                      color: PdfColors.black,
                    ),
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 16),

            // Contact & Skills section
            pw.Row(
              children: [
                // Left Column: Contact and Skills
                pw.Container(
                  width: 180,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _sectionTitle('Contact'),
                      _bullet('Phone: ${resume.phone}'),
                      _bullet('Email: ${resume.email}'),
                      if (resume.website.isNotEmpty) _bullet('Website: ${resume.website}'),
                      if (resume.linkedIn.isNotEmpty) _bullet('LinkedIn: ${resume.linkedIn}'),
                      if (resume.portfolio.isNotEmpty) _bullet('Portfolio: ${resume.portfolio}'),
                      if (resume.address.isNotEmpty) _bullet('Address: ${resume.address}'),
                      pw.SizedBox(height: 12),

                      _sectionTitle('Skills'),
                      _listBullets(resume.skills),
                    ],
                  ),
                ),

                pw.SizedBox(width: 30),

                // Right Column: Experience, Education, etc.
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _sectionTitle('Summary'),
                      pw.Text(resume.about, style: _bodyStyle()),
                      pw.SizedBox(height: 12),

                      _sectionTitle('Work Experience'),
                      ...resume.experience.map((exp) => pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          _boldText(exp.position),
                          pw.Text('${exp.company} | ${exp.year}', style: _mutedStyle()),
                          pw.Text(exp.description),
                          pw.SizedBox(height: 8),
                        ],
                      )),

                      _sectionTitle('Education'),
                      ...resume.education.map((edu) => pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          _boldText(edu.degree),
                          pw.Text('${edu.university} | ${edu.year}', style: _mutedStyle()),
                          pw.Text(edu.description),
                          pw.SizedBox(height: 8),
                        ],
                      )),

                      if (resume.certifications.any((c) => c.title.isNotEmpty)) ...[
                        _sectionTitle('Certifications'),
                        ...resume.certifications.map((cert) => pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            _boldText(cert.title),
                            pw.Text('${cert.organization} | ${cert.year}', style: _mutedStyle()),
                            pw.SizedBox(height: 8),
                          ],
                        )),
                      ],

                      if (resume.projects.any((p) => p.name.isNotEmpty)) ...[
                        _sectionTitle('Projects'),
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

                      if (resume.achievements.any((a) => a.title.isNotEmpty)) ...[
                        _sectionTitle('Achievements'),
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

                      if (resume.references.isNotEmpty) ...[
                        _sectionTitle('References'),
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
              ],
            ),
          ],
        );
      },
    );
  }

  static pw.Widget _sectionTitle(String title) {
    return pw.Padding(
      padding: pw.EdgeInsets.only(top: 12, bottom: 6),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 14,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.black,
        ),
      ),
    );
  }

  static pw.Widget _bullet(String text) {
    return pw.Text(text, style: _bodyStyle());
  }

  static pw.Widget _listBullets(List<String> items) {
    return pw.Column(
      children: items.map((item) => _bullet(item)).toList(),
    );
  }

  static pw.TextStyle _bodyStyle() {
    return pw.TextStyle(fontSize: 10, color: PdfColors.black);
  }

  static pw.Widget _boldText(String text) {
    return pw.Text(
      text,
      style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
    );
  }

  static pw.TextStyle _mutedStyle() {
    return pw.TextStyle(fontSize: 10, color: PdfColors.grey600);
  }
}
