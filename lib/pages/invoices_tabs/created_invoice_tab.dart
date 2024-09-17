import 'package:flutter/material.dart';
import '../invoices_section.dart'; // Import Invoice class

class CreatedInvoiceTab extends StatefulWidget {
  final List<Invoice> createdInvoices;
  final Function(String) filterCreatedInvoices;

  const CreatedInvoiceTab({
    required this.createdInvoices,
    required this.filterCreatedInvoices,
    super.key,
  });

  @override
  _CreatedInvoiceTabState createState() => _CreatedInvoiceTabState();
}

class _CreatedInvoiceTabState extends State<CreatedInvoiceTab> {
  final List<Invoice> createdInvoices = [
    Invoice('Wang Ones', 'APP/082302', 'Fri Aug 23 2024', '245,000 TZS', 'Fixed', 'Sat Aug 31 2024', 'Sat Sep 06 2024'),
    Invoice('Jackie Jackies', 'APP/082303', 'Fri Aug 23 2024', '4,000 TZS', 'Flexible', 'Fri Aug 30 2024', 'Fri Sep 06 2024'),
    Invoice('Pio Pio J.', 'APP/082304', 'Fri Aug 23 2024', '5,000 TZS', 'Fixed', 'Fri Aug 30 2024', 'Fri Sep 06 2024'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              labelText: 'Search by name or invoice',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
            onChanged: (query) => widget.filterCreatedInvoices(query),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: createdInvoices.length, // Use the local createdInvoices list
            itemBuilder: (context, index) {
              return _buildInvoiceCard(createdInvoices[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInvoiceCard(Invoice invoice) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: ExpansionTile(
        title: Text(invoice.invoiceNumber),
        subtitle: Text(invoice.customerName),
        children: [
          ListTile(
            title: Text('Invoice Date: ${invoice.invoiceDate}'),
          ),
          ListTile(
            title: Text('Total: ${invoice.total}'),
          ),
          ListTile(
            title: Text('Payment Type: ${invoice.paymentType}'),
          ),
          ListTile(
            title: Text('Due Date: ${invoice.dueDate}'),
          ),
          ListTile(
            title: Text('Expiry Date: ${invoice.expiryDate}'),
          ),
        ],
      ),
    );
  }
}
