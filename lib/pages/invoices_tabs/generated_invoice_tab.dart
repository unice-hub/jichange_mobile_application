import 'dart:io';

import 'package:flutter/material.dart';
import 'package:learingdart/core/api/invoice_apis.dart';
import 'package:learingdart/pages/amend_invoice.dart';
// import 'package:learingdart/pages/invoices_tabs/created_invoice_tab.dart';
import '../invoices_section.dart'; // Import Invoice class
import 'dart:convert';
import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;


class GeneratedInvoiceTab extends StatefulWidget {
  final List<Invoice> generatedInvoices;
  final List<Invoice> filterGeneratedInvoices;

  const GeneratedInvoiceTab({
    required this.generatedInvoices,
    required this.filterGeneratedInvoices,
    super.key,
  });

  @override
  _GeneratedInvoiceTabState createState() => _GeneratedInvoiceTabState();
}

class _GeneratedInvoiceTabState extends State<GeneratedInvoiceTab> {
  String searchQuery = "";
  String _token = 'Not logged in';
  bool isLoading = true;
  List<InvoiceData> generatedInvoices = [];

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

  Future<void> _fetchInvoicesData() async {
    const url = 'http://192.168.100.50:98/api/Invoice/GetSignedDetails';
    
    try {
      final prefs = await SharedPreferences.getInstance();
      int instituteID = prefs.getInt('instID') ?? 0;
      int userID = prefs.getInt('userID') ?? 0;
      log(userID.toString());

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({"compid": instituteID}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        if (responseBody['response'] is List) {
          setState(() {
            generatedInvoices = (responseBody['response'] as List)
                .map((item) => InvoiceData.fromJson(item, userID))
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
      // _showSnackBar('Error: $e');
      if (e is http.ClientException) {
          // Network error
          _showErrorDialog('Network error. Please check your connection and try again.');

        } else {
          // Other exceptions
          _showErrorDialog('An unexpected error occurred. Please try again.');
          
        }
      setState(() {
        isLoading = false;
      });
    }
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

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {

    // Filter the invoices based on the search query
    final filteredCreatedInvoices = generatedInvoices.where((invoice) {
      return invoice.customerName.toLowerCase().contains(searchQuery.toLowerCase()) ||
             invoice.invoiceNumber.toLowerCase().contains(searchQuery.toLowerCase()) ||
             invoice.approve.toLowerCase().contains(searchQuery.toLowerCase()) ||
             invoice.paymentType.toLowerCase().contains(searchQuery.toLowerCase()) ||
             invoice.status.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();


    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              children: [
                _buildSearchField(),
                const SizedBox(height: 8.0),
                _buildInvoiceList(filteredCreatedInvoices),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      onChanged: (value) {
        setState(() {
          searchQuery = value;
        });
      },
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search),
        labelText: 'Search',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
    );
  }

  Widget _buildInvoiceList(List<InvoiceData> invoices) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (invoices.isEmpty) {
      return const Center(child: Text("No invoices found"));
    }
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.66,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: invoices.length,
        itemBuilder: (context, index) {
          final invoice = invoices[index];
          return _InvoiceCard(invoice: invoice);
        },
      ),
    );
  }
  
}

class InvoiceData {
  final String customerName;
  final String invoiceNumber;
  final String controlNo;
  final String invoiceDate;
  final String approve;
  final String paymentType;
  final String deliveryStatus;
  final String status;
  final double total;
  final String currencyCode;
  final String dueDate;
  final String expiryDate;
  final int invMasSno;
  final int compid;
  final String companyName;
  final String controlNumber;
   final int invMasNo;

  InvoiceData(
    this.customerName,
    this.invoiceNumber,
    this.controlNo,
    this.invoiceDate,
    this.approve,
    this.paymentType,
    this.deliveryStatus,
    this.status,
    this.total,
    this.currencyCode,
    this.dueDate,
    this.expiryDate,
    this.invMasSno,
    this.compid,
    this.companyName,
    this.controlNumber,
    this.invMasNo,
  );

  factory InvoiceData.fromJson(Map<String, dynamic> json, int userID) {
    return InvoiceData(
      json['Chus_Name'],
      json['Invoice_No'],
      json['Control_No'],
      json['Invoice_Date'],
      (json['AuditBy'] == userID.toString()) ? "No Access" : "Access",
      json['Payment_Type'],
      json['delivery_status'] ?? "Unsent",
      json['Status'],
      json['Total'],
      json['Currency_Code'],
      json['Due_Date'],
      json['Invoice_Expired_Date'],
      json['Inv_Mas_Sno'],
      json['Com_Mas_Sno'],
      json['Company_Name'],
      json['Control_No'],
      json['Chus_Mas_No'] ?? '',
      
    );
  }
}

String formatDate(String dateStr) {
  DateTime dateTime = DateTime.parse(dateStr);
  return DateFormat('EEE MMM dd yyyy').format(dateTime);
}

class _InvoiceCard extends StatefulWidget {
  final InvoiceData invoice;

  const _InvoiceCard({super.key, required this.invoice});

  @override
  _InvoiceCardState createState() => _InvoiceCardState();
}

class _InvoiceCardState extends State<_InvoiceCard> {
  bool _isExpanded = false;

  final TextEditingController _reasonController = TextEditingController();

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
              _buildInvoiceRow('Invoice Date:', formatDate(widget.invoice.invoiceDate)),
              const SizedBox(height: 5),
              _buildInvoiceRow('Customer name:', widget.invoice.customerName),
              const SizedBox(height: 5),
              _buildInvoiceRow('Invoice N°:', widget.invoice.invoiceNumber ),
              const SizedBox(height: 5),
              _buildInvoiceRow('Control N°:', widget.invoice.controlNo),
              const SizedBox(height: 5),
              // _buildApprovalRow(),
              const SizedBox(height: 5),
              _buildInvoiceRow('Payment type:', _buildPaymentTypeContainer()),
              const SizedBox(height: 5),
              _buildInvoiceRow('Delivery Status:', widget.invoice.deliveryStatus),
              const SizedBox(height: 5),
              _buildInvoiceRow('Status:', _buildStatusContainer()),
              const SizedBox(height: 5),
              _buildInvoiceRow('Total:', "${widget.invoice.total}  ${widget.invoice.currencyCode}"),
              const SizedBox(height: 5),
              _buildInvoiceRow('Due Date:', formatDate(widget.invoice.dueDate)),
              const SizedBox(height: 5),
              _buildInvoiceRow('Expiry Date:', formatDate(widget.invoice.expiryDate)),
              if (_isExpanded) _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInvoiceRow(String label, dynamic value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        value is Widget ? value : Text(value.toString()),
      ],
    );
  }

  Widget _buildApprovalRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Approve:'),
        ElevatedButton(
          onPressed: () {
            // Define the action to perform when the button is pressed
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.invoice.approve == 'Access' ? Colors.blue : Colors.yellow,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(widget.invoice.approve, style: const TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildPaymentTypeContainer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: widget.invoice.paymentType == 'Fixed' ? Colors.purpleAccent : Colors.greenAccent,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        widget.invoice.paymentType,
        style: TextStyle(color: widget.invoice.paymentType == 'Fixed' ? Colors.white : Colors.black),
      ),
    );
  }

  Widget _buildStatusContainer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: widget.invoice.status == 'Active' ? Colors.blueAccent : const Color.fromARGB(255, 247, 211, 54),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        widget.invoice.status,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

Widget _buildActionButtons() {
  return Column(
    children: [
      const SizedBox(height: 10),
      const Divider(),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: widget.invoice.deliveryStatus == 'Unsent'
          ? [
              _buildIconActionButton(Icons.restart_alt, 'Amend', () {
                // Define the action to amend
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AmendInvoicePage(
                      invoiceNumber:widget.invoice.invoiceNumber,
                      invoiceDate:widget.invoice.invoiceDate,
                      invoiceDueDate:widget.invoice.dueDate,
                      invoiceExpiryDate:widget.invoice.expiryDate,
                      customer:widget.invoice.customerName,
                      paymentType:widget.invoice.paymentType,
                      currency:widget.invoice.currencyCode,
                      customerSno:widget.invoice.invMasNo,
                      invMasSno:widget.invoice.invMasSno,
                    ),
                  ),
                );
              }, Colors.purple),
              _buildIconActionButton(Icons.local_shipping, 'Deliver', () {
                // Define the action to deliver
                _showShippingPopup();
              }, Colors.green),
              _buildIconActionButton(Icons.cancel, 'Cancel', () {
                // Define the action to cancel
                _showCancelPopup();
              },Colors.red),
              _buildIconActionButton(Icons.visibility, 'View Details', () {
                // Define the action to view details
              }, Colors.yellow),
              _buildIconActionButton(Icons.download, 'Download', () {
                // Define the action to download PDF
              }, Colors.black),
            ]
          : [
              _buildIconActionButton(Icons.visibility, 'View Details', () {
                // Define the action to view details
              }, Colors.yellow),
              _buildIconActionButton(Icons.download, 'Download', () {
                // Define the action to download PDF
              }, Colors.black),
            ],
      ),
    ],
  );
}

