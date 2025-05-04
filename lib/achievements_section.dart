import 'package:flutter/material.dart';
import 'resume_data.dart';

class AchievementsSection extends StatefulWidget {
  final ResumeData resume;
  final Function() onChanged;

  const AchievementsSection({
    super.key, 
    required this.resume,
    required this.onChanged,
  });

  @override
  State<AchievementsSection> createState() => _AchievementsSectionState();
}

class _AchievementsSectionState extends State<AchievementsSection> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        ...widget.resume.achievements.asMap().entries.map((entry) {
          final index = entry.key;
          final achievement = entry.value;
          return Column(
            children: [
              _buildAchievementField(index, achievement),
              const SizedBox(height: 12),
            ],
          );
        }).toList(),
        _buildAddRemoveButtons(),
      ],
    );
  }

  Widget _buildAchievementField(int index, Achievement achievement) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          initialValue: achievement.title,
          decoration: const InputDecoration(
            labelText: 'Title',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            achievement.title = value;
            widget.onChanged();
          },
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: achievement.description,
          decoration: const InputDecoration(
            labelText: 'Description',
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
          onChanged: (value) {
            achievement.description = value;
            widget.onChanged();
          },
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: achievement.year,
          decoration: const InputDecoration(
            labelText: 'Year',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            achievement.year = value;
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
          onPressed: widget.resume.achievements.length > 1
              ? () {
                  setState(() {
                    widget.resume.achievements.removeLast();
                    widget.onChanged();
                  });
                }
              : null,
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: () {
            setState(() {
              widget.resume.achievements.add(Achievement());
              widget.onChanged();
            });
          },
        ),
      ],
    );
  }
}