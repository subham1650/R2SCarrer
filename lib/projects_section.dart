import 'package:flutter/material.dart';
import 'resume_data.dart';

class ProjectsSection extends StatefulWidget {
  final ResumeData resume;
  final Function() onChanged;

  const ProjectsSection({
    super.key, 
    required this.resume,
    required this.onChanged,
  });

  @override
  State<ProjectsSection> createState() => _ProjectsSectionState();
}

class _ProjectsSectionState extends State<ProjectsSection> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
    
        const SizedBox(height: 8),
        ...widget.resume.projects.asMap().entries.map((entry) {
          final index = entry.key;
          final project = entry.value;
          return Column(
            children: [
              _buildProjectFields(index, project),
              const SizedBox(height: 12),
            ],
          );
        }).toList(),
        _buildAddRemoveButtons(),
      ],
    );
  }

  Widget _buildProjectFields(int index, Project project) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          initialValue: project.name,
          decoration: const InputDecoration(
            labelText: 'Project Name',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            project.name = value;
            widget.onChanged();
          },
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: project.description,
          decoration: const InputDecoration(
            labelText: 'Description',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          onChanged: (value) {
            project.description = value;
            widget.onChanged();
          },
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: project.techStack,
          decoration: const InputDecoration(
            labelText: 'Technologies Used',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            project.techStack = value;
            widget.onChanged();
          },
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: project.link,
          decoration: const InputDecoration(
            labelText: 'Project Link (URL)',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            project.link = value;
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
          onPressed: widget.resume.projects.length > 1
              ? () {
                  setState(() {
                    widget.resume.projects.removeLast();
                    widget.onChanged();
                  });
                }
              : null,
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: () {
            setState(() {
              widget.resume.projects.add(Project());
              widget.onChanged();
            });
          },
        ),
      ],
    );
  }
}