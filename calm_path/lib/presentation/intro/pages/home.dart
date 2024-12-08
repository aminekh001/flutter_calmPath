import 'dart:convert';
import 'package:calm_path/core/configs/theme/app_colors.dart';
import 'package:calm_path/core/configs/theme/color_palette.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:calm_path/common/widgets/app_bar/bottom_nav_bar.dart';
import 'package:calm_path/presentation/auth/pages/signupOrSignin.dart';
import 'package:calm_path/core/configs/assets/app_vectors.dart';

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

  // Confirm logout with a dialog
  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Logout"),
          content: const Text("Are you sure you want to log out?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Close dialog
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                _logout(context); // Perform logout
              },
              child: const Text("Logout"),
            ),
          ],
        );
      },
    );
  }

  // Fetching the daily quote
  Future<Map<String, String>> fetchDailyQuote() async {
    try {
      final response = await http.get(Uri.parse('https://zenquotes.io/api/today'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return {
          'quote': data[0]['q'],
          'author': data[0]['a'],
        };
      } else {
        return {
          'quote': 'Unable to fetch quote at the moment.',
          'author': '',
        };
      }
    } catch (e) {
      return {
        'quote': 'An error occurred while fetching the quote.',
        'author': '',
      };
    }
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

  // Fetching the username
  String getUsername() {
    final User? user = FirebaseAuth.instance.currentUser;
    return user?.displayName ?? 'User';
  }

  @override
  Widget build(BuildContext context) {
    final String greeting = getGreeting();
    final String username = getUsername();

    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          AppVectors.logoH,
          height: 100,
          width: 100,
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _confirmLogout(context),
            icon: const Icon(
              Icons.logout,
              color: Colors.red,
            ),
          ),
        ],
        automaticallyImplyLeading: false,
      ),
body: Container(
  decoration: BoxDecoration(
    color: Colors.transparent, // Keep the existing background
  ),
  child: SafeArea(
    child: SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Daily Quote Section in a Card
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            color: ColorPalette.colors.first.withOpacity(0.4), // Use app's white color

            child: Padding(
              padding: const EdgeInsets.all(20),
              child: FutureBuilder<Map<String, String>>(
                future: fetchDailyQuote(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return const Text(
                      'Failed to load quote',
                      style: TextStyle(
                        color: Colors.white,
                        fontStyle: FontStyle.italic,
                      ),
                    );
                  } else {
                    final quote = snapshot.data?['quote'] ?? '';
                    final author = snapshot.data?['author'] ?? '';
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '"$quote"',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.grey, // App’s grey color
                            fontStyle: FontStyle.italic,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            '- $author',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.grey,
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
          ),


          // Dynamic Greeting Section
          Text(
            '${getGreeting()}, $username!',
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white, // Keep greeting text in black
              letterSpacing: 1.1,
            ),
            textAlign: TextAlign.left,
          ),

          // Image Section
          Center(
            child: Image.asset(
              'assets/images/home.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Text(
                  "Image not found",
                  style: TextStyle(color: Colors.red),
                );
              },
            ),
          ),


          // App Description
          const Text(
            'Welcome to Thryve!',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          const Text(
            'Thryve helps you relieve stress and promote wellness in your daily life.',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppColors.grey,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  ),
),


      bottomNavigationBar: BottomNavBar(currentIndex: 0),
    );
  }
}
