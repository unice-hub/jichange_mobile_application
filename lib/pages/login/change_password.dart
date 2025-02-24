import 'dart:convert'; // For encoding and decoding JSON
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // For making HTTP requests
import 'package:learingdart/core/api/endpoint_api.dart';
import 'login_page.dart'; // Import login page

class ChangePasswordPage extends StatefulWidget {
  final String mobileNumber;

  const ChangePasswordPage({super.key, required this.mobileNumber});

  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  // Method to handle the API request for changing the password
  Future<void> _changePassword() async {
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // Validate that passwords match
    if (password.isEmpty || confirmPassword.isEmpty) {
      _showErrorDialog('Please enter both password fields.');
      return;
    } else if (password != confirmPassword) {
      _showErrorDialog('Passwords do not match.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse(ApiEndpoints.changePwd);//endpoint for the change password
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    final body = jsonEncode({
      'password': password,
      'mobile': widget.mobileNumber,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        _showSuccessDialog();
      } else {
        _showErrorDialog('Failed to change the password. Please try again.');
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
        _isLoading = false;
      });
      
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Show success dialog and navigate to login
  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Success'),
        content: const Text('Your password has been changed successfully.'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (Route<dynamic> route) => false, // Remove all previous routes
              );
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Show error dialog in case of failure
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password'),
      ),
      body: SingleChildScrollView( // Wrap content in SingleChildScrollView to prevent overflow
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo at the top
              Center(
                child: Image.asset(
                  'assets/jichange_logo.png', // Add your logo asset here
                  height: 80.0,
                ),
              ),
              const SizedBox(height: 24.0),

              // Change Password title
              Center(
                child: Text(
                  'Change password',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const SizedBox(height: 8.0),

              // Instructional text
              Center(
                child: Text(
                  'Complete the form below to continue',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24.0),

              // Mobile Number Input (prefilled and non-editable)
              TextField(
                controller: TextEditingController(text: widget.mobileNumber),
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Mobile number *',
                  prefixText: '+',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24.0),

              // Password Input
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 16.0),

              // Confirm Password Input
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirm password *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 24.0),

              // Submit Button
              ElevatedButton(
                onPressed: _isLoading ? null : _changePassword,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Submit',
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
