import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;


class CustomerDetailsPage extends StatefulWidget {
  final String name;
  final String email;
  final String mobile;

  const CustomerDetailsPage({
    super.key,
    required this.name,
    required this.email,
    required this.mobile,
  });

  @override
  _CustomerDetailsPageState createState() => _CustomerDetailsPageState();
}

class _CustomerDetailsPageState extends State<CustomerDetailsPage> {
  final TextEditingController _searchController = TextEditingController();
  final List<TransactionCardData> _transactions = [
    TransactionCardData('F9032', 'Fri Sep 06 2024', 'T00070213', '111,000 TZS', 'Approved'),
    TransactionCardData('F9033', 'Fri Sep 07 2024', 'T00070214', '50,000 TZS', 'Pending'),
    // Add more transaction data as needed
  ];
  List<TransactionCardData> _filteredTransactions = [];

  @override
  void initState() {
    super.initState();
    _filteredTransactions = _transactions;
  }

  void _filterTransactions(String query) {
    setState(() {
      _filteredTransactions = _transactions
          .where((transaction) => transaction.invoiceNo.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Details', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
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
              child: ListView.builder(
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
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class TransactionCardData {
  final String invoiceNo;
  final String created;
  final String controlNo;
  final String amount;
  final String status;

  TransactionCardData(this.invoiceNo, this.created, this.controlNo, this.amount, this.status);
}

class TransactionCard extends StatefulWidget {
  final String invoiceNo;
  final String created;
  final String controlNo;
  final String amount;
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
              Text(
                'Invoice No: ${widget.invoiceNo}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Text('Created: ${widget.created}'),
              const SizedBox(height: 5),
              Text('Amount: ${widget.amount}'),
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
                      Text('Control No: ${widget.controlNo}'),
                      IconButton(
                        icon: const Icon(Icons.visibility),
                        onPressed: () {
                          // Action for viewing control number details
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