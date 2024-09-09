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

  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final filteredCustomers = customers.where((customer) {
      return customer.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          customer.email.toLowerCase().contains(searchQuery.toLowerCase()) ||
          customer.mobileNumber.contains(searchQuery);
    }).toList();

    return Scaffold(
      resizeToAvoidBottomInset: true, // Ensures content adjusts when the keyboard appears
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus(); // Dismiss the keyboard when tapping outside
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              bottom: MediaQuery.of(context).viewInsets.bottom, // Adjust for the keyboard
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Search by name, email, or phone number',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8.0),
                filteredCustomers.isEmpty
                    ? const Center(child: Text("No customers found"))
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(), // Disable scrolling inside the list
                        itemCount: filteredCustomers.length,
                        itemBuilder: (context, index) {
                          return _buildCustomerCard(filteredCustomers[index]);
                        },
                      ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddCustomerSheet(context);
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCustomerCard(Customer customer) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        title: Text(customer.name, style: Theme.of(context).textTheme.titleLarge),
        subtitle: Text(customer.email, style: Theme.of(context).textTheme.bodyMedium),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Text(
            customer.name[0].toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(Icons.email, 'Email', customer.email),
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
                        _showEditCustomerSheet(context, customer);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
                      onPressed: () {
                        _confirmDeleteCustomer(context, customer);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
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

  void _showAddCustomerSheet(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final mobileController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows the sheet to expand when the keyboard appears
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom, // Adjust for keyboard
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'Add New Customer',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16.0),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  TextField(
                    controller: mobileController,
                    decoration: InputDecoration(
                      labelText: 'Mobile Number',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      if (nameController.text.isNotEmpty &&
                          emailController.text.isNotEmpty &&
                          mobileController.text.isNotEmpty) {
                        setState(() {
                          customers.add(Customer(
                            nameController.text,
                            emailController.text,
                            mobileController.text,
                          ));
                        });
                        Navigator.pop(context); // Close the bottom sheet
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('All fields are required')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                    ),
                    child: const Text('Add Customer'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showEditCustomerSheet(BuildContext context, Customer customer) {
    final nameController = TextEditingController(text: customer.name);
    final emailController = TextEditingController(text: customer.email);
    final mobileController = TextEditingController(text: customer.mobileNumber);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows the sheet to expand when the keyboard appears
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom, // Adjust for keyboard
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'Edit Customer',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16.0),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  TextField(
                    controller: mobileController,
                    decoration: InputDecoration(
                      labelText: 'Mobile Number',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        customer.name = nameController.text;
                        customer.email = emailController.text;
                        customer.mobileNumber = mobileController.text;
                      });
                      Navigator.pop(context); // Close the bottom sheet
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                    ),
                    child: const Text('Save Changes'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _confirmDeleteCustomer(BuildContext context, Customer customer) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Customer'),
          content: Text('Are you sure you want to delete ${customer.name}?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  customers.remove(customer);
                });
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}

class Customer {
  String name;
  String email;
  String mobileNumber;

  Customer(this.name, this.email, this.mobileNumber);
}
