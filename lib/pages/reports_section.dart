import 'package:flutter/material.dart';


class ReportsSection extends StatelessWidget {
  const ReportsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      padding: EdgeInsets.all(16.0),
      crossAxisSpacing: 16.0,
      mainAxisSpacing: 16.0,
      children: <Widget>[
        _buildReportCard(
          context,
          Icons.dashboard,
          'Overview',
          OverviewPage(),
        ),
        _buildReportCard(
          context,
          Icons.payment,
          'Payment Details',
          PaymentDetailsPage(),
        ),
        _buildReportCard(
          context,
          Icons.receipt_long,
          'Invoice Details',
          InvoiceDetailsPage(),
        ),
        _buildReportCard(
          context,
          Icons.check_circle_outline,
          'Completed Payments',
          CompletedPaymentsPage(),
        ),
        _buildReportCard(
          context,
          Icons.edit,
          'Amendments Details',
          AmendmentsDetailsPage(),
        ),
        _buildReportCard(
          context,
          Icons.cancel,
          'Cancelled Invoice',
          CancelledInvoicePage(),
        
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
            SizedBox(height: 16.0),
            Center(  // Center-align the text
              child: Text(
                title,
                style: TextStyle(fontSize: 18.0),
                textAlign: TextAlign.center,  // Ensures text is center-aligned within the Center widget
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Placeholder pages for each report category
class OverviewPage extends StatelessWidget {
  const OverviewPage({super.key});
  
   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Overview'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Text(
          'Overview Content',
          style: TextStyle(fontSize: 24.0),
          ),
      ),
    );
  }
}

class PaymentDetailsPage extends StatelessWidget {
  const PaymentDetailsPage({super.key});

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(title: Text('Payment Details')),
  //     body: Center(child: Text('Payment Details Content')),
  //   );
  // }

    @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Details'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Text(
          'Payment Details Content',
           style: TextStyle(fontSize: 24.0),),
      ),
    );
  }

}

class InvoiceDetailsPage extends StatelessWidget {
  const InvoiceDetailsPage({super.key});

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(title: Text('Invoice Details')),
  //     body: Center(child: Text('Invoice Details Content')),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Invoice Details'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Text(
          'Invoice Details Content',
           style: TextStyle(fontSize: 24.0),
           ),
      ),
    );
  }  
}

class CompletedPaymentsPage extends StatelessWidget {
  const CompletedPaymentsPage({super.key});

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(title: Text('Completed Payments')),
  //     body: Center(child: Text('Completed Payments Content')),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Completed Payments'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Text(
          'Completed Payments Content',
           style: TextStyle(fontSize: 24.0),
           ),
      ),
    );
  }
}

class AmendmentsDetailsPage extends StatelessWidget {
  const AmendmentsDetailsPage({super.key});

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(title: Text('Amendments Details')),
  //     body: Center(child: Text('Amendments Details Content')),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Amendments Details'
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Text(
          'Amendments Details Content', 
          style: TextStyle(fontSize: 24.0),
          ),
      ),
    );
  }
}

class CancelledInvoicePage extends StatelessWidget {
  const CancelledInvoicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Cancelled Invoice',
          style: const TextStyle(color: Colors.white),
        ),
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
      body: Center(
        child: Text(
          'Cancelled Invoice Content',
          style: TextStyle(fontSize: 24.0),
        ),
        
      ),
    );
  }
}
