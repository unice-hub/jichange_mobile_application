import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  void _logout(BuildContext context) {
    // Add your logout logic here, e.g., clearing user session and navigating to the login page
    // For now, we'll just show a snack bar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Logged out')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('This is the Profile Page'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _logout(context),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        tooltip: 'Logout',
        child: const Icon(Icons.logout),
      ),
    );
  }
}
