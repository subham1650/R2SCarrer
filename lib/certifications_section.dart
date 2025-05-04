import 'package:flutter/material.dart';
import 'resume_data.dart';

class CertificationsSection extends StatefulWidget {
  final ResumeData resume;
  final Function() onChanged;

  const CertificationsSection({
    super.key, 
    required this.resume,
    required this.onChanged,
  });

  @override
  State<CertificationsSection> createState() => _CertificationsSectionState();
}

class _CertificationsSectionState extends State<CertificationsSection> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        ...widget.resume.certifications.asMap().entries.map((entry) {
          final index = entry.key;
          final certification = entry.value;
          return Column(
            children: [
              _buildCertificationField(index, certification),
              const SizedBox(height: 12),
            ],
          );
        }).toList(),
        _buildAddRemoveButtons(),
      ],
    );
  }

  Widget _buildCertificationField(int index, Certification certification) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          initialValue: certification.title,
          decoration: const InputDecoration(
            labelText: 'Certification Title',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            certification.title = value;
            widget.onChanged();
          },
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: certification.organization,
          decoration: const InputDecoration(
            labelText: 'Issuing Organization',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            certification.organization = value;
            widget.onChanged();
          },
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: certification.year,
          decoration: const InputDecoration(
            labelText: 'Year Obtained',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            certification.year = value;
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
          onPressed: widget.resume.certifications.length > 1
              ? () {
                  setState(() {
                    widget.resume.certifications.removeLast();
                    widget.onChanged();
                  });
                }
              : null,
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: () {
            setState(() {
              widget.resume.certifications.add(Certification());
              widget.onChanged();
            });
          },
        ),
      ],
    );
  }
}