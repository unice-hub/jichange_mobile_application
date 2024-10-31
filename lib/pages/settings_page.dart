import 'package:flutter/material.dart';
import 'package:learingdart/pages/login/login_page.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class SettingsPage extends StatefulWidget {
  final ValueChanged<ThemeMode> onThemeChanged;

  const SettingsPage({super.key, required this.onThemeChanged});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _token = 'Not logged in';
  bool isLoading = false;
  ThemeMode _selectedTheme = ThemeMode.light;

  @override
  void initState() {
    super.initState();
    _loadSessionInfo();
  }

  Future<void> _loadSessionInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('token') ?? 'Not logged in';
    });
  }

  Future<void> _logout() async {
    setState(() {
      isLoading = true;
    });
    const url = 'http://192.168.100.50:98/api/LoginUser/Logout';
    try {
      final prefs = await SharedPreferences.getInstance();
      int userID = prefs.getInt('userID') ?? 0;

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({"userid": userID}),
      );

      if (response.statusCode == 200) {
        await prefs.clear();
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        }
      } else {
        _showErrorDialog('Error: Failed to logout');
      }
    } catch (e) {
      _showErrorDialog('An unexpected error occurred. Please try again.');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showThemeBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Change Theme',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.phone_android_rounded),
                title: const Text('Light'),
                trailing: Radio<ThemeMode>(
                  value: ThemeMode.light,
                  groupValue: _selectedTheme,
                  onChanged: (ThemeMode? value) {
                    setState(() {
                      _selectedTheme = value!;
                    });
                    widget.onThemeChanged(value!); // Notify parent widget
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.phone_android),
                title: const Text('Dark'),
                trailing: Radio<ThemeMode>(
                  value: ThemeMode.dark,
                  groupValue: _selectedTheme,
                  onChanged: (ThemeMode? value) {
                    setState(() {
                      _selectedTheme = value!;
                    });
                    widget.onThemeChanged(value!); // Notify parent widget
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.brightness_auto),
                title: const Text('System Default'),
                trailing: Radio<ThemeMode>(
                  value: ThemeMode.system,
                  groupValue: _selectedTheme,
                  onChanged: (ThemeMode? value) {
                    setState(() {
                      _selectedTheme = value!;
                    });
                    widget.onThemeChanged(value!); // Notify parent widget
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Personalization',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.color_lens),
              title: const Text('Change Theme'),
              onTap: () => _showThemeBottomSheet(context),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: _logout,
              trailing: isLoading
                  ? const CircularProgressIndicator()
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
