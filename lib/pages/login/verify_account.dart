import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'change_password.dart'; // Import change_password.dart page

class VerifyAccountPage extends StatefulWidget {
  final String mobileNumber;
  final String otpCode;

  const VerifyAccountPage({
    super.key,
    required this.mobileNumber,
    required this.otpCode,
  });

  @override
  _VerifyAccountPageState createState() => _VerifyAccountPageState();
}

class _VerifyAccountPageState extends State<VerifyAccountPage> {
  final TextEditingController otpController = TextEditingController();
  bool isLoading = false;

  // Function to make the OTP validation API call
  Future<void> validateOTP(String otpCode) async {
    setState(() {
      isLoading = true;
    });

    const url = 'http://192.168.100.50:98/api/Forgot/OtpValidate';
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode({
      "otp_code": otpCode,
      "mobile": widget.mobileNumber,
    });

    try {
      final response = await http.post(Uri.parse(url), headers: headers, body: body);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['response'] != null) {
          // OTP is valid, navigate to ChangePasswordPage
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChangePasswordPage(mobileNumber: widget.mobileNumber),
            ),
          );
        } else {
          // Handle invalid OTP response
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid OTP code. Please try again.')),
          );
        }
      } else {
        // Handle server error
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server error. Please try again later.')),
        );
      }
    } catch (e) {
      // Handle network error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to connect to the server. Please check your internet connection.')),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  // Function to handle OTP submission
  void handleSubmit() {
    final otpCode = otpController.text.trim();

    if (otpCode.isEmpty) {
      // Show error message if OTP is empty
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the OTP code.')),
      );
    } else {
      // Call the validate OTP API
      validateOTP(otpCode);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Account'),
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

              // Verify Account title
              Center(
                child: Text(
                  'Verify Account',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const SizedBox(height: 8.0),

              // Instructional text
              Center(
                child: Text(
                  'Please enter the OTP code sent to your mobile number.',
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
              const SizedBox(height: 16.0),

              // OTP Input
              TextField(
                controller: otpController,
                decoration: InputDecoration(
                  labelText: 'OTP Code *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.security),
                ),
              ),
              const SizedBox(height: 24.0),

              // Submit Button
              ElevatedButton(
                onPressed: isLoading ? null : handleSubmit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isLoading
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
