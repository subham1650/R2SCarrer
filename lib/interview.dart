import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:r2scareer/Personal_interview.dart';
import 'text_based_interview.dart';
import 'voice_based_interview.dart';


enum InterviewStyle { text, voice, personal }

class SkillSelectionPage extends StatefulWidget {
  const SkillSelectionPage({super.key});

  @override
  State<SkillSelectionPage> createState() => _SkillSelectionPageState();
}

class _SkillSelectionPageState extends State<SkillSelectionPage> {
  final TextEditingController _skillController = TextEditingController();
  List<String> skills = [];
  final Set<String> selectedSkills = {};
  InterviewStyle selectedStyle = InterviewStyle.text;

  @override
  void initState() {
    super.initState();
    selectedSkills.clear();
    loadUserSkills();
  }

  Future<void> loadUserSkills() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('skills')
        .get();

    setState(() {
      skills = snapshot.docs.map((doc) => doc['name'] as String).toList();
    });
  }

  Future<void> addNewSkill() async {
    final newSkill = _skillController.text.trim();
    if (newSkill.isNotEmpty && !skills.contains(newSkill)) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('skills')
          .add({'name': newSkill});

      setState(() {
        skills.add(newSkill);
        _skillController.clear();
      });
    }
  }

  void toggleSkill(String skill) {
    setState(() {
      if (selectedSkills.contains(skill)) {
        selectedSkills.remove(skill);
      } else {
        if (selectedSkills.length < 5) {
          selectedSkills.add(skill);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("You can select up to 5 skills")),
          );
        }
      }
    });
  }

  Future<void> deleteSkill(String skill) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('skills')
        .where('name', isEqualTo: skill)
        .get();

    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }

    setState(() {
      skills.remove(skill);
      selectedSkills.remove(skill);
    });
  }

  void selectInterviewStyle(InterviewStyle style) {
    setState(() {
      selectedStyle = style;
    });
  }

  Future<void> startInterview() async {
    if (selectedSkills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("⚠️ Please select at least one skill."),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ User not logged in."),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final userId = user.uid;

    try {
      await FirebaseFirestore.instance.collection('interviews').add({
        'userId': userId,
        'selectedSkills': selectedSkills.toList(),
        'interviewStyle': selectedStyle.name,
        'timestamp': FieldValue.serverTimestamp(),
      });

      Widget nextPage;
      switch (selectedStyle) {
        case InterviewStyle.text:
          nextPage = MockInterviewPage(skills: selectedSkills.toList(), userId: userId, proficiencies: {},);
          break;
        case InterviewStyle.voice:
          nextPage = VoiceBasedInterviewPage(skills: selectedSkills.toList(), userId: userId, proficiencies: {},);
          break;
        case InterviewStyle.personal:
          nextPage = PersonalInterviewPage();
          break;
      }

      Navigator.push(context, MaterialPageRoute(builder: (context) => nextPage));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Error saving to Firebase: $e"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: const Color(0xFFF4F7FE),
      appBar: AppBar(
           backgroundColor: Colors.transparent,
           elevation: 0,
           centerTitle: true,
        title: const Text(
          'AI-Powered Mock Interview',
          style: TextStyle(fontSize: 17),
        ),
       
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Add Skill Field
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_outline, color: Colors.deepPurple),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _skillController,
                      decoration: const InputDecoration(
                        hintText: "Add a new skill",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: addNewSkill,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white
                    ),
                    child: const Text("Add"),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Selected Skills
            if (selectedSkills.isNotEmpty) ...[
              const Text("⭐️ Selected Skills",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: selectedSkills.map((skill) {
                  return InputChip(
                    label: Text(skill),
                    backgroundColor: Colors.deepPurple,
                    labelStyle: const TextStyle(color: Colors.white),
                    onDeleted: () => deleteSkill(skill),
                    deleteIcon: const Icon(Icons.cancel, size: 18, color: Colors.white),
                    onSelected: (_) => toggleSkill(skill),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
            ],

            const Text("💡 Available Skills",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: skills
                  .where((skill) => !selectedSkills.contains(skill))
                  .map((skill) => InputChip(
                        label: Text(skill),
                        backgroundColor: Colors.deepPurple.shade50,
                        labelStyle: const TextStyle(color: Colors.deepPurple),
                        onDeleted: () => deleteSkill(skill),
                        deleteIcon: const Icon(Icons.cancel, size: 18, color: Colors.redAccent),
                        onSelected: (_) => toggleSkill(skill),
                      ))
                  .toList(),
            ),

            const SizedBox(height: 24),
            const Text(
              "🎯 Choose Interview Style",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Column(
              children: InterviewStyle.values.map((style) {
                IconData icon;
                String title;
                String subtitle;

                switch (style) {
                  case InterviewStyle.text:
                    icon = Icons.chat;
                    title = "Aptitude Test";
                    subtitle = "Aptitude Q&A with AI";
                    break;
                  case InterviewStyle.voice:
                    icon = Icons.mic;
                    title = "Chat Interview";
                    subtitle = "Answer questions with chat";
                    break;
                  case InterviewStyle.personal:
                    icon = Icons.people;
                    title = "Personal Interview";
                    subtitle = "Personal based Interview";
                    break;
                }

                final isSelected = selectedStyle == style;

                return GestureDetector(
                  onTap: () => selectInterviewStyle(style),
                  child: Card(
                    color: isSelected ? Colors.deepPurple : Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: isSelected ? 4 : 2,
                    child: ListTile(
                      leading: Icon(icon, color: isSelected ? Colors.white : Colors.deepPurple),
                      title: Text(
                        title,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.deepPurple,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        subtitle,
                        style: TextStyle(
                          color: isSelected ? Colors.white70 : Colors.deepPurple.shade300,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle, color: Colors.white)
                          : null,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SizedBox(
          width: MediaQuery.of(context).size.width - 32,
          child: ElevatedButton.icon(
            onPressed: startInterview,
            icon: const Icon(Icons.play_arrow),
            label: const Text("Start Interview"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
  
  
}
