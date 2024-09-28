
import 'dart:convert'; // For encoding and decoding JSON
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // For making HTTP requests
import 'package:shared_preferences/shared_preferences.dart'; // For session management
import 'forgot_password_page.dart';
import 'vendor_registration_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _controlNumberController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false; // For showing a loading indicator during login

  // Method to handle login API call and save session
  Future<void> loginUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse('http://192.168.100.50:98/api/LoginUser/AddLogins');
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    };
    final body = jsonEncode({
      'userName': _userNameController.text,
      'password': _passwordController.text
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        
        // Check if login was unsuccessful due to incorrect username or password
        if (responseData['response']?['check'] == "Username or password is incorrect") {
          _showErrorDialog('Username or password is incorrect.');
          return;
        }
         // Extract session data
        String token = responseData['response']['Token'];
        String userType = responseData['response']['userType'];
        String userName = responseData['response']['Uname'];
        int instID = responseData['response']['InstID'];
        int userID = responseData['response']['userid'];
        int braid = responseData['response']['braid'];
        String role = responseData['response']['role'];
        String designation = responseData['response']['desig'];
        
        // // print('Login successful, Token: $token');
        // print('Login successful, InstID: $instID');
        // print('Login successful, InstID: $userType');
        // print('Login successful, InstID: $braid');
        // print('Login successful, InstID: $userName');

       
        // Store the session data in SharedPreferences for session management
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('userType', userType);
        await prefs.setString('userName', userName);
        await prefs.setInt('instID', instID);
        await prefs.setInt('userID', userID);
        await prefs.setInt('braid', braid);
        await prefs.setString('role', role);
        await prefs.setString('designation', designation);
        

        // Navigate to Home Page
        if (!mounted) return;
        Navigator.pushNamed(context, '/home');
      } else if (response.statusCode == 401) {
        // Handle unauthorized (wrong username/password)
        _showErrorDialog('Incorrect username or password. Please try again.');

      }else if (response.statusCode >= 500){
        // Handle server errors
        _showErrorDialog('Server error. Please try again later.');

      } else {
       // Handle other errors
        _showErrorDialog('Login failed. Please check your credentials and try again.');
      }

    } catch (e) {
      if (e is http.ClientException) {
        // Network error
        _showErrorDialog('Network error. Please check your connection and try again.');

      } else {
        // Other exceptions
        _showErrorDialog('An unexpected error occurred. Please try again.');
        
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  

  // Method to handle Control Number Details API call
  Future<void> _fetchControlNumberDetails(String controlNumber) async {
  final url = Uri.parse('http://192.168.100.50:98/api/Invoice/GetControl');
  final headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json'
  };
  final body = jsonEncode({'control': controlNumber});

  try {
    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      
      // Check if the control number is incorrect based on the response
      if (responseData['response'] == 0) {
        // If control number is wrong, show an error dialog
        _showErrorDialog('Failed to get control number details. Please check your control number and try again.');
        return;
      }

      // If control number is correct, handle and display the details
      final details = responseData['response'];
      _showControlNumberDetailsDialog(details);

    } else if (response.statusCode == 401) {
      // Handle unauthorized (wrong control number)
      _showErrorDialog('Incorrect Control Number. Please try again.');
      
    } else if (response.statusCode >= 500) {
      // Handle server errors
      _showErrorDialog('Server error. Please try again later.');

    } else {
      // Handle other errors
      _showErrorDialog('Failed to get control number details. Please check your control number and try again.');
    }
  } catch (e) {
    if (e is http.ClientException) {
        // Network error
        _showErrorDialog('Network error. Please check your connection and try again.');

      } else {
        // Other exceptions
        _showErrorDialog('An unexpected error occurred. Please try again.');
        
      }
  }
}

  // Show Control Number Details as a BottomSheet
  void _showControlNumberDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
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
                      controller: _controlNumberController,
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

                    // Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            // Fetch control number details
                            final controlNumber = _controlNumberController.text;
                            if (controlNumber.isNotEmpty) {
                              _fetchControlNumberDetails(controlNumber);
                            } else {
                              _showErrorDialog('Please enter a control number.');
                            }
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

  // Show details in a dialog
  void _showControlNumberDetailsDialog(Map<String, dynamic> details) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Control Number Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Control Number: ${details['Control_No']}'),
            Text('Customer Name: ${details['Cust_Name']}'),
            Text('Payment Type: ${details['Payment_Type']}'),
            Text('Item Total Amount: ${details['Item_Total_Amount']}'),
            Text('Balance: ${details['Balance']}'),
            Text('Currency Code: ${details['Currency_Code']}'),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
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
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Logo
                Center(
                  child: Image.asset(
                    'assets/jichange_logo.png',
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

                // "Enter your email & password" text
                Center(
                  child: Text(
                    'Enter your email & password to login',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                ),
                const SizedBox(height: 24.0),

                // Username TextField with validation
                TextFormField(
                  controller: _userNameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your username';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),

                // Password TextField with validation
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),

                // "Forgot password?" text
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const ForgotPasswordPage()),
                      );
                    },
                    child: const Text('Forgot password?'),
                  ),
                ),
                const SizedBox(height: 24.0),

                // Sign In Button
                ElevatedButton(
                  onPressed: _isLoading ? null : loginUser,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    backgroundColor:
                        Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text(
                          'SIGN IN',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
                const SizedBox(height: 16.0),

                // Control No Details and Register Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    OutlinedButton(
                      onPressed: () => _showControlNumberDetails(context),
                  // child: const Text('Control No Details'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16.0, horizontal: 24.0),
                        side: const BorderSide(color: Colors.blue),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('CONTROL NO DETAILS'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const VendorRegistrationPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16.0, horizontal: 24.0),
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
      ),
    );
  }
}


