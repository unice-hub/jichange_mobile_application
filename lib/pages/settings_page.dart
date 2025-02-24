import 'package:flutter/material.dart';
import 'package:learingdart/core/api/endpoint_api.dart';
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
  bool isPersonalInfoLoading = true;
  ThemeMode _selectedTheme = ThemeMode.system;
  Map<String, dynamic>? personalInfo;

  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  String? _newPasswordError;
  String? _confirmPasswordError;

  @override
  void initState() {
    super.initState();
    _loadSessionInfo();
    _fetchPersonalInfo();
    _loadThemePreference();  // Load the saved theme preference on init
  }

  Future<void> _loadSessionInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('token') ?? 'Not logged in';
    });
  }

  Future<void> _fetchPersonalInfo() async {
    const url = ApiEndpoints.editCompanyUsers;
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
        body: jsonEncode({"Sno": userID}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          personalInfo = data['response'];
          isPersonalInfoLoading = false;
        });
      } else {
        _showErrorDialog('Error: Failed to fetch personal information');
      }
    } catch (e) {
   if (e is http.ClientException) {
        // Network error
        _showErrorDialog('Network error. Please check your connection and try again.');

      } else {
        // Other exceptions
        _showErrorDialog('An unexpected error occurred. Please try again.');
        
      }
      setState(() {
        isLoading = false;
      });
      
    }
  }

  Future<void> _logout() async {
    setState(() {
      isLoading = true;
    });
    const url = ApiEndpoints.getLogout;
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
    if (e is http.ClientException) {
        // Network error
        _showErrorDialog('Network error. Please check your connection and try again.');

      } else {
        // Other exceptions
        _showErrorDialog('An unexpected error occurred. Please try again.');
        
      }
      setState(() {
        isLoading = false;
      });
      
    }
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final theme = prefs.getString('theme') ?? 'system';
    setState(() {
      _selectedTheme = _stringToThemeMode(theme);
    });
    widget.onThemeChanged(_selectedTheme);
  }

  Future<void> _saveThemePreference(ThemeMode theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', _themeModeToString(theme));
  }

  ThemeMode _stringToThemeMode(String theme) {
    switch (theme) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  String _themeModeToString(ThemeMode theme) {
    switch (theme) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      default:
        return 'system';
    }
  }


  Future<void> _changePassword() async {
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    setState(() {
      _newPasswordError = newPassword.isEmpty ? "New password is required" : null;
      _confirmPasswordError = confirmPassword.isEmpty ? "Please confirm your password" : null;
    });

    if (_newPasswordError != null || _confirmPasswordError != null) return;

    if (newPassword != confirmPassword) {
      setState(() {
        _confirmPasswordError = "Passwords do not match";
      });
      return;
    }

    setState(() {
      isLoading = true;
    });

    const url =ApiEndpoints.getUpdatePwd;
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
        body: jsonEncode({
          "type": "string",
          "pwd": newPassword,
          "confirmPwd": confirmPassword,
          "userid": userID
        }),
      );

      if (response.statusCode == 200) {

        final Map<String, dynamic> responseBody = jsonDecode(response.body);
       if (response.statusCode == 200 && responseBody['response'] != 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Password changed successfully")),
          );
          _newPasswordController.clear();
          _confirmPasswordController.clear();
          _fetchPersonalInfo();

        } else {
          var errorMessage = (responseBody['message']?.isNotEmpty ?? false)
              ? responseBody['message'][0]
              : 'An error occurred';

          errorMessage = 'Failed to update password';
              
          _showQuickAlert(context, 'Failed', errorMessage, true);
        }
      } else {
        _showErrorDialog('Error: Failed to change password');
      }
    } catch (e) {
    if (e is http.ClientException) {
        // Network error
        _showErrorDialog('Network error. Please check your connection and try again.');

      } else {
        // Other exceptions
        _showErrorDialog('An unexpected error occurred. Please try again.');
        
      }
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
            style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            child: const Text(
              'OK',
              style: TextStyle(color: Colors.white),
              ),
          ),
        ],
      ),
    );
  }

  void _showQuickAlert(BuildContext context, String title, String message, bool isSuccess) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'OK',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

void _showConfirmDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _changePassword(); // Trigger password change
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'CONFIRM',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
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
                    if (value != null) {
                      setState(() {
                        _selectedTheme = value;
                      });
                      widget.onThemeChanged(value);
                      _saveThemePreference(value);  // Save theme preference
                    }
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
                    if (value != null) {
                      setState(() {
                        _selectedTheme = value;
                      });
                      widget.onThemeChanged(value);
                      _saveThemePreference(value);  // Save theme preference
                    }
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
                    if (value != null) {
                      setState(() {
                        _selectedTheme = value;
                      });
                      widget.onThemeChanged(value);
                      _saveThemePreference(value);  // Save theme preference
                    }
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
        backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Theme.of(context).colorScheme.surface // Dark mode
          : Theme.of(context).colorScheme.primary, // Light mode
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
        // backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: SingleChildScrollView( 
       child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isPersonalInfoLoading)
              const Center(child: CircularProgressIndicator())
            else
              Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Personal Information',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text('Full Name: ${personalInfo?['Fullname'] ?? 'N/A'}'),
                      Text('Username: ${personalInfo?['Username'] ?? 'N/A'}'),
                      Text('Email: ${personalInfo?['Email'] ?? 'N/A'}'),
                      Text('Phone: ${personalInfo?['Mobile'] ?? 'N/A'}'),
                      Text('Role: ${personalInfo?['Userpos'] ?? 'N/A'}'),
                    ],
                  ),
                ),
              ),
            Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Change Password',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _newPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'New Password',
                        errorText: _newPasswordError,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        errorText: _confirmPasswordError,
                      ),
                    ),
                    // const SizedBox(height: 16),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      
                      onPressed: () => _showConfirmDialog(
                        context,
                        'Change password',
                        'Are you sure you want to change the password?',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Change Password',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              title: const Text('Change Theme'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showThemeBottomSheet(context),
            ),
            const SizedBox(height: 20),
            ListTile(
              // leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: _logout,
              trailing: const Icon(Icons.logout),
            ),
          ],
        ),
      ),
      )
    );
  }
}