void _showShippingPopup() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cancel Invoice'),
          content: Text(
            'Are you sure you want to deliver items for invoice  "${widget.invoice.invoiceNumber}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the popup
              },
              child: const Text('Close'),
            ),
          TextButton(
            onPressed: () {
              _confirmApprovellation();
            },
              child: const Text('Confirm'),
          ),
        ],
      );
    },
  );   
}

void _confirmApprovellation() {
  Navigator.pop(context); // Close the confirmation popup
  deliverlInvoice();
}

 Future<void> deliverlInvoice() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // int instituteID = prefs.getInt('instID') ?? 0;
      int userID = prefs.getInt('userID') ?? 0;

      // Body of the API request
      final Map<String, int> body = {
        // "compid": instituteID
        "sno": widget.invoice.invMasSno,
        "user_id": userID
      };

      // Start loading
      setState(() {
        isLoading = true;
      });

      // Make the API request
      final addDCode = await InvoiceApis.addDCode.sendRequest(body: body);

      // Check if the response is valid
      if (addDCode['response'] != null) {
        _showErrorDialog("successful.");
      } else {
        // Handle empty or invalid response
        _showErrorDialog("Invalid response from the server.");
      }
    } 
    on http.ClientException {
          _showErrorDialog("No internet connection. Please check your network.");
    } on HttpException {
      // Handle server-related errors
      _showErrorDialog("Couldn't retrieve data from the server.");
    } on FormatException {
      // Handle invalid response format (JSON parsing errors)
      _showErrorDialog("Invalid response format.");
    } catch (e) {
      // Handle any other errors
      _showErrorDialog("An unexpected error occurred: $e");
    } finally {
      // Stop loading in any case
      setState(() {
        isLoading = false;
      });
    }
  }

