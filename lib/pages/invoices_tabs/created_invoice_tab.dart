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
  final List<InvoiceData> createdInvoices = [
    InvoiceData('Wang Ones', 'APP/082302', 'Fri Aug 23 2024', 'No Access', 'Fixed', 'Active', '245,000 CDF', 'Mon Sep 30 2024', 'Fri Oct 04 2024'),
    InvoiceData('Jackie Jackies', 'APP/082303', 'Fri Aug 23 2024', 'Access', 'Flexible', 'No Active', '4,000 CDF', 'Mon Jan 29 2024', 'Fri Feb 04 2024'),
    InvoiceData('Pio Pio J.', 'APP/082304', 'Fri Aug 23 2024', 'No Access', 'Fixed', 'Active', '5,000 CDF', 'Mon Mar 10 2024', 'Fri Apr 04 2024'),
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
              final invoice = createdInvoices[index];
              return _InvoiceCard(
                customerName: invoice.customerName,
                invoiceNumber: invoice.invoiceNumber,
                invoiceDate: invoice.invoiceDate,
                approve: invoice.approve,
                paymentType: invoice.paymentType,
                status: invoice.status,
                total: invoice.total,
                dueDate: invoice.dueDate,
                expiryDate: invoice.expiryDate,
              );
            },
          ),
        ),
      ],
    );
  }
}

class InvoiceData {
  final String customerName;
  final String invoiceNumber;
  final String invoiceDate;
  final String approve;
  final String paymentType;
  final String status;
  final String total;
  final String dueDate;
  final String expiryDate;

  InvoiceData(this.customerName, this.invoiceNumber, this.invoiceDate, this.approve, this.paymentType, this.status, this.total, this.dueDate, this.expiryDate);
}

class _InvoiceCard extends StatefulWidget {
  final String customerName;
  final String invoiceNumber;
  final String invoiceDate;
  final String approve;
  final String paymentType;
  final String status;
  final String total;
  final String dueDate;
  final String expiryDate;

  const _InvoiceCard({
    super.key,
    required this.customerName,
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.approve,
    required this.paymentType,
    required this.status,
    required this.total,
    required this.dueDate,
    required this.expiryDate,
  });

  @override
  _InvoiceCardState createState() => _InvoiceCardState();
}

class _InvoiceCardState extends State<_InvoiceCard> {
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Customer name:'), // Left-aligned
                  Text(widget.customerName), // Right-aligned
                ],
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Invoice N°:'), // Left-aligned
                  Text(widget.invoiceNumber), // Right-aligned
                ],
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Invoice Date:'), // Left-aligned
                  Text(widget.invoiceDate), // Right-aligned
                ],
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Approve:'), // Left-aligned
                  widget.approve == 'Access'
                      ? ElevatedButton(
                          onPressed: () {
                            // Define the action to perform when the button is pressed
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue, // Set the button color to blue
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8), // Optional: Add rounded corners
                            ),
                          ),
                          child: Text(
                            widget.approve,
                            style: const TextStyle(
                              // fontWeight: FontWeight.bold, // Set text weight to bold
                              color: Colors.white, // Set text color to white
                            ),
                          ),
                        )
                      : Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: widget.approve == 'No Access' ? Colors.yellow : Colors.blue,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            widget.approve,
                            style: TextStyle(
                              // fontWeight: FontWeight.bold, // Set text weight to bold
                              color: widget.approve == 'No Access' ? Colors.black : const Color.fromARGB(255, 223, 250, 224),
                            ),
                          ),
                        ),
                ],
              ),

              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Payment type:'), // Left-aligned
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: widget.paymentType == 'Fixed' ? Colors.purpleAccent : Colors.greenAccent, // Purple for "Fixed", green for "Flexible"
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      widget.paymentType, // Right-aligned
                      style: TextStyle(
                        color: widget.paymentType == 'Fixed' ? Colors.white : Colors.black, // White text for "Fixed", black for "Flexible"
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Status:'), // Left-aligned
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: widget.status == 'Active' ? Colors.blueAccent : Colors.redAccent, // Blue for "Active", red for "No Active"
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      widget.status, // Right-aligned
                      style: TextStyle(
                        color: widget.status == 'Active' ? Colors.white : Colors.white, // White for both "Active" and "No Active"
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total:'), // Left-aligned
                  Text(widget.total), // Right-aligned
                ],
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Due Date:'), // Left-aligned
                  Text(widget.dueDate), // Right-aligned
                ],
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Expiry Date:'), // Left-aligned
                  Text(widget.expiryDate), // Right-aligned
                ],
              ),
              const SizedBox(height: 5),
              if (_isExpanded) ...[
                const SizedBox(height: 10),
                const Divider(),
                Row(
                  children: [
                    const Text('Actions'),
                    IconButton(
                      icon: const Icon(Icons.visibility),
                      onPressed: () {
                        // Action for viewing control number details
                      },
                    ),
                    // Add other action icons
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        // Action for editing
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.cancel),
                      onPressed: () {
                        // Action for cancelling
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.download),
                      onPressed: () {
                        // Action for downloading
                      },
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}





