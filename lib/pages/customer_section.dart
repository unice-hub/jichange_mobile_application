import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class CustomerSection extends StatefulWidget {
  const CustomerSection({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CustomerSectionState createState() => _CustomerSectionState();
}

class _CustomerSectionState extends State<CustomerSection> {
  List<Customer> customers = [];
  String searchQuery = "";
  String _token = 'Not logged in';
  int _userID = 0;
  int _instID = 0;
  String _braid = 'sksc';
  String _userName = 'Unknown';
  bool isLoading = true; // To show loading indicator while fetching data
  
  @override
  void initState() {
    super.initState();
    _loadSessionInfo();
    _fetchCustomerData();
  }

  // Method to load all session data from SharedPreferences
  Future<void> _loadSessionInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('token') ?? 'Not logged in';
      _userID = prefs.getInt('userID') ?? 0;
      _instID = prefs.getInt('instID') ?? 0;
      _userName = prefs.getString('userName') ?? 'Unknown';
      _braid = prefs.getString('ubraid') ?? 'Unknown';
    });
  }

  // Method to fetch customer data from the API
Future<void> _fetchCustomerData() async {
  const url = 'http://192.168.100.50:98/api/RepCustomer/GetcustDetReport';
  try {    
    final prefs = await SharedPreferences.getInstance();
    int instituteID = prefs.getInt('instID') ?? 0;
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $_token' // Ensure _token is initialized properly
      },
      body: jsonEncode({"vendors": instituteID}),
    );

    log(response.statusCode.toString());
    log(response.body);

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);

      // Check if 'response' exists and is a list
      if (responseBody['response'] is List) {
        final List<dynamic> responseList = responseBody['response'];

        setState(() {
          customers = responseList.map((item) => Customer.fromJson(item)).toList();
          isLoading = false; // Data is fetched, hide loading indicator
        });
      } else {
        // Handle unexpected data format
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unexpected data format')),
        );
      }
    } else {
      // Handle error response from the server
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Failed to fetch customer data')),
      );
    }
  } catch (e) {
    // Handle any other errors
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
}



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
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filteredCustomers.isEmpty
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
    // Code for adding customer (if needed)
  }

  void _showEditCustomerSheet(BuildContext context, Customer customer) {
    // Code for editing customer (if needed)
  }

  void _confirmDeleteCustomer(BuildContext context, Customer customer) {
    // Code for confirming delete (if needed)
  }
}

// Model class for Customer
class Customer {
  final int id;
  final String name;
  final String email;
  final String mobileNumber;

  Customer({
    required this.id,
    required this.name,
    required this.email,
    required this.mobileNumber,
  });

  // Factory method to create a Customer object from JSON
  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['Cust_Sno'],
      name: json['Cust_Name'] ?? 'N/A',
      email: json['Email'] ?? 'N/A',
      mobileNumber: json['Phone'] ?? 'N/A',
    );
  }
}
