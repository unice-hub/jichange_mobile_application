// ignore_for_file: library_private_types_in_public_api

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:learingdart/core/api/endpoint_api.dart';
import 'package:learingdart/pages/create_invoice_for_specific_customer.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'all_transactions.dart';




class CustomerDetailsPage extends StatefulWidget {
  final String name;
  final String email;
  final String mobile;
  final int custSno;
  

  const CustomerDetailsPage({
    super.key,
    required this.name,
    required this.email,
    required this.mobile,
    required this.custSno,
  });

  @override
  _CustomerDetailsPageState createState() => _CustomerDetailsPageState();
}

class _CustomerDetailsPageState extends State<CustomerDetailsPage> {
  final TextEditingController _searchController = TextEditingController();

  String searchQuery = "";
  late String _token = '';
  bool isLoading = true;
  List<TransactionCardData> _transactions = [];
  List<TransactionCardData> _filteredTransactions = [];



  @override
  void initState() {
    super.initState();
    _filteredTransactions = _transactions;
     _fetchInvoicesData();
    _loadSessionInfo();
  }

  Future<void> _loadSessionInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('token') ?? '';
    });
    _fetchInvoicesData();
  }

  Future<void> _fetchInvoicesData() async {
    
    const url = ApiEndpoints.getInvReport; //endpoints for get invoicereport
    
    try {
      final prefs = await SharedPreferences.getInstance();
      int instituteID = prefs.getInt('instID') ?? 0;
      int userID = prefs.getInt('userID') ?? 0;
     log(instituteID.toString());

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({
          "companyIds": [instituteID],
          "customerIds": [widget.custSno],
          "enddate": "",
          "allowCancelInvoice": false //true//false
        }),
      );
      print(response.body);
       log(widget.custSno.toString());

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
       final responseData = jsonDecode(response.body)['response'];

        if (responseBody['response'] is List) {
          setState(() {
            _transactions = (responseBody['response'] as List)
                .map((item) => TransactionCardData.fromJson(item, userID))
                .toList();
                
            _filteredTransactions = _transactions; // Set filtered list to transactions
            isLoading = false;
          });
        } else if(responseBody['response'] is Map) {
          setState(() {
            _transactions = [TransactionCardData.fromJson(responseBody['response'], userID)];
            _filteredTransactions = _transactions; // Set filtered list to transactions
            isLoading = false;
          });

        }else{
          _showSnackBar('Unexpected data format: response is not a list');
        }
      } 
      // else {
      //   _showSnackBar('Error: Failed to fetch invoices');
      // }
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

  // Show error dialog in case of failure

 void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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

 

  void _filterTransactions(String query) {
    setState(() {
      _filteredTransactions = _transactions
          .where((transaction) => transaction.invoiceNo.toLowerCase().contains(query.toLowerCase()))
          .toList();
          isLoading = false;
    });
    
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###');
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Theme.of(context).colorScheme.surface // Dark mode
          : Theme.of(context).colorScheme.primary, // Light mode
        title: const Text('Customer Details', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        // backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Customer Details Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Customer details',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text('Name: ${widget.name}'),
                    Text('Email: ${widget.email}'),
                    Text('Mobile: ${widget.mobile}'),
                    //  Text('custSno: ${widget.custSno}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Transactions Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Transactions',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: TextField(
                    controller: _searchController,
                    onChanged: _filterTransactions,
                    decoration: const InputDecoration(
                      labelText: 'Search Invoice No.',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Transaction Cards
            Expanded(
              child: isLoading
                  ? const Center(
                    child: CircularProgressIndicator())
                    :_filteredTransactions.isEmpty
                    ? const Center(
                      child: Text('No Data found',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color:Colors.grey,
                      ),
                    ),
                    )
                  : ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: _filteredTransactions.length,
                    itemBuilder: (context, index) {
                      final transaction = _filteredTransactions[index];
                      return TransactionCard(
                        invoiceNo: transaction.invoiceNo,
                        created: transaction.created,
                        controlNo: transaction.controlNo,
                        amount: transaction.amount,
                        status: transaction.status,
                      );
                    },
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Action for floating button
          // Define the action to add the invoice
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CreateInvoiceForSpecificCustomer(
                  customer: widget.name,
                  customerSno: widget.custSno,
                ),
              ),
            );
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class TransactionCardData {
  final String invoiceNo;
  final String created;
  final String controlNo;
  final double amount;
  final String status;

  TransactionCardData(
    this.invoiceNo, 
    this.created, 
    this.controlNo, 
    this.amount, 
    this.status
  );

  factory TransactionCardData.fromJson(Map<String, dynamic> json, int userID){
    return TransactionCardData(
      json['Invoice_No'],
      json['Invoice_Date'],
      json['Control_No'],
      json['Total'],
      json['Status'],
    );
  }
}

class TransactionCard extends StatefulWidget {
  final String invoiceNo;
  final String created;
  final String controlNo;
  final double amount;
  final String status;

  const TransactionCard({
    super.key,
    required this.invoiceNo,
    required this.created,
    required this.controlNo,
    required this.amount,
    required this.status,
  });

  @override
  _TransactionCardState createState() => _TransactionCardState();
}

class _TransactionCardState extends State<TransactionCard> {
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
              Text('Created: ${widget.created}'),
              Text(
                'Invoice No: ${widget.invoiceNo}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Text('Control N°:  ${widget.controlNo}'),
              const SizedBox(height: 5),
              Text('Amount:  ${widget.amount}'),
              const SizedBox(height: 5),
              Text(
                'Status: ${widget.status}',
                style: TextStyle(color: widget.status == 'Approved' ? Colors.green : Colors.orange),
              ),
              if (_isExpanded) ...[
                const SizedBox(height: 10),
                const Divider(),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Action(s):'),
                      IconButton(
                        icon: const Icon(Icons.visibility),
                        
                        onPressed: () {
                          // Action for viewing control number details
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AllTransactionsPage(
                                invoiceSno: widget.invoiceNo,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
