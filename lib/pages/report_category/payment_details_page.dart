import 'package:flutter/material.dart';

class PaymentDetailsPage extends StatefulWidget {
  const PaymentDetailsPage({super.key});

  @override
  _PaymentDetailsPageState createState() => _PaymentDetailsPageState();
}

class _PaymentDetailsPageState extends State<PaymentDetailsPage> {
  String? selectedVendor;
  String? selectedCustomer;
  DateTime? fromDate;
  DateTime? toDate;

  List<String> vendors = ['Me&U Apparel', 'Vendor 2', 'Vendor 3'];
  List<String> customers = ['All', 'Customer 1', 'Customer 2'];

  // Function to pick a date
  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2125),
    );
    if (picked != null) {
      setState(() {
        if (isFromDate) {
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
        title: const Text('Payment Details', style: TextStyle(color: Colors.white)),
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
            // Filter section
            _buildFilterSection(),
            const SizedBox(height: 16.0),
            
            // Action buttons for downloading filtered data
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    // Download as spreadsheet action
                  },
                  icon: const Icon(Icons.download),
                  label: const Text('Spreadsheet'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
                const SizedBox(width: 16.0),
                ElevatedButton.icon(
                  onPressed: () {
                    // Download as PDF action
                  },
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),

            // Display the filtered payment details
            Expanded(
              child: ListView.builder(
                itemCount: 3, // Number of payment details
                itemBuilder: (context, index) {
                  return _buildPaymentCard(index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Column(
      children: [
        Row(
          children: [
            // Vendor Dropdown
            Expanded(
              child: DropdownButtonFormField<String>(
                value: selectedVendor,
                items: vendors.map((vendor) {
                  return DropdownMenuItem(
                    value: vendor,
                    child: Text(vendor),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedVendor = value;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Vendor',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 16.0),
            // Customer Dropdown
            Expanded(
              child: DropdownButtonFormField<String>(
                value: selectedCustomer,
                items: customers.map((customer) {
                  return DropdownMenuItem(
                    value: customer,
                    child: Text(customer),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCustomer = value;
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
        const SizedBox(height: 16.0),
        Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context, true),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'From (Payment date)',
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
                        labelText: 'To (Payment date)',
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
        const SizedBox(height: 16.0),
        // Submit button for filtering
        ElevatedButton(
          onPressed: () {
            // Filter action
          },
          child: const Text('SUBMIT'),
        ),
      ],
    );
  }

  Widget _buildPaymentCard(int index) {
    // Sample payment data (replace with actual data)
    final paymentDetails = {
      'paymentDate': 'Thu Aug 22 2024',
      'customer': 'Mini Man',
      'invoiceNumber': 'APP/082301',
      'paymentType': 'Fixed',
      'status': 'Completed',
      'totalAmount': '2,262,500 TZS',
      'paidAmount': '2,262,500 TZS',
      'balance': '0 TZS',
      'controlNumber': 'T00060198',
      'transactionNumber': 'AC910209000',
      'receiptNumber': 'TZSC393030',
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: ExpansionTile(
        title: Text(paymentDetails['invoiceNumber']!),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Customer: ${paymentDetails['customer']}'),
            Text('Total Amount: ${paymentDetails['totalAmount']}'),
            Text('Payment Date: ${paymentDetails['paymentDate']}'),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Invoice N°: ${paymentDetails['invoiceNumber']}'),
                Text('Payment Type: ${paymentDetails['paymentType']}'),
                Text('Status: ${paymentDetails['status']}'),
                Text('Paid Amount: ${paymentDetails['paidAmount']}'),
                Text('Balance: ${paymentDetails['balance']}'),
                Text('Control N°: ${paymentDetails['controlNumber']}'),
                Text('Transaction N°: ${paymentDetails['transactionNumber']}'),
                Text('Receipt N°: ${paymentDetails['receiptNumber']}'),
                const SizedBox(height: 8.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.visibility, color: Colors.amber),
                      onPressed: () {
                        // View action
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
