import 'package:flutter/material.dart';

class CreateInvoicePage extends StatefulWidget {
  const CreateInvoicePage({super.key});

  @override
  _CreateInvoicePageState createState() => _CreateInvoicePageState();
}

class _CreateInvoicePageState extends State<CreateInvoicePage> {
  String? selectedBranch;
  String? selectedVendor;
  String? selectedCustomer;
  String? selectedInvoiceNumber;
  DateTime? fromDate;
  DateTime? toDate;

  List<String> branches = ['Magomeni', 'Ilala', 'Kawe', 'Joshua Speaker Urio'];
  List<String> vendors = ['Me&U Apparel', 'Vendor A', 'Vendor B', 'Joshua Speaker Urio'];
  List<String> customers = ['All', 'Customer A', 'Customer B', 'Joshua Speaker Urio'];
  List<String> invoiceNumbers = ['All', 'Invoice A', 'Invoice B', 'Joshua Speaker Urio'];

  // Dummy data for filtered results
  final List<Map<String, String>> filteredResults = [
    {
      'Payment Date': 'Thu Aug 22 2024',
      'Payer': 'Min Man',
      'Customer': 'Mini Man',
      'Invoice N°': 'ap01',
      'Control N°': 'T00060198',
      'Payment Method': 'MNO',
      'Transaction N°': 'AC9102900000',
      'Status': 'Not sent',
      'Receipt N°': 'TZSC339030',
      'Total Amount': '2,262,500 TZS',
      'Paid Amount': '2,262,500 TZS',
      'Payment Type': 'Fixed',
    },
    // Additional entries can go here
  ];

  Future<void> _selectDate(BuildContext context, bool isFrom) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          fromDate = picked;
        } else {
          toDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Invoice', style: TextStyle(color: Colors.white)),
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
      body: SingleChildScrollView( // Wrap the entire content in SingleChildScrollView
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Filters Section
            Column(
              children: [
                // Invoice number
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'Invoice number',
                    border: OutlineInputBorder(),
                    hintText: 'Enter invoice number',
                  ),
                ),
                const SizedBox(height: 16),

                // From (Invoice Date)
                InkWell(
                  onTap: () => _selectDate(context, true),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Invoice Date',
                      suffixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(),
                    ),
                    child: Text(
                      fromDate == null ? 'Choose a date' : fromDate!.toLocal().toString().split(' ')[0],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Invoice due date
                InkWell(
                  onTap: () => _selectDate(context, false),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Invoice due Date',
                      suffixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(),
                    ),
                    child: Text(
                      toDate == null ? 'Choose a date' : toDate!.toLocal().toString().split(' ')[0],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Invoice due date
                InkWell(
                  onTap: () => _selectDate(context, false),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Invoice expiry Date',
                      suffixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(),
                    ),
                    child: Text(
                      toDate == null ? 'Choose a date' : toDate!.toLocal().toString().split(' ')[0],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Customer Dropdown
                DropdownButtonFormField<String>(
                  value: selectedCustomer,
                  isExpanded: true,
                  hint: const Text('Select Customer'),
                  items: customers.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      selectedCustomer = newValue;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Customer',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Invoice Number Dropdown
                DropdownButtonFormField<String>(
                  value: selectedInvoiceNumber,
                  isExpanded: true,
                  hint: const Text('Select a payment type'),
                  items: invoiceNumbers.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      selectedInvoiceNumber = newValue;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Payment type',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Invoice remark Dropdown (Optional)
                DropdownButtonFormField<String>(
                  value: selectedInvoiceNumber,
                  isExpanded: true,
                  hint: const Text('Enter invoice remark'),
                  items: invoiceNumbers.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      selectedInvoiceNumber = newValue;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Invoice remark (Optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: () {
                // Implement filtering logic here
              },
              child: const Text('Submit'),
            ),
            const SizedBox(height: 16),

            // Export buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    // Export to Excel logic here
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('ADD'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent,
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    // Export to PDF logic here
                  },
                  icon: const Icon(Icons.remove),
                  label: const Text('REMOVE'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Filtered Results Section
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(), // Disable scrolling in the inner ListView
              shrinkWrap: true, // Allow ListView to take only the space it needs
              itemCount: filteredResults.length,
              itemBuilder: (context, index) {
                final item = filteredResults[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ExpansionTile(
                    title: Text('Invoice N°: ${item['Invoice N°']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Customer: ${item['Customer']}'),
                        Text('Total Amount: ${item['Total Amount']}'),
                        Text('Status: ${item['Status']}'),
                      ],
                    ),
                    children: [
                      ListTile(
                        title: Text('Control N°: ${item['Control N°']}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Payment Date: ${item['Payment Date']}'),
                            Text('Paid Amount: ${item['Paid Amount']}'),
                            Text('Payment Method: ${item['Payment Method']}'),
                            Text('Transaction N°: ${item['Transaction N°']}'),
                            Text('Receipt N°: ${item['Receipt N°']}'),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
