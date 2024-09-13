import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeSection extends StatefulWidget {
  const HomeSection({super.key});

  @override
  _HomeSectionState createState() => _HomeSectionState();
}

class _HomeSectionState extends State<HomeSection> {
  String _token = 'Not logged in';

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('token') ?? 'Not logged in';
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      
      body: Center(
        child: Text(
          // 'Home Section\nToken: $_token',
          'This is the Home Page',
          style: TextStyle(fontSize: 24.0),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
