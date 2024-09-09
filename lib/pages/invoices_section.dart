import 'package:flutter/material.dart';

class InvoicesSection extends StatefulWidget {
  const InvoicesSection({super.key});

  @override
  _InvoicesSectionState createState() => _InvoicesSectionState();
}

class _InvoicesSectionState extends State<InvoicesSection> {
  final List<Invoice> createdInvoices = [
    Invoice('Wang Ones', 'APP/082302', 'Fri Aug 23 2024', '245,000 TZS', 'Fixed', 'Sat Aug 31 2024', 'Sat Sep 06 2024'),
    Invoice('Jackie Jackies', 'APP/082303', 'Fri Aug 23 2024', '4,000 TZS', 'Flexible', 'Fri Aug 30 2024', 'Fri Sep 06 2024'),
    Invoice('Pio Pio J.', 'APP/082304', 'Fri Aug 23 2024', '5,000 TZS', 'Fixed', 'Fri Aug 30 2024', 'Fri Sep 06 2024'),
  ];

  final List<Invoice> generatedInvoices = [
    Invoice('Wang Ones', 'APP/082301', 'Fri Aug 23 2024', '596,550 TZS', 'Flexible', 'Fri Aug 30 2024', 'Sat Aug 31 2024'),
    Invoice('Mininos', 'APP/082003', 'Fri Aug 23 2024', '1,409,500 TZS', 'Flexible', 'Thu Sep 05 2024', 'Thu Sep 05 2024'),
    Invoice('Emmanuel', 'APP/902321', 'Fri Aug 30 2024', '165,000 TZS', 'Flexible', 'Mon Sep 02 2024', 'Tue Sep 03 2024'),
  ];

  List<Invoice> filteredInvoices = [];
  List<Invoice> filteredGeneratedInvoices = [];

  @override
  void initState() {
    super.initState();
    filteredInvoices = createdInvoices; // Display all created invoices initially
    filteredGeneratedInvoices = generatedInvoices; // Display all generated invoices initially
  }

  void _filterCreatedInvoices(String query) {
    setState(() {
      filteredInvoices = createdInvoices.where((invoice) {
        return invoice.customerName.toLowerCase().contains(query.toLowerCase()) ||
               invoice.invoiceNumber.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  void _filterGeneratedInvoices(String query) {
    setState(() {
      filteredGeneratedInvoices = generatedInvoices.where((invoice) {
        return invoice.customerName.toLowerCase().contains(query.toLowerCase()) ||
               invoice.invoiceNumber.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: TabBar(
            tabs: const [
              Tab(text: 'Created Invoice'),
              Tab(text: 'Generated Invoice'),
            ],
            labelColor: Theme.of(context).colorScheme.onPrimary,
            unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
        body: TabBarView(
          children: [
            _buildInvoiceTab(filteredInvoices, _filterCreatedInvoices),
            _buildInvoiceTab(filteredGeneratedInvoices, _filterGeneratedInvoices),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceTab(List<Invoice> invoices, Function(String) onFilter) {
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
            onChanged: (query) => onFilter(query),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: invoices.length,
            itemBuilder: (context, index) {
              return _buildInvoiceCard(invoices[index]);
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
        title: _buildSummaryRow(invoice),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Customer name', invoice.customerName),
                _buildInfoRow('Invoice N°', invoice.invoiceNumber),
                _buildInfoRow('Invoice Date', invoice.invoiceDate),
                _buildInfoRow('Payment type', invoice.paymentType),
                _buildInfoRow('Total', invoice.total),
                _buildInfoRow('Due Date', invoice.dueDate),
                _buildInfoRow('Expiry Date', invoice.expiryDate),
                const SizedBox(height: 8.0),
                _buildActionButtons(),
                const SizedBox(height: 8.0),
                _buildIconButtons(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(Invoice invoice) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(invoice.invoiceNumber, style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 4.0),
        Text('Due Date: ${invoice.dueDate}', style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 12.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(invoice.total, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              decoration: BoxDecoration(
                color: invoice.paymentType == 'Fixed' ? Colors.pinkAccent : Colors.lightBlueAccent,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                invoice.paymentType,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text('$label: ', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value, style: Theme.of(context).textTheme.bodyLarge)),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        ElevatedButton(
          onPressed: () {
            // Approve action
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green, // Material Design 3 color
          ),
          child: const Text('Approve'),
        ),
        ElevatedButton(
          onPressed: () {
            // Decline action
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red, // Material Design 3 color
          ),
          child: const Text('Decline'),
        ),
      ],
    );
  }

  Widget _buildIconButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        IconButton(
          icon: Icon(Icons.remove_red_eye_outlined, color: Theme.of(context).colorScheme.primary),
          onPressed: () {
            // View action
          },
        ),
        IconButton(
          icon: Icon(Icons.edit, color: Theme.of(context).colorScheme.secondary),
          onPressed: () {
            // Edit action
          },
        ),
        IconButton(
          icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
          onPressed: () {
            // Delete action
          },
        ),
        IconButton(
          icon: const Icon(Icons.file_copy, color: Colors.orange),
          onPressed: () {
            // Copy action
          },
        ),
        IconButton(
          icon: Icon(Icons.download, color: Theme.of(context).colorScheme.primary),
          onPressed: () {
            // Download action
          },
        ),
      ],
    );
  }
}

class Invoice {
  final String customerName;
  final String invoiceNumber;
  final String invoiceDate;
  final String total;
  final String paymentType;
  final String dueDate;
  final String expiryDate;

  Invoice(this.customerName, this.invoiceNumber, this.invoiceDate, this.total, this.paymentType, this.dueDate, this.expiryDate);
}
