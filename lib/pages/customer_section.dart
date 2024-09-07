import 'package:flutter/material.dart';

class CustomerSection extends StatefulWidget {
  const CustomerSection({super.key});

  @override
  _CustomerSectionState createState() => _CustomerSectionState();
}

class _CustomerSectionState extends State<CustomerSection> {
  final List<Customer> customers = [
    Customer('Emmanuel', 'emmz56@yahoo.com', '255655443454'),
    Customer('Mininos', 'koydorikigufum.com', '255800010022'),
    Customer('Wang Ones', 'faimayurdi@gufum.com', '25580020010'),
    Customer('Jackie Jackies', '255800800814', '255800800814'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Customer Section'),
      // ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: customers.length,
        itemBuilder: (context, index) {
          return _buildCustomerCard(customers[index]);
        },
      ),
    );
  }

  

  Widget _buildCustomerCard(Customer customer) {
    return ExpansionTile(
      title: Text(customer.name, style: Theme.of(context).textTheme.titleLarge),
      subtitle: Text(customer.email, style: Theme.of(context).textTheme.bodyMedium),
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Text(customer.name[0]), // First letter of customer name
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow(Icons.email, 'Email Address', customer.email),
              const SizedBox(height: 8.0),
              _buildInfoRow(Icons.phone, 'Mobile Number', customer.mobileNumber),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: Icon(Icons.remove_red_eye_outlined, color: Theme.of(context).colorScheme.primary),
                    onPressed: () {
                      // Handle view action
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.edit, color: Theme.of(context).colorScheme.primary),
                    onPressed: () {
                      // Handle edit action
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
                    onPressed: () {
                      // Handle delete action
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8.0),
        Text('$label: $value', style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }
}

class Customer {
  final String name;
  final String email;
  final String mobileNumber;

  Customer(this.name, this.email, this.mobileNumber);
}
