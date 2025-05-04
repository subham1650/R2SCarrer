import 'package:flutter/material.dart';
import 'resume_data.dart';

class ExperienceSection extends StatefulWidget {
  final ResumeData resume;
  final Function() onChanged;

  const ExperienceSection({
    super.key,
    required this.resume,
    required this.onChanged,
  });

  @override
  State<ExperienceSection> createState() => _ExperienceSectionState();
}

class _ExperienceSectionState extends State<ExperienceSection> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        ...widget.resume.experience.asMap().entries.map((entry) {
          final index = entry.key;
          return Column(
            children: [
              _buildExperienceFields(index),
              const SizedBox(height: 12),
            ],
          );
        }).toList(),
        _buildAddRemoveButtons(),
      ],
    );
  }

  Widget _buildExperienceFields(int index) {
    final experience = widget.resume.experience[index];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          initialValue: experience.position,
          decoration: InputDecoration(
            labelText: 'Position ${index + 1}',
            border: const OutlineInputBorder(),
          ),
          onChanged: (value) {
            experience.position = value;
            widget.onChanged();
          },
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: experience.company,
          decoration: InputDecoration(
            labelText: 'Company ${index + 1}',
            border: const OutlineInputBorder(),
          ),
          onChanged: (value) {
            experience.company = value;
            widget.onChanged();
          },
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: experience.year,
          decoration: InputDecoration(
            labelText: 'Year ${index + 1}',
            border: const OutlineInputBorder(),
          ),
          onChanged: (value) {
            experience.year = value;
            widget.onChanged();
          },
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: experience.description,
          decoration: InputDecoration(
            labelText: 'Description ${index + 1}',
            border: const OutlineInputBorder(),
          ),
          maxLines: 3,
          onChanged: (value) {
            experience.description = value;
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
          onPressed: widget.resume.experience.length > 1
              ? () {
                  setState(() {
                    widget.resume.experience.removeLast();
                    widget.onChanged();
                  });
                }
              : null,
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: () {
            setState(() {
              widget.resume.experience.add(Experience());
              widget.onChanged();
            });
          },
        ),
      ],
    );
  }
}
