import 'package:flutter/material.dart';

class InvoicesSection extends StatelessWidget {
  const InvoicesSection({super.key});

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
        body: const TabBarView(
          children: [
            Center(child: Text('Created Invoice Content', style: TextStyle(fontSize: 24.0))),
            Center(child: Text('Generated Invoice Content', style: TextStyle(fontSize: 24.0))),
          ],
        ),
      ),
    );
  }
}
