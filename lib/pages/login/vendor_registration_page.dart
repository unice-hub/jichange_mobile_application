import 'package:flutter/material.dart';

class VendorRegistrationPage extends StatefulWidget {
  const VendorRegistrationPage({super.key});

  @override
  _VendorRegistrationPageState createState() => _VendorRegistrationPageState();
}

class _VendorRegistrationPageState extends State<VendorRegistrationPage> {
  bool? _checkerForInvoiceApproval = false; // Group value for Radio buttons

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
              // const Text(
              //   'Vendor Registration',
              //   style: TextStyle(
              //     fontSize: 24.0,
              //     fontWeight: FontWeight.bold,
              //   ),
              // ),
              const SizedBox(height: 16.0),

              // Vendor Name
              TextField(
                decoration: InputDecoration(
                  labelText: 'Vendor name',
                  border: OutlineInputBorder(),
                  hintText: 'Enter vendor name',
                  suffixText: '*',
                ),
              ),
              const SizedBox(height: 16.0),

              // Mobile Number (non-editable)
              Row(
                children: const [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      enabled: false, // Non-editable
                      decoration: InputDecoration(
                        // labelText: 'Mobile Number',
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
                      enabled: true, // Non-editable
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
              TextField(
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  border: OutlineInputBorder(),
                  hintText: 'Enter email address',
                  suffixText: '*',
                ),
              ),
              const SizedBox(height: 16.0),

              // Branch Dropdown
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Branch',
                  border: OutlineInputBorder(),
                ),
                items: <String>['Branch 1', 'Branch 2', 'Branch 3']
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (_) {},
              ),
              const SizedBox(height: 16.0),

              // Account Number
              TextField(
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
