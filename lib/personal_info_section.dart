// personal_info_section.dart
import 'package:flutter/material.dart';
import 'resume_data.dart';

class PersonalInfoSection extends StatelessWidget {
  final ResumeData resume;

  const PersonalInfoSection({super.key, required this.resume});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        
        TextFormField(
          initialValue: resume.name,
          decoration: const InputDecoration(labelText: 'Full Name'),
          onSaved: (val) => resume.name = val ?? '',
        ),
        TextFormField(
          initialValue: resume.profession,
          decoration: const InputDecoration(labelText: 'Profession'),
          onSaved: (val) => resume.profession = val ?? '',
        ),
        TextFormField(
          initialValue: resume.phone,
          decoration: const InputDecoration(labelText: 'Phone Number'),
          onSaved: (val) => resume.phone = val ?? '',
        ),
        TextFormField(
          initialValue: resume.email,
          decoration: const InputDecoration(labelText: 'Email Address'),
          onSaved: (val) => resume.email = val ?? '',
        ),
        TextFormField(
          initialValue: resume.address,
          decoration: const InputDecoration(labelText: 'Address'),
          onSaved: (val) => resume.address = val ?? '',
        ),
        TextFormField(
          initialValue: resume.website,
          decoration: const InputDecoration(labelText: 'Website or LinkedIn'),
          onSaved: (val) => resume.website = val ?? '',
        ),
      ],
    );
  }
}



