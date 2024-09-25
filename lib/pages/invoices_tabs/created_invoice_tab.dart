
import 'package:flutter/material.dart';
import '../invoices_section.dart'; // Import Invoice class
import 'dart:convert';
import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class CreatedInvoiceTab extends StatefulWidget {
  final List<Invoice> createdInvoices;
  final Function(String) filterCreatedInvoices;

  const CreatedInvoiceTab({
    required this.createdInvoices,
    required this.filterCreatedInvoices,
    super.key,
  });

  @override
  _CreatedInvoiceTabState createState() => _CreatedInvoiceTabState();
}

class _CreatedInvoiceTabState extends State<CreatedInvoiceTab> {
  String searchQuery = "";
  String _token = 'Not logged in';
  bool isLoading = true;
  List<InvoiceData> createdInvoices = [];

  @override
  void initState() {
    super.initState();
    _loadSessionInfo();
  }

  Future<void> _loadSessionInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('token') ?? 'Not logged in';
    });
    _fetchInvoicesData();
  }

  // Method to fetch Invoice data from the API
  Future<void> _fetchInvoicesData() async {
    const url = 'http://192.168.100.50:98/api/Invoice/GetchDetails';
    try {
      final prefs = await SharedPreferences.getInstance();
      int instituteID = prefs.getInt('instID') ?? 0;

      log('Making API request with token: $_token and instituteID: $instituteID');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({"compid": instituteID}),
      );

      log('API Status Code: ${response.statusCode}');
      log('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        if (responseBody['response'] is List) {
          setState(() {
            createdInvoices = (responseBody['response'] as List)
                .map((item) => InvoiceData.fromJson(item))
                .toList();
            isLoading = false;
          });
        } else {
          _showSnackBar('Unexpected data format: response is not a list');
        }
      } else {
        _showSnackBar('Error: Failed to fetch invoices');
      }
    } catch (e) {
      _showSnackBar('Error: $e');
    }
  }

  void _showSnackBar(String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              labelText: 'Search by name or invoice',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
            onChanged: (query) => widget.filterCreatedInvoices(query),
          ),
        ),
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: createdInvoices.length,
                  itemBuilder: (context, index) {
                    final invoice = createdInvoices[index];
                    return _InvoiceCard(
                      customerName: invoice.customerName,
                      invoiceNumber: invoice.invoiceNumber,
                      invoiceDate: invoice.invoiceDate,
                      approve: invoice.approve,
                      paymentType: invoice.paymentType,
                      status: invoice.status,
                      total: invoice.total,
                      dueDate: invoice.dueDate,
                      expiryDate: invoice.expiryDate,
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class InvoiceData {
  final String customerName;
  final String invoiceNumber;
  final String invoiceDate;
  final String approve;
  final String paymentType;
  final String status;
  final int total;
  final String dueDate;
  final String expiryDate;

  InvoiceData(this.customerName, this.invoiceNumber, this.invoiceDate, this.approve, this.paymentType, this.status, this.total, this.dueDate, this.expiryDate);

  // Assuming fromJson method to parse data from API
  factory InvoiceData.fromJson(Map<String, dynamic> json) {
    return InvoiceData(
      json['Chus_Name'],
      json['Invoice_No'],
      json['Invoice_Date'],
      json['AuditBy'] ?? "NO ",
      json['Payment_Type'],
      json['Status'],
      json['Total'],
      json['Due_Date'],
      json['Invoice_Expired_Date'],
    );
  }
}

class _InvoiceCard extends StatefulWidget {
  final String customerName;
  final String invoiceNumber;
  final String invoiceDate;
  final String approve;
  final String paymentType;
  final String status;
  final int total;
  final String dueDate;
  final String expiryDate;

  const _InvoiceCard({
    super.key,
    required this.customerName,
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.approve,
    required this.paymentType,
    required this.status,
    required this.total,
    required this.dueDate,
    required this.expiryDate,
  });

  @override
  _InvoiceCardState createState() => _InvoiceCardState();
}

class _InvoiceCardState extends State<_InvoiceCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Customer namee:'), // Left-aligned
                  Text(widget.customerName), // Right-aligned
                ],
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Invoice N°:'), // Left-aligned
                  Text(widget.invoiceNumber), // Right-aligned
                ],
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Invoice Date:'), // Left-aligned
                  Text(widget.invoiceDate), // Right-aligned
                ],
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Approve:'), // Left-aligned
                  widget.approve == 'Access'
                      ? ElevatedButton(
                          onPressed: () {
                            // Define the action to perform when the button is pressed
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue, // Set the button color to blue
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8), // Optional: Add rounded corners
                            ),
                          ),
                          child: Text(
                            widget.approve,
                            style: const TextStyle(
                              // fontWeight: FontWeight.bold, // Set text weight to bold
                              color: Colors.white, // Set text color to white
                            ),
                          ),
                        )
                      : Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: widget.approve == 'No Access' ? Colors.yellow : Colors.blue,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            widget.approve,
                            style: TextStyle(
                              // fontWeight: FontWeight.bold, // Set text weight to bold
                              color: widget.approve == 'No Access' ? Colors.black : const Color.fromARGB(255, 223, 250, 224),
                            ),
                          ),
                        ),
                ],
              ),

              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Payment type:'), // Left-aligned
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: widget.paymentType == 'Fixed' ? Colors.purpleAccent : Colors.greenAccent, // Purple for "Fixed", green for "Flexible"
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      widget.paymentType, // Right-aligned
                      style: TextStyle(
                        color: widget.paymentType == 'Fixed' ? Colors.white : Colors.black, // White text for "Fixed", black for "Flexible"
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Status:'), // Left-aligned
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: widget.status == 'Active' ? Colors.blueAccent : Colors.redAccent, // Blue for "Active", red for "No Active"
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      widget.status, // Right-aligned
                      style: TextStyle(
                        color: widget.status == 'Active' ? Colors.white : Colors.white, // White for both "Active" and "No Active"
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total:'), // Left-aligned
                  Text(widget.total.toString()), // Right-aligned
                ],
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Due Date:'), // Left-aligned
                  Text(widget.dueDate), // Right-aligned
                ],
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Expiry Date:'), // Left-aligned
                  Text(widget.expiryDate), // Right-aligned
                ],
              ),
              const SizedBox(height: 5),
              if (_isExpanded) ...[
                const SizedBox(height: 10),
                const Divider(),
                Row(
                  children: [
                    const Text('Actions'),
                    IconButton(
                      icon: const Icon(Icons.visibility),
                      onPressed: () {
                        // Action for viewing control number details
                      },
                    ),
                    // Add other action icons
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        // Action for editing
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.cancel),
                      onPressed: () {
                        // Action for cancelling
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.download),
                      onPressed: () {
                        // Action for downloading
                      },
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}





