import 'package:flutter/material.dart';
import 'invoices_tabs/created_invoice_tab.dart';
import 'invoices_tabs/generated_invoice_tab.dart';

class InvoicesSection extends StatefulWidget {
  const InvoicesSection({super.key});

  @override
  _InvoicesSectionState createState() => _InvoicesSectionState();
}

class _InvoicesSectionState extends State<InvoicesSection> {
  final List<Invoice> createdInvoices = [
    // Invoice data
  ];

  final List<Invoice> generatedInvoices = [
    // Invoice data
  ];

  List<Invoice> filteredInvoices = [];
  List<Invoice> filteredGeneratedInvoices = [];

  @override
  void initState() {
    super.initState();
    filteredInvoices = createdInvoices;
    filteredGeneratedInvoices = generatedInvoices;
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
              createdInvoices: filteredInvoices,
              filterCreatedInvoices: _filterCreatedInvoices,
            ),
            GeneratedInvoiceTab(
              generatedInvoices: filteredGeneratedInvoices,
              filterGeneratedInvoices: _filterGeneratedInvoices,
            ),
          ],
        ),
      ),
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

  Invoice(
    this.customerName,
    this.invoiceNumber,
    this.invoiceDate,
    this.total,
    this.paymentType,
    this.dueDate,
    this.expiryDate,
  );
}
