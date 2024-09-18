import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeSection extends StatefulWidget {
  const HomeSection({super.key});

  @override
  _HomeSectionState createState() => _HomeSectionState();
}

class _HomeSectionState extends State<HomeSection> {
  String _token = 'Not logged in';
  int _userID = 402;
  int _instID = 402;
  String _braid = 'sksc';
  String _userName = 'Unknown';
  

  @override
  void initState() {
    super.initState();
    _loadSessionInfo();
  }

  // Method to load all session data from SharedPreferences
  Future<void> _loadSessionInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('token') ?? 'Not logged in';
      _userID = prefs.getInt('userID') ?? 402;
      _instID = prefs.getInt('instID') ?? 402;
      _userName = prefs.getString('userName') ?? 'Unknown';
      _braid = prefs.getString('ubraid') ?? 'Unknown';
      
    });
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Welcome to the Home Page',
              style: TextStyle(fontSize: 24.0),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20.0),
            Text(
              'Token: $_token',
              style: const TextStyle(fontSize: 16.0, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10.0),
            Text(
              'User ID: $_userID',
              style: const TextStyle(fontSize: 16.0, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10.0),
            Text(
              'userName: $_userName',
              style: const TextStyle(fontSize: 16.0, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10.0),
            Text(
              'instID: $_instID',
              style: const TextStyle(fontSize: 16.0, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10.0),
            Text(
              'braid: $_braid',
              style: const TextStyle(fontSize: 16.0, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
