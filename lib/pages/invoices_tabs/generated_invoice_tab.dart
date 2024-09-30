import 'package:flutter/material.dart';
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
      _showSnackBar('Error: $e');
    }
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
  final String control_No;
  final String invoiceDate;
  final String approve;
  final String paymentType;
  final String deliveryStatus;
  final String status;
  final double total;
  final String currencyCode;
  final String dueDate;
  final String expiryDate;

  InvoiceData(
    this.customerName,
    this.invoiceNumber,
    this.control_No,
    this.invoiceDate,
    this.approve,
    this.paymentType,
    this.deliveryStatus,
    this.status,
    this.total,
    this.currencyCode,
    this.dueDate,
    this.expiryDate,
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
              _buildInvoiceRow('Control N°:', widget.invoice.control_No),
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
        children: [
          _buildIconActionButton(Icons.visibility, 'View Details', () {
            // Define the action to view details
          }),
          _buildIconActionButton(Icons.picture_as_pdf, 'Download PDF', () {
            // Define the action to download PDF
          }),
          _buildIconActionButton(Icons.edit, 'Edit', () {
            // Define the action to edit the invoice
          }),
          _buildIconActionButton(Icons.cancel, 'Cancel', () {
            // Define the action to cancel
          }),
        ],
      ),
    ],
  );
}

Widget _buildIconActionButton(IconData icon, String label, VoidCallback onPressed) {
  return Column(
    children: [
      IconButton(
        icon: Icon(icon, color: Theme.of(context).colorScheme.primary),
        onPressed: onPressed,
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