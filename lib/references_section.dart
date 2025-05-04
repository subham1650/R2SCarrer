import 'package:flutter/material.dart';
import 'resume_data.dart';

class ReferencesSection extends StatelessWidget {
  final ResumeData resume;

  const ReferencesSection({super.key, required this.resume});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
      
        ...resume.references.asMap().entries.map((entry) {
          final index = entry.key;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                initialValue: resume.references[index].name,
                decoration: InputDecoration(labelText: 'Reference Name ${index + 1}'),
                onSaved: (val) => resume.references[index].name = val ?? '',
              ),
              TextFormField(
                initialValue: resume.references[index].position,
                decoration: InputDecoration(labelText: 'Position ${index + 1}'),
                onSaved: (val) => resume.references[index].position = val ?? '',
              ),
              TextFormField(
                initialValue: resume.references[index].contact,
                decoration: InputDecoration(labelText: 'Contact ${index + 1}'),
                onSaved: (val) => resume.references[index].contact = val ?? '',
              ),
            ],
          );
        }).toList(),
      ],
    );
  }
}