void _showCancelPopup() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cancel Invoice'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Reason'),
              const SizedBox(height: 8),
              TextField(
                //to get the data form the textfild 
                controller: _reasonController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter reason for cancellation',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              const Text(
                'Once cancelled, changes cannot be undone. Please proceed with caution.',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the popup
              },
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () {
                _validateAndProceed();
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
}

void _validateAndProceed() {
    if (_reasonController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a reason for cancellation')),
      );
    } else {
      Navigator.pop(context); // Close the first popup
      _showConfirmationPopup();
    }
}

void _showConfirmationPopup() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cancel Invoice'),
          content: Text(
            'Are you sure you want to cancel invoice "${widget.invoice.invoiceNumber}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the popup
              },
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () {
                _confirmCancellation();
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  void _confirmCancellation() {
  Navigator.pop(context); // Close the confirmation popup
  cancelInvoice();
}

bool isLoading = true;

Future<void> cancelInvoice() async {
  try {
    // SharedPreferences to get stored values
    final prefs = await SharedPreferences.getInstance();
    int instituteID = prefs.getInt('instID') ?? 0;
    int userID = prefs.getInt('userID') ?? 0;
    String token = prefs.getString('token') ?? ''; // Token from SharedPreferences

    // Define your API URL
    const String url = 'http://192.168.100.50:98/api/Invoice/AddCancel';

    // Prepare the body with necessary details
    Map<String, dynamic> requestBody = {
      "compid": instituteID, // Company ID
      "invno": widget.invoice.invoiceNumber, // Invoice number
      "auname": "", // Actual user name
      "date": DateTime.now().toIso8601String(), // Current date
      "edate": DateTime.now().toIso8601String(), // End date
      "iedate": DateTime.now().toIso8601String(), // Invoice expired date
      "ptype": widget.invoice.paymentType, // Payment type
      "chus": widget.invoice.invMasNo, // Customer number
      "comno": 0, // Company number
      "ccode": widget.invoice.currencyCode, // Currency code
      "ctype": "0", // Placeholder for type information
      "cino": "0", // Control number
      "twvat": 0, // Total without VAT
      "vtamou": 0, // VAT amount
      "total": widget.invoice.total.toString(), // Total amount
      "Inv_remark": "", // Invoice remarks
      "lastrow": 0, // Last row
      "details": [
        {
          "Inv_Mas_Sno": widget.invoice.invMasSno,
          "Invoice_Date": widget.invoice.invoiceDate,
          "Payment_Type": widget.invoice.paymentType,
          "Invoice_No": widget.invoice.invoiceNumber,
          "Invoice_Expired_Date": widget.invoice.expiryDate,
          "Reason": _reasonController.text, // Reason for cancellation
          "Status": widget.invoice.status,
          "Mobile": "",
        }
      ],

      "sno": widget.invoice.invMasSno,
      "reason": _reasonController.text, // Cancellation reason
      "userid": userID, // User ID
    };

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      setState(() {
        isLoading = false;
        
      });

      _showSnackBar('Invoice cancelled successfully');
    } else {
      _showSnackBar('Failed to cancel the invoice');
    }
  } catch (e) {
    if (e is http.ClientException) {
          // Network error
          _showErrorDialog('Network error. Please check your connection and try again.');

        } else {
          // Other exceptions
          _showErrorDialog('An unexpected error occurred. Please try again.');
          
        }
    setState(() {
      // _showSnackBar ('Error checking invoice number'); // Error in the request
      isLoading = false;
    });
  }
}

void _showSnackBar(String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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


Widget _buildIconActionButton(IconData icon, String label, VoidCallback onPressed, Color iconColor) {
  return Column(
    children: [
      Container(
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          border: Border.all(color: iconColor, width: 2),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),        // Flat edge
            topRight: Radius.circular(16),       // Curved edge
            bottomLeft: Radius.circular(16),     // Curved edge
            bottomRight: Radius.circular(16),     // Flat edge
          ), // Apply caved corner effect
        ),
        child: IconButton(
          icon: Icon(icon, color: iconColor),
          onPressed: onPressed,
        ),
      ),
      Text(label, style: const TextStyle(fontSize: 12)),
    ],
  );
}

Widget _buildActionButton(String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(label),
    );
  }
}