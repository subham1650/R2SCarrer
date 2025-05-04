import 'package:flutter/material.dart';
import 'resume_data.dart';

class KeywordsSection extends StatefulWidget {
  final ResumeData resume;

  const KeywordsSection({super.key, required this.resume});

  @override
  State<KeywordsSection> createState() => _KeywordsSectionState();
}

class _KeywordsSectionState extends State<KeywordsSection> {
  void _addKeyword() {
    setState(() {
      widget.resume.keywords.add('');
    });
  }

  void _removeKeyword(int index) {
    if (widget.resume.keywords.length > 1) {
      setState(() {
        widget.resume.keywords.removeAt(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        
        const SizedBox(height: 10),
        ...widget.resume.keywords.asMap().entries.map((entry) {
          final index = entry.key;
          return Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: widget.resume.keywords[index],
                  decoration: InputDecoration(
                    labelText: 'Keyword ${index + 1}',
                    border: const OutlineInputBorder(),
                  ),
                  onSaved: (val) => widget.resume.keywords[index] = val ?? '',
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter a keyword';
                    }
                    return null;
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.remove_circle),
                onPressed: () => _removeKeyword(index),
              ),
            ],
          );
        }).toList(),
        ElevatedButton(
          onPressed: _addKeyword,
          child: const Text('Add Keyword'),
        ),
      ],
    );
  }
}
