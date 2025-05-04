import 'package:flutter/material.dart';
import 'resume_data.dart';

class AboutSection extends StatelessWidget {
  final ResumeData resume;

  const AboutSection({super.key, required this.resume});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          initialValue: resume.about,
          maxLines: 4,
          decoration: const InputDecoration(labelText: 'Professional Summary'),
          onSaved: (val) => resume.about = val ?? '',
        ),
      ],
    );
  }
}
