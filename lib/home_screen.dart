import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:r2scareer/carrer_advice.dart';
import 'package:r2scareer/cover_letter_generator.dart';
import 'package:r2scareer/template_selection.dart';
import 'package:r2scareer/interview.dart'; // Import the Interview Mode screen
import 'package:r2scareer/login.dart'; // Create this login screen for navigation

class CareerAIHomeScreen extends StatelessWidget {
  
  CareerAIHomeScreen({super.key});

  // FirebaseAuth instance for sign-out
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sign out method
  Future<void> _signOut(BuildContext context) async {
    try {
      await _auth.signOut();
      // Navigate to the login screen after sign-out
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } catch (e) {
      print('Sign out error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'R2SCareer',
          style: TextStyle(
            color: Colors.deepPurple,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () => _signOut(context),
            tooltip: 'Logout',
            color: Colors.deepPurple,
            iconSize: 30,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAppBanner(),
            const SizedBox(height: 20),
            const Text(
              'Main Features',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildMainFeaturesGrid(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7B61FF), Color(0xFF5737FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Empowering Your Career Journey",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            "Create resumes, cover letters, and prepare for interviews.",
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildMainFeaturesGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildFeatureCard(Icons.description, "Create Resume", () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TemplateSelectionScreen(),
            ),
          );
        }),
        _buildFeatureCard(Icons.edit_note, "AI Cover Letter", () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CoverLetterPage(),
            ),
          );
        }),
        _buildFeatureCard(Icons.mic, "Mock Interview", () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SkillSelectionPage(),
            ),
          );
        }),
        _buildFeatureCard(Icons.lightbulb_outline, "Career Advice", () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AdviceScreen(),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildFeatureCard(IconData icon, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.deepPurple, size: 32),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
