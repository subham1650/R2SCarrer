// TODO Implement this library.
import 'package:flutter/material.dart';
import 'resume_data.dart';

class SkillsSection extends StatefulWidget {
  final ResumeData resume;

  const SkillsSection({super.key, required this.resume});

  @override
  State<SkillsSection> createState() => _SkillsSectionState();
}

class _SkillsSectionState extends State<SkillsSection> {
  void _addSkill() {
    setState(() {
      widget.resume.skills.add('');
    });
  }

  void _removeSkill(int index) {
    if (widget.resume.skills.length > 1) {
      setState(() {
        widget.resume.skills.removeAt(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        
        const SizedBox(height: 10),
        ...widget.resume.skills.asMap().entries.map((entry) {
          int index = entry.key;
          return Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Skill ${index + 1}',
                    border: const OutlineInputBorder(),
                  ),
                  onSaved: (value) => widget.resume.skills[index] = value ?? '',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter skill';
                    }
                    return null;
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.remove_circle),
                onPressed: () => _removeSkill(index),
              ),
            ],
          );
        }).toList(),
        ElevatedButton(
          onPressed: _addSkill,
          child: const Text('Add Skill'),
        ),
      ],
    );
  }
}