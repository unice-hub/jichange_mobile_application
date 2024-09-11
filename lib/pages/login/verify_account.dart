import 'package:flutter/material.dart';

class VerifyAccountPage extends StatelessWidget {
  final String mobileNumber;
  final String otpCode;

  const VerifyAccountPage({
    Key? key,
    required this.mobileNumber,
    required this.otpCode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Account'),
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

            // Verify Account Title
            Center(
              child: Text(
                'Verify account',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const SizedBox(height: 8.0),

            // Instructional Text
            Center(
              child: Text(
                'A code was sent to your mobile number $mobileNumber, please enter the code below to proceed',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24.0),

            // OTP Input
            TextField(
              decoration: InputDecoration(
                labelText: 'Enter 6 digit code *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                hintText: '0-0-0-0-0-0',
              ),
              keyboardType: TextInputType.number,
              maxLength: 6,
            ),
            const SizedBox(height: 24.0),

            // Resend Code Text
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () {
                  // Handle resend OTP action here
                },
                child: const Text('Resend code'),
              ),
            ),
            const SizedBox(height: 24.0),

            // Submit Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Handle OTP verification here
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  backgroundColor: Theme.of(context).colorScheme.primary, // Blue color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Submit',
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
