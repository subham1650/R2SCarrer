import 'package:flutter/material.dart';
import 'resume_data.dart';

class EducationSection extends StatefulWidget {
  final ResumeData resume;
  final Function() onChanged;

  const EducationSection({
    super.key,
    required this.resume,
    required this.onChanged,
  });

  @override
  State<EducationSection> createState() => _EducationSectionState();
}

class _EducationSectionState extends State<EducationSection> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        ...widget.resume.education.asMap().entries.map((entry) {
          final index = entry.key;
          return Column(
            children: [
              _buildEducationFields(index),
              const SizedBox(height: 12),
            ],
          );
        }).toList(),
        _buildAddRemoveButtons(),
      ],
    );
  }

  Widget _buildEducationFields(int index) {
    final education = widget.resume.education[index];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          initialValue: education.degree,
          decoration: InputDecoration(
            labelText: 'Degree ${index + 1}',
            border: const OutlineInputBorder(),
          ),
          onChanged: (value) {
            education.degree = value;
            widget.onChanged();
          },
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: education.university,
          decoration: InputDecoration(
            labelText: 'University ${index + 1}',
            border: const OutlineInputBorder(),
          ),
          onChanged: (value) {
            education.university = value;
            widget.onChanged();
          },
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: education.year,
          decoration: InputDecoration(
            labelText: 'Year ${index + 1}',
            border: const OutlineInputBorder(),
          ),
          onChanged: (value) {
            education.year = value;
            widget.onChanged();
          },
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: education.description,
          decoration: InputDecoration(
            labelText: 'Description ${index + 1}',
            border: const OutlineInputBorder(),
          ),
          maxLines: 3,
          onChanged: (value) {
            education.description = value;
            widget.onChanged();
          },
        ),
      ],
    );
  }

  Widget _buildAddRemoveButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          icon: const Icon(Icons.remove_circle_outline),
          onPressed: widget.resume.education.length > 1
              ? () {
                  setState(() {
                    widget.resume.education.removeLast();
                    widget.onChanged();
                  });
                }
              : null,
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: () {
            setState(() {
              widget.resume.education.add(Education());
              widget.onChanged();
            });
          },
        ),
      ],
    );
  }
}
