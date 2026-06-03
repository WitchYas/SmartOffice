import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'package:appbot/screens/chat_screen.dart'; // ✅ Import ChatScreen

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FB),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/office.png', height: 200), // Your logo
            const SizedBox(height: 20),
            const Text(
              "Welcome to your Smart Office",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Control and monitor everything easily.",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 40),

            // ✅ Get Started button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: const Text("Get Started"),
            ),

            const SizedBox(height: 20),

            // ✅ Try Chatbot button using Builder to get correct context
            Builder(
              builder: (context) {
                return ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ChatScreen()),
                    );
                  },
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text("Try Chatbot"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
