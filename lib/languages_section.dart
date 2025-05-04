import 'package:flutter/material.dart';
import 'resume_data.dart';

class LanguagesSection extends StatefulWidget {
  final ResumeData resume;

  const LanguagesSection({super.key, required this.resume});

  @override
  State<LanguagesSection> createState() => _LanguagesSectionState();
}

class _LanguagesSectionState extends State<LanguagesSection> {
  void _addLanguage() {
    setState(() {
      widget.resume.languages.add('');
    });
  }

  void _removeLanguage(int index) {
    if (widget.resume.languages.length > 1) {
      setState(() {
        widget.resume.languages.removeAt(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        ...widget.resume.languages.asMap().entries.map((entry) {
          final index = entry.key;
          return Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: widget.resume.languages[index],
                  decoration: InputDecoration(
                    labelText: 'Language ${index + 1}',
                    border: const OutlineInputBorder(),
                  ),
                  onSaved: (val) => widget.resume.languages[index] = val ?? '',
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter a language';
                    }
                    return null;
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.remove_circle),
                onPressed: () => _removeLanguage(index),
              ),
            ],
          );
        }).toList(),
        ElevatedButton(
          onPressed: _addLanguage,
          child: const Text('Add Language'),
        ),
      ],
    );
  }
}
