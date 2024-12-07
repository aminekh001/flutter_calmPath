import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:calm_path/core/configs/assets/app_vectors.dart';
import 'package:calm_path/core/configs/theme/app_colors.dart';
import 'package:calm_path/common/widgets/app_bar/bottom_nav_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:calm_path/presentation/auth/pages/signupOrSignin.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Logout functionality
  void _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const Signuporsignin()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed: ${e.toString()}')),
      );
    }
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Logout"),
          content: const Text("Are you sure you want to log out?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _logout(context);
              },
              child: const Text("Logout"),
            ),
          ],
        );
      },
    );
  }

  // Greeting based on the time of day
  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  // Fetching the daily quote
  Future<Map<String, String>> fetchDailyQuote() async {
    final response = await http.get(Uri.parse('https://zenquotes.io/api/today'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return {
        'quote': data[0]['q'],
        'author': data[0]['a'],
      };
    } else {
      throw Exception('Failed to load quote');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        centerTitle: true,
        title: Image.asset(
          AppVectors.logoH,
          height: 100,
          width: 100,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: () => _confirmLogout(context),
            tooltip: "Logout",
          ),
        ],
        automaticallyImplyLeading: false,
      ),
      body: Container(
        color: Colors.black.withOpacity(0.1),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Greeting
              Text(
                '${getGreeting()}, [User Name]!',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 20),
              // Daily Quote
              FutureBuilder<Map<String, String>>(
                future: fetchDailyQuote(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return const Text(
                      'Failed to load quote',
                      style: TextStyle(
                        color: Colors.white70,
                        fontStyle: FontStyle.italic,
                      ),
                    );
                  } else {
                    final quote = snapshot.data?['quote'] ?? '';
                    final author = snapshot.data?['author'] ?? '';
                    return Column(
                      children: [
                        Text(
                          '"$quote"',
                          style: const TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '- $author',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ],
                    );
                  }
                },
              ),
              const SizedBox(height: 20),
              // Fox Image
              Image.asset(
                'assets/images/home.png',
                height: 200,
                width: 200,
              ),
              const SizedBox(height: 20),
              // Welcome Text
              const Text(
                'Welcome to Thryve',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 17,
                ),
              ),
              const SizedBox(height: 10),
              // Tagline
              const Text(
                'Explore gratitude and mindfulness for a calmer, more peaceful life',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: AppColors.grey,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const Align(
        alignment: Alignment.bottomCenter,
        child: BottomNavBar(currentIndex: 0),
      ),
    );
  }
}
