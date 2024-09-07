import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

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
                'assets/jichange_logo.png', 
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
                onPressed: () {
                  // Handle reset password link action here
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  backgroundColor: Theme.of(context).colorScheme.primary, // Blue color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
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
