import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class VendorRegistrationPage extends StatefulWidget {
  const VendorRegistrationPage({super.key});

  @override
  _VendorRegistrationPageState createState() => _VendorRegistrationPageState();
}

class _VendorRegistrationPageState extends State<VendorRegistrationPage> {
  bool? _checkerForInvoiceApproval = false; // Group value for Radio buttons
  String? _selectedBranch;
  List<String> _branchNames = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBranches();
  }

  Future<void> _fetchBranches() async {
    final url = Uri.parse('http://192.168.100.50:98/api/Branch/GetBranchLists');

    try {
      final response = await http.post(url, headers: {'Accept': 'application/json'});

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final List<dynamic> branchList = jsonResponse['response'];

        setState(() {
          _branchNames = branchList.map((branch) => branch['Name'] as String).toList();
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load branches');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle error (show a message to the user, etc.)
      print('Error fetching branches: $e');
    }
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
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Vendor name',
                  border: OutlineInputBorder(),
                  hintText: 'Enter vendor name',
                  suffixText: '*',
                ),
              ),
              const SizedBox(height: 16.0),

              // Mobile Number (non-editable)
              const Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      enabled: false, // Non-editable
                      decoration: InputDecoration(
                        hintText: '+255',
                        border: OutlineInputBorder(),
                        prefix: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text('+255'), // Country code
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.0),
                  Expanded(
                    flex: 3,
                    child: TextField(
                      enabled: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: '(0) 111-000-333',
                        suffixText: '*',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),

              // Email Address
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  border: OutlineInputBorder(),
                  hintText: 'Enter email address',
                  suffixText: '*',
                ),
              ),
              const SizedBox(height: 16.0),

              // Branch Dropdown
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Branch',
                        border: OutlineInputBorder(),
                      ),
                      items: _branchNames.map((String branch) {
                        return DropdownMenuItem<String>(
                          value: branch,
                          child: Text(branch),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedBranch = newValue;
                        });
                      },
                      value: _selectedBranch,
                    ),
              const SizedBox(height: 16.0),

              // Account Number
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Account Number',
                  border: OutlineInputBorder(),
                  hintText: 'Enter account number',
                  suffixText: '*',
                ),
              ),
              const SizedBox(height: 16.0),

              // Checker for Invoice Approval
              const Text(
                'Checker for invoice approval? *',
                style: TextStyle(fontSize: 16.0),
              ),
              Row(
                children: [
                  Radio<bool>(
                    value: true,
                    groupValue: _checkerForInvoiceApproval,
                    onChanged: (value) {
                      setState(() {
                        _checkerForInvoiceApproval = value;
                      });
                    },
                  ),
                  const Text('Yes'),
                  Radio<bool>(
                    value: false,
                    groupValue: _checkerForInvoiceApproval,
                    onChanged: (value) {
                      setState(() {
                        _checkerForInvoiceApproval = value;
                      });
                    },
                  ),
                  const Text('No'),
                ],
              ),
              const SizedBox(height: 24.0),

              // Submit Button
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Handle the form submission here
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16.0, horizontal: 24.0),
                    backgroundColor:
                        Theme.of(context).colorScheme.primary, // Blue color
                  ),
                  child: const Text(
                    'SUBMIT',
                    style: TextStyle(color: Colors.white), // White text
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
