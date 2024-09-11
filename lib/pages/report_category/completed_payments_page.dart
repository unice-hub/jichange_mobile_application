import 'package:flutter/material.dart';

class CompletedPaymentsPage extends StatefulWidget {
  const CompletedPaymentsPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CompletedPaymentsPageState createState() => _CompletedPaymentsPageState();
}

class _CompletedPaymentsPageState extends State<CompletedPaymentsPage> {
  String? selectedBranch;
  String? selectedVendor;
  String? selectedCustomer;
  String? selectedInvoiceNumber;
  DateTime? fromDate;
  DateTime? toDate;

  List<String> branches = ['Magomeni', 'Ilala', 'Kawe'];
  List<String> vendors = ['Me&U Apparel', 'Vendor A', 'Vendor B'];
  List<String> customers = ['All', 'Customer A', 'Customer B'];
  List<String> invoiceNumbers = ['All', 'Invoice A', 'Invoice B'];

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
    if (picked != null && picked != (isFrom ? fromDate : toDate)) {
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
        title: const Text('Completed Payments', style: TextStyle(color: Colors.white)),
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
          children: [
            // Filters Section
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedBranch,
                    hint: const Text('Select Branch'),
                    items: branches.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        selectedBranch = newValue;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Branch',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedVendor,
                    hint: const Text('Select Vendor'),
                    items: vendors.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        selectedVendor = newValue;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Vendor',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedCustomer,
                    hint: const Text('Select Customer'),
                    items: customers.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
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
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedInvoiceNumber,
                    hint: const Text('Select Invoice Number'),
                    items: invoiceNumbers.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        selectedInvoiceNumber = newValue;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Invoice Number',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context, true),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'From (Invoice Date)',
                        suffixIcon: Icon(Icons.calendar_today),
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        fromDate == null ? 'Choose a date' : fromDate.toString().substring(0, 10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context, false),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'To (Invoice Date)',
                        suffixIcon: Icon(Icons.calendar_today),
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        toDate == null ? 'Choose a date' : toDate.toString().substring(0, 10),
                      ),
                    ),
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
                  icon: const Icon(Icons.download),
                  label: const Text('Export to Excel'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    // Export to PDF logic here
                  },
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Export to PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Filtered Results Section
            Expanded(
              child: ListView.builder(
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
            ),
          ],
        ),
      ),
    );
  }
}
