import 'package:flutter/material.dart';
import '../invoices_section.dart'; // Import Invoice class

class GeneratedInvoiceTab extends StatefulWidget {
  final List<Invoice> generatedInvoices;
  final Function(String) filterGeneratedInvoices;

  const GeneratedInvoiceTab({
    required this.generatedInvoices,
    required this.filterGeneratedInvoices,
    super.key,
  });

  @override
  _GeneratedInvoiceTabState createState() => _GeneratedInvoiceTabState();
}

class _GeneratedInvoiceTabState extends State<GeneratedInvoiceTab> {
  final List<Invoice> generatedInvoices =[
     Invoice('Wang Ones', 'APP/082301', 'Fri Aug 23 2024', '596,550 TZS', 'Flexible', 'Fri Aug 30 2024', 'Sat Aug 31 2024'),
    Invoice('Mininos', 'APP/082003', 'Fri Aug 23 2024', '1,409,500 TZS', 'Flexible', 'Thu Sep 05 2024', 'Thu Sep 05 2024'),
    Invoice('Emmanuel', 'APP/902321', 'Fri Aug 30 2024', '165,000 TZS', 'Flexible', 'Mon Sep 02 2024', 'Tue Sep 03 2024'),
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
            onChanged: (query) => widget.filterGeneratedInvoices(query),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: generatedInvoices.length,
            itemBuilder: (context, index) {
              return _buildInvoiceCard(generatedInvoices[index]);
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
