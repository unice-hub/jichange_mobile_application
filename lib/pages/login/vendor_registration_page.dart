// ignore_for_file: unused_field

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:learingdart/core/api/endpoint_api.dart';
import 'package:learingdart/pages/login/login_page.dart';

class VendorRegistrationPage extends StatefulWidget {
  const VendorRegistrationPage({super.key});

  @override
  _VendorRegistrationPageState createState() => _VendorRegistrationPageState();
}

class _VendorRegistrationPageState extends State<VendorRegistrationPage> {
  bool? _checkerForInvoiceApproval = false;
  String? _selectedBranchName;
  int? _selectedBranchSno;  // Store Sno of the selected branch
  List<Map<String, dynamic>> _branches = [];  // List to store both branch Name and Sno
  bool _isLoading = true;
  TextEditingController accountNumberController = TextEditingController();
  String? accountNumberErrorMessage;
  TextEditingController vendorNameController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchBranches();

    // Add a listener to the account number field to validate the input
    accountNumberController.addListener(() {
      String accountNumber = accountNumberController.text;
      validateAccountNumber(accountNumber);
    });
  }

  void validateAccountNumber(String accountNumber) {
    if (accountNumber.isEmpty) {
      setState(() {
        accountNumberErrorMessage = null;
      });
    } else if (!RegExp(r'^(015|012|01J)').hasMatch(accountNumber) || accountNumber.length != 13) {
      setState(() {
        accountNumberErrorMessage = 'Account number must start with 015, 012, or 01J and be 13 characters long.';
      });
    } else {
      _isExistInvoice(accountNumber);
    }
  }

  Future<void> _fetchBranches() async {
    final url = Uri.parse(ApiEndpoints.vendorReg);

    try {
      final response = await http.post(url, headers: {'Accept': 'application/json'});

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final List<dynamic> branchList = jsonResponse['response'];

        setState(() {
          _branches = branchList
              .map((branch) => {
                    'Name': branch['Name'],
                    'Sno': branch['Sno'],
                  })
              .toList();
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load branches');
      }
    } catch (e) {
      _showErrorDialog('Network error. Please check your connection and try again.');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _isExistInvoice(String accountNumber) async {
    final url = Uri.parse(ApiEndpoints.accountNumber);//endpoint for checking account number

    try {
      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'acc': accountNumber}),
      );

      if (response.statusCode == 200) {
        final exists = json.decode(response.body);
        if (exists['response'] == true) {
          setState(() {
            accountNumberErrorMessage = 'Account number already exists';
          });
        } else {
          setState(() {
            accountNumberErrorMessage = null;
          });
        }
      } else {
        throw Exception('Failed to check account number');
      }
    } catch (e) {
      _showErrorDialog('An unexpected error occurred. Please try again.');
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

  Future<void> _submitForm() async {
    if (vendorNameController.text.isEmpty ||
        mobileController.text.isEmpty ||
        emailController.text.isEmpty ||
        _selectedBranchSno == null ||
        accountNumberController.text.isEmpty ||
        _checkerForInvoiceApproval == null) {
      _showErrorDialog("Please fill in all fields.");
      return;
    }

    // Show the confirmation dialog
    bool confirmSubmit = await _showConfirmDialog();

    if (confirmSubmit) {
      // If confirmed, submit data to the API
      await _submitData();
    }
  }

  Future<bool> _showConfirmDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm'),
        content: const Text('Save changes?'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context, false); // Close the dialog without confirming
            },
            child: const Text('CLOSE'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, true); // Confirm submission
            },
            child: const Text('CONFIRM'),
          ),
        ],
      ),
    ) ?? false;
  }

  Future<void> _submitData() async {
    final url = Uri.parse(ApiEndpoints.submitData);//endpoint for submitting data
    final requestBody = {
      "compsno": "0",
      "compname": vendorNameController.text,
      "userid": "0",
      "mob": mobileController.text,
      "branch": _selectedBranchSno,  // Send the branch Sno here
      "check_status": _checkerForInvoiceApproval == true ? "Yes" : "No",
      "fax": "", // Assuming this is empty, change as needed
      "pbox": "", // Assuming this is empty, change as needed
      "addr": "", // Assuming this is empty, change as needed
      "rsno": "0",
      "dsno": "0",
      "wsno": "0",
      "tin": "", // Assuming this is empty, change as needed
      "vat": "", // Assuming this is empty, change as needed
      "dname": "", // Assuming this is empty, change as needed
      "email": emailController.text,
      "telno": "", // Assuming this is empty, change as needed
      "dummy": true,
      "accno": accountNumberController.text,
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final List<String> messages = List<String>.from(jsonResponse['message']);

        // Check if there are any error messages
        if (messages.isEmpty) {
          // No error messages, show success
          _showSuccessDialog();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        } else {
          // Display the error messages
          String errorMessage = messages.join('\n');
          _showErrorDialog(errorMessage);
        }
      } else {
        throw Exception('Failed to submit data');
      }
    } catch (e) {
      _showErrorDialog('Error submitting data. Please try again.');
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Success'),
        content: const Text('Data saved successfully!'),
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
        title: const Text('Vendor Registration'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16.0),
              // Vendor Name
              TextField(
                controller: vendorNameController,
                decoration: const InputDecoration(
                  labelText: 'Vendor name',
                  border: OutlineInputBorder(),
                  hintText: 'Enter vendor name',
                ),
              ),
              const SizedBox(height: 8.0),
              // Vendor name validation
              if (vendorNameController.text.isEmpty)
                Text(
                  'Please enter vendor name.',
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              const SizedBox(height: 16.0),

              // Mobile Number
              TextField(
                controller: mobileController,
                decoration: const InputDecoration(
                  labelText: 'Mobile Number',
                  border: OutlineInputBorder(),
                  hintText: 'Enter mobile number',
                ),
              ),
              const SizedBox(height: 8.0),
              // Mobile number validation
              if (mobileController.text.isEmpty)
                Text(
                  'Please enter mobile number.',
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              const SizedBox(height: 16.0),

              // Email Address
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  border: OutlineInputBorder(),
                  hintText: 'Enter email address',
                ),
              ),
              const SizedBox(height: 16.0),

              // Branch Dropdown
              DropdownButtonFormField<String>(
                value: _selectedBranchName,
                hint: const Text('Select Branch'),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedBranchName = newValue;
                    _selectedBranchSno = _branches.firstWhere((branch) => branch['Name'] == newValue)['Sno'];
                  });
                },
                items: _branches.map<DropdownMenuItem<String>>((branch) {
                  return DropdownMenuItem<String>(
                    value: branch['Name'],
                    child: Text(branch['Name']),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16.0),

              // Account Number
              TextField(
                controller: accountNumberController,
                decoration: InputDecoration(
                  labelText: 'Account Number',
                  border: OutlineInputBorder(),
                  hintText: 'Enter account number',
                  errorText: accountNumberErrorMessage,
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16.0),

              // Checkbox for Invoice Approval
              Row(
                children: [
                  Checkbox(
                    value: _checkerForInvoiceApproval,
                    onChanged: (value) {
                      setState(() {
                        _checkerForInvoiceApproval = value;
                      });
                    },
                  ),
                  const Text('Invoice Approval'),
                ],
              ),
              const SizedBox(height: 16.0),

              // Submit Button
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
