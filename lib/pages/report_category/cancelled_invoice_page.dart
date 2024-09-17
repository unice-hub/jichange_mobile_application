import 'package:flutter/material.dart';

class CancelledInvoicePage extends StatefulWidget {
  const CancelledInvoicePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CancelledInvoicePageState createState() => _CancelledInvoicePageState();
}


class _CancelledInvoicePageState extends State<CancelledInvoicePage> {
  String? selectedBranch;
  String? selectedVendor;
  String? selectedCustomer;
  String? selectedInvoiceNumber;
  DateTime? fromDate;
  DateTime? toDate;

  List<String> branches = ['Magomeni', 'Ilala', 'Kawe','joshua speaker urio'];
  List<String> vendors = ['Me&U Apparel', 'Vendor A', 'Vendor B','joshua speaker urio'];
  List<String> customers = ['All', 'Customer A', 'Customer B','joshua speaker urio'];
  List<String> invoiceNumbers = ['All', 'Invoice A', 'Invoice B','joshua speaker urio'];

  // Dummy data for filtered results
  final List<Map<String, String>> filteredResults = [
    {
      'No.': '1',
      'Posted': 'Fri Aug 23 2024',
      'Customer name': 'Minios',
      'Invoice N°': 'APP/0823100103',
      'Status': 'Cancelled',
      'Total Amount': '319,200 TZS',
      'Control N°': 'T00060219',
      'Reason': 'wrong customer',
      
    },
    {

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
        title: const Text('Cancelled Invoice', style: TextStyle(color: Colors.white)),
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
                  flex: 1,
                  child: DropdownButtonFormField<String>(
                    value: selectedBranch,
                    isExpanded: true,
                    hint: const Text('Select Branch'),
                    items: branches.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, overflow: TextOverflow.ellipsis),
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
                  flex: 1,
                  child: DropdownButtonFormField<String>(
                    value: selectedVendor,
                    isExpanded: true,
                    hint: const Text('Select Vendor'),
                    items: vendors.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, overflow: TextOverflow.ellipsis),
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
                  flex: 1,
                  child: DropdownButtonFormField<String>(
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
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<String>(
                    value: selectedInvoiceNumber,
                    isExpanded: true,
                    hint: const Text('Select Invoice Number'),
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
                          Text('Customer name: ${item['Customer name']}'),
                          Text('Status: ${item['Status']}'),
                          Text('Total Amount: ${item['Total Amount']}'),
                        ],
                      ),
                      children: [
                        ListTile(
                          title: Text('Control N°: ${item['Control N°']}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Reason: ${item['Reason']}'),
                              Text('Posted: ${item['Posted']}'),
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