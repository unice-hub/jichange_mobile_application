import 'package:flutter/material.dart';

class InvoiceDetailsPage extends StatefulWidget {
  const InvoiceDetailsPage({super.key});

  @override
  _InvoiceDetailsPageState createState() => _InvoiceDetailsPageState();
}

class _InvoiceDetailsPageState extends State<InvoiceDetailsPage> {
  String? selectedVendor;
  String? selectedCustomer;
  DateTime? fromDate;
  DateTime? toDate;

  List<String> vendors = ['Me&U Apparel', 'Vendor A', 'Vendor B'];
  List<String> customers = ['All', 'Customer A', 'Customer B'];

  // Dummy data for filtered results
  final List<Map<String, String>> filteredResults = [
    {
      'Date Posted': 'Mon Aug 19 2024',
      'Customer': 'Juma Juma',
      'Invoice No': 'App/01',
      'Control No': 'T00060199',
      'Payment Type': 'Flexible',
      'Delivery Status': 'Unsent',
      'Status': 'Expired',
      'Total Amount': '1,619,500 TZS',
      'Posted by': '255400400400',
      'Invoice Date': 'Thu Aug 15 2024',
      'Due Date': 'Sun Aug 18 2024',
      'Reason': 'Item not delivered',
    },
    // Additional data entries can go here
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
        title: const Text('Invoice Details', style: TextStyle(color: Colors.white)),
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
            Row(
              children: [
                // Vendor Dropdown
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
                const SizedBox(width: 16),
                // Customer Dropdown
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
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                // From Date Picker
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
                // To Date Picker
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
            Expanded(
              child: ListView.builder(
                itemCount: filteredResults.length,
                itemBuilder: (context, index) {
                  final item = filteredResults[index];
                  return ExpansionTile(
                    title: Text('Invoice No: ${item['Invoice No']}'),
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
                        title: Text('Control No: ${item['Control No']}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Payment Type: ${item['Payment Type']}'),
                            Text('Delivery Status: ${item['Delivery Status']}'),
                            Text('Date Posted: ${item['Date Posted']}'),
                            Text('Invoice Date: ${item['Invoice Date']}'),
                            Text('Due Date: ${item['Due Date']}'),
                            Text('Posted by: ${item['Posted by']}'),
                            Text('Reason: ${item['Reason']}'),
                          ],
                        ),
                      ),
                    ],
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
