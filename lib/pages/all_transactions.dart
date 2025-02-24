import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:learingdart/core/api/endpoint_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AllTransactionsPage extends StatefulWidget {
  final String invoiceSno;

  const AllTransactionsPage({super.key, required this.invoiceSno});

  @override
  State<AllTransactionsPage> createState() => _AllTransactionsPageState();
}

class _AllTransactionsPageState extends State<AllTransactionsPage> {
  String _token = 'Not logged in';
  List<InvoiceData> invoices = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSessionInfo();
    fetchInvoices();
  }

  Future<void> _loadSessionInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('token') ?? 'Not logged in';
    });
  }

  Future<void> fetchInvoices() async {
    setState(() => isLoading = true);
    const url = ApiEndpoints.allTransactions;

    try {
      final prefs = await SharedPreferences.getInstance();
      int instituteID = prefs.getInt('instID') ?? 0;
      int userID = prefs.getInt('userID') ?? 0;

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({"invoice_sno": widget.invoiceSno}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['response'].isEmpty) {
          setState(() {
            invoices = [];
            isLoading = false;
          });
        } else {
          setState(() {
            invoices = (data['response'] as List)
                .map((e) => InvoiceData.fromJson(e))
                .toList();
            isLoading = false;
          });
        }
      } else {
        _showQuickAlert(context, 'Error', 'Failed to fetch transactions: ${response.body}', false);
      }
    } catch (e) {
      _showErrorDialog('An unexpected error occurred. Please try again.');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showQuickAlert(BuildContext context, String title, String message, bool isSuccess) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Theme.of(context).colorScheme.surface // Dark mode
          : Theme.of(context).colorScheme.primary, // Light mode
        title: const Text('All Transactions', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        // backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : invoices.isEmpty
                    ? const Center(child: Text('No data found'))
                    : Expanded(
                        child: ListView.builder(
                          itemCount: invoices.length,
                          itemBuilder: (context, index) {
                            return _InvoiceCard(invoice: invoices[index]);
                          },
                        ),
                      ),
          ],
        ),
      ),
    );
  }
}

class _InvoiceCard extends StatelessWidget {
  final InvoiceData invoice;
  final formatter = NumberFormat('#,###');

   _InvoiceCard({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInvoiceRow('VENDOR', invoice.companyName),
            const SizedBox(height: 5),
            _buildInvoiceRow('CUSTOMER', invoice.customerName),
            const SizedBox(height: 5),
            _buildInvoiceRow('DESCRIPTION', invoice.paymentDesc),
            const SizedBox(height: 5),
            _buildInvoiceRow('TRANSACTION TYPE', invoice.paymentType ?? 'N/A'),
            const SizedBox(height: 5),
            _buildInvoiceRow('PAYER', invoice.payerName ?? 'N/A'),
            const SizedBox(height: 5),
            _buildInvoiceRow('METHOD', invoice.transChannel ?? 'N/A'),
            const SizedBox(height: 5),
            _buildInvoiceRow('AMOUNT', formatter.format(double.tryParse(invoice.requestedAmount ?? '0') ?? 0)),
            const SizedBox(height: 5),
            _buildInvoiceRow('BALANCE', formatter.format(double.tryParse(invoice.balance ?? '0') ?? 0)),
            const SizedBox(height: 5),
            _buildInvoiceRow('CURRENCY', invoice.currencyCode ?? 'N/A'),
            const SizedBox(height: 5),
            _buildInvoiceRow('STATUS', invoice.status ?? 'N/A'),
            const SizedBox(height: 5),
            _buildInvoiceRow('ATTACHMENT(S)', ''),
            const SizedBox(height: 5),
            _buildInvoiceRow('Receipt No:', invoice.receiptNo ?? 'N/A'),
            const SizedBox(height: 5),
            _buildInvoiceRow(
              'Payment Date:',
              Text(invoice.paymentDate != null ? _formatDate(invoice.paymentDate!) : 'N/A'),
            ),
            const SizedBox(height: 5),
            _buildInvoiceRow(
              '',
              _buildIconActionButton(Icons.visibility, '', () {}, const Color.fromARGB(255, 128, 116, 12)),
            ),
          ],
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

  String _formatDate(String dateStr) {
    try {
      DateTime dateTime = DateTime.parse(dateStr);
      return DateFormat('EEE MMM dd yyyy').format(dateTime);
    } catch (e) {
      return 'Invalid date';
    }
  }

  Widget _buildIconActionButton(IconData icon, String label, VoidCallback onPressed, Color iconColor) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            border: Border.all(color: iconColor, width: 2),
            borderRadius: const BorderRadius.all(Radius.circular(16)),
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
}

class InvoiceData {
  final String paymentTransNo;
  final String companyName;
  final String paymentDesc;
  final String? paymentType;
  final String? payerName;
  final String? transChannel;
  final String? requestedAmount;
  final String? balance;
  final String? currencyCode;
  final String? status;
  final String? receiptNo;
  final String? paymentDate;
  final String? customerName;

  InvoiceData({
    required this.paymentTransNo,
    required this.companyName,
    required this.paymentDesc,
    required this.paymentType,
    required this.payerName,
    required this.transChannel,
    required this.requestedAmount,
    required this.balance,
    required this.currencyCode,
    required this.status,
    required this.receiptNo,
    required this.paymentDate,
    required this.customerName,
  });

  factory InvoiceData.fromJson(Map<String, dynamic> json) {
    return InvoiceData(
      paymentTransNo: json['Payment_Trans_No'] ?? '',
      companyName: json['Company_Name'] ?? '',
      paymentDesc: json['Payment_Desc'] ?? '',
      paymentType: json['Payment_Type'],
      payerName: json['Payer_Name'],
      transChannel: json['Trans_Channel'],
      requestedAmount: json['Requested_Amount']?.toString(),
      balance: json['Balance']?.toString(),
      currencyCode: json['Currency_Code'],
      status: json['Status'],
      receiptNo: json['Receipt_No'],
      paymentDate: json['Payment_Date'],
      customerName: json['Customer_Name'],
    );
  }
}
