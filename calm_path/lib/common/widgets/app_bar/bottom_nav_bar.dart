import 'package:flutter/material.dart';
import 'package:calm_path/presentation/intro/pages/home.dart';
import 'package:calm_path/presentation/gratitude/gratList.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.book),
          label: "Gratitude",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.headphones),
          label: "Listen",
        ),
      ],
      currentIndex: currentIndex,
      selectedItemColor: Colors.blueAccent,
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        if (index == currentIndex) return; // Avoid navigation if already selected

        switch (index) {
          case 0:
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const HomeScreen(),
              ),
            );
            break;
          case 1:
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GratitudeListScreen(),
              ),
            );
            break;
          case 2:
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Listening feature coming soon!')),
            );
            break;
        }
      },
      backgroundColor: Colors.black.withOpacity(0.1),
    );
  }
}
