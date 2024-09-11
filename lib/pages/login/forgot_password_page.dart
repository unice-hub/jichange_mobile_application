import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'verify_account.dart'; // Import the verify_account page

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _mobileController = TextEditingController();
  bool _isLoading = false;

  // Method to send OTP to the entered mobile number
  Future<void> _sendOTP() async {
    final String mobile = _mobileController.text;
    final url = Uri.parse('http://192.168.100.50:98/api/Forgot/GetMobile');
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    final body = jsonEncode({'mobile': mobile});

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        String otpCode = responseData['response']['code'];
        String mobileNumber = responseData['response']['mobile_no'];

        // Navigate to verify account screen and pass the OTP and mobile number
        // ignore: use_build_context_synchronously
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VerifyAccountPage(
              mobileNumber: mobileNumber,
              otpCode: otpCode,
            ),
          ),
        );
      } else {
        // Show error message for invalid response
        _showErrorDialog('Failed to send OTP. Please try again.');
      }
    } catch (e) {
      // Handle errors
      _showErrorDialog('An error occurred. Please try again.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Show error dialog
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
        title: const Text('Forgot Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo at the top
            Center(
              child: Image.asset(
                'assets/jichange_logo.png', // Add your logo asset here
                height: 80.0,
              ),
            ),
            const SizedBox(height: 24.0),

            // Forgot Password title
            Center(
              child: Text(
                'Forgot Password',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const SizedBox(height: 8.0),

            // Instructional text
            Center(
              child: Text(
                'Enter your mobile number and instructions will be sent to you.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24.0),

            // Mobile Number TextField
            TextField(
              controller: _mobileController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Mobile number',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixText: '+255 ', // Country code prefix
              ),
            ),
            const SizedBox(height: 24.0),

            // Send Reset Password Button
            Center(
              child: ElevatedButton(
                onPressed: _isLoading ? null : _sendOTP,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  backgroundColor: Theme.of(context).colorScheme.primary, // Blue color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Send reset password link',
                        style: TextStyle(color: Colors.white), // White text
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
