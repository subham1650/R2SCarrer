import 'package:flutter/material.dart';
import 'resume_form.dart';
import 'template_card.dart';

class TemplateSelectionScreen extends StatelessWidget {
  const TemplateSelectionScreen({super.key});

  final List<Map<String, dynamic>> templates = const [
    {
      'name': 'Creative Professional',
      'image': 'assets/template1.png',
      'template': 1,
    },
    {
      'name': 'Modern Minimalist',
      'image': 'assets/template2.png',
      'template': 2,
    },
    {
      'name': 'Corporate Professional',
      'image': 'assets/template3.png',
      'template': 3,
    },
    {
      'name': 'Modern Professional',
      'image': 'assets/template4.png',
      'template': 4,
    },
    {
      'name': 'Clean Blue',
      'image': 'assets/template5.png',
      'template': 5,
    },
    {
      'name': 'Academic Style',
      'image': 'assets/template6.png',
      'template': 6,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resume Templates'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.7,
        ),
        itemCount: templates.length,
        itemBuilder: (context, index) {
          return TemplateCard(
            name: templates[index]['name'],
            image: templates[index]['image'],
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ResumeFormScreen(
                    template: templates[index]['template'],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
