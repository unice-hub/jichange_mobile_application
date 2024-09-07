import 'package:flutter/material.dart';
import 'forgot_password_page.dart'; 
import 'vendor_registration_page.dart'; 

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  // Method to show Control Number Details as a BottomSheet
  void _showControlNumberDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows the bottom sheet to resize with the keyboard
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: EdgeInsets.only(
                  left: 16.0,
                  right: 16.0,
                  top: 16.0,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16.0, // Adds padding for keyboard
                ),
                child: Wrap(
                  children: [
                    Center(
                      child: Text(
                        'Control Number Details',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    const SizedBox(height: 16.0),

                    // Control Number TextField
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Control number',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        hintText: 'Enter control number',
                        suffixText: '*',
                      ),
                    ),
                    const SizedBox(height: 24.0),

                    // Buttons: Close and Submit
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            // Handle form submission
                          },
                          child: const Text('SUBMIT'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Logo
              Center(
                child: Image.asset(
                  'assets/jichange_logo.png', // Make sure this asset exists
                  height: 100.0,
                ),
              ),
              const SizedBox(height: 24.0),

              // "Sign in to your account" text
              Center(
                child: Text(
                  'Sign in to your account',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const SizedBox(height: 8.0),

              // "Enter your email & password to login" text
              Center(
                child: Text(
                  'Enter your email & password to login',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
                      ),
                ),
              ),
              const SizedBox(height: 24.0),

              // Username TextField
              TextField(
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),

              // Password TextField
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),

              // "Forgot password?" text
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // Navigate to Forgot Password Page
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ForgotPasswordPage()),
                    );
                  },
                  child: const Text('Forgot password?'),
                ),
              ),
              const SizedBox(height: 24.0),

              // Sign In Button
              ElevatedButton(
                onPressed: () {
                  // Navigate to Home Page
                  Navigator.pushNamed(context, '/home');
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  backgroundColor: Theme.of(context).colorScheme.primary, // Blue color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  )
                ),
                child: const Text(
                  'SIGN IN',
                  style: TextStyle(color: Colors.white), // White text
                ),
              ),
              const SizedBox(height: 16.0),

              // Control No Details and Register Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  OutlinedButton(
                    onPressed: () {
                      // Show Control Number Details as Bottom Sheet (Backdrop)
                      _showControlNumberDetails(context);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
                      side: const BorderSide(color: Colors.blue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('CONTROL NO DETAILS'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to Vendor Registration Page
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const VendorRegistrationPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue,
                      side: const BorderSide(color: Colors.blue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('REGISTER'),
                  ),
                ],
              ),
              const SizedBox(height: 24.0),

              // Footer Text
              Center(
                child: Text(
                  'Designed & Developed by Biz-Logic Solutions Ltd.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
