import 'package:flutter/material.dart';
import 'package:learingdart/pages/report_category/overview_page.dart';
import 'package:learingdart/pages/report_category/payment_details_page.dart';
import 'package:learingdart/pages/report_category/invoice_details_page.dart';
import 'package:learingdart/pages/report_category/completed_payments_page.dart';
import 'package:learingdart/pages/report_category/amendments_details_page.dart';
import 'package:learingdart/pages/report_category/cancelled_invoice_page.dart';
import 'package:learingdart/pages/report_category/audit_trails_page.dart';

class ReportsSection extends StatelessWidget {
  const ReportsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      padding: const EdgeInsets.all(16.0),
      crossAxisSpacing: 16.0,
      mainAxisSpacing: 16.0,
      children: <Widget>[
        _buildReportCard(
          context,
          Icons.dashboard,
          'Overview',
          const OverviewPage(),
        ),
        _buildReportCard(
          context,
          Icons.payment,
          'Payment Details',
          const PaymentDetailsPage(),
        ),
        _buildReportCard(
          context,
          Icons.receipt_long,
          'Invoice Details',
          const InvoiceDetailsPage(),
        ),
        _buildReportCard(
          context,
          Icons.check_circle_outline,
          'Completed Payments',
          const CompletedPaymentsPage(),
        ),
        _buildReportCard(
          context,
          Icons.edit,
          'Amendments Details',
          const AmendmentsDetailsPage(),
        ),
        _buildReportCard(
          context,
          Icons.cancel,
          'Cancelled Invoice',
          const CancelledInvoicePage(),
        ),
        _buildReportCard(
          context,
          Icons.fact_check,
          'Audit Trails',
          const AuditTrailsPage(),
        ),
      ],
    );
  }

  Widget _buildReportCard(BuildContext context, IconData icon, String title, Widget page) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        elevation: 4.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 48.0, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16.0),
            Center(
              child: Text(
                title,
                style: const TextStyle(fontSize: 18.0),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
