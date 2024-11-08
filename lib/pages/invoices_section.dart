import 'package:flutter/material.dart';
import 'invoices_tabs/created_invoice_tab.dart';
import 'invoices_tabs/generated_invoice_tab.dart';

class InvoicesSection extends StatefulWidget {
  const InvoicesSection({super.key});

  @override
  _InvoicesSectionState createState() => _InvoicesSectionState();

  static void navigateToHome(BuildContext context) {}
}

class _InvoicesSectionState extends State<InvoicesSection> {
  // final List<Invoice> createdInvoices = [
  //   // Sample Invoice Data
   
  // ];

  // final List<Invoice> generatedInvoices = [
  //   // Sample Invoice Data
    
  // ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const TabBar(
            tabs: [
              Tab(text: 'Created Invoice'),
              Tab(text: 'Generated Invoice'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            CreatedInvoiceTab(
              // createdInvoices: createdInvoices, filteredCreatedInvoices: const [],
            ),
            GeneratedInvoiceTab(
              // generatedInvoices: generatedInvoices, filterGeneratedInvoices: const [],
            ),
          ],
        ),
      ),
    );
  }
}

// class Invoice {
//   final String customerName;
//   final String invoiceNumber;
//   final String invoiceDate;
//   final String total;
//   final String paymentType;
//   final String dueDate;
//   final String expiryDate;

//   Invoice(
//     this.customerName,
//     this.invoiceNumber,
//     this.invoiceDate,
//     this.total,
//     this.paymentType,
//     this.dueDate,
//     this.expiryDate,
//   );
// }
