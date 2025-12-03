// lib/common/widgets/floating_nav_bar.dart
import 'package:flutter/material.dart';

class FloatingNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const FloatingNavBar({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.deepPurple, width: 2.5),
        boxShadow: [
          BoxShadow(color: Colors.deepPurple.withOpacity(0.25), blurRadius: 16, offset: const Offset(0, 8)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            labelTextStyle: MaterialStateProperty.resolveWith((states) {
              return TextStyle(
                color: states.contains(MaterialState.selected) ? Colors.deepPurple : Colors.grey[600],
                fontWeight: states.contains(MaterialState.selected) ? FontWeight.w600 : FontWeight.normal,
              );
            }),
            iconTheme: MaterialStateProperty.resolveWith((states) {
              return IconThemeData(color: states.contains(MaterialState.selected) ? Colors.deepPurple : Colors.grey[600]);
            }),
          ),
          child: NavigationBar(
            selectedIndex: currentIndex,
            onDestinationSelected: onTap,
            height: 70,
            backgroundColor: Colors.transparent,
            elevation: 0,
            indicatorColor: Colors.deepPurple.withOpacity(0.15),
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home_rounded, size: 28), selectedIcon: Icon(Icons.home_rounded, color: Colors.deepPurple, size: 28), label: 'Home'),
              NavigationDestination(icon: Icon(Icons.event_rounded, size: 28), selectedIcon: Icon(Icons.event_rounded, color: Colors.deepPurple, size: 28), label: 'Bookings'),
              NavigationDestination(icon: Icon(Icons.favorite_border_rounded, size: 28), selectedIcon: Icon(Icons.favorite_rounded, color: Colors.deepPurple, size: 28), label: 'Favourites'),
              NavigationDestination(icon: Icon(Icons.person_rounded, size: 28), selectedIcon: Icon(Icons.person_rounded, color: Colors.deepPurple, size: 28), label: 'Profile'),
            ],
          ),
        ),
      ),
    );
  }
}