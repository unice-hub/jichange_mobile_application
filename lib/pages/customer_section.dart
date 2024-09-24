import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'customer_details.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class CustomerSection extends StatefulWidget {
  const CustomerSection({super.key});

  @override
  _CustomerSectionState createState() => _CustomerSectionState();
}

class _CustomerSectionState extends State<CustomerSection> {
  List<Customer> customers = [];
  String searchQuery = "";
  String _token = 'Not logged in';
  // int _userID = 0;
  // int _instID = 0;
  // String _braid = 'Unknown';
  // String _userName = 'Unknown';
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
      // _userID = prefs.getInt('userID') ?? 0;
      // _instID = prefs.getInt('instID') ?? 0;
      // _userName = prefs.getString('userName') ?? 'Unknown';
      // _braid = prefs.getString('ubraid') ?? 'Unknown';
    });
  }

  // Method to fetch customer data from the API
  Future<void> _fetchCustomerData() async {
    const url = 'http://192.168.100.50:98/api/RepCustomer/GetcustDetReport';
    try {
      final prefs = await SharedPreferences.getInstance();
      int instituteID = prefs.getInt('instID') ?? 0;

      // Log the request to debug the API call
      log('Making API request with token: $_token and instituteID: $instituteID');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token' // Ensure _token is initialized properly
        },
        body: jsonEncode({"vendors": [instituteID]}),
      );

      log('API Status Code: ${response.statusCode}');
      log('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);

        // Check if 'response' contains a list as expected
        if (responseBody['response'] is List) {
          setState(() {
            customers = (responseBody['response'] as List)
                .map((item) => Customer.fromJson(item))
                .toList();
            isLoading = false; // Data is fetched, hide loading indicator
          });
        } else {
          // Handle the case where the response is not a list
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Unexpected data format: response is not a list')),
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

  Future<void> _modifyCustomerAPI(Customer customer, String name, String email, String mobile) async {
    const url = 'http://192.168.100.50:98/api/Customer/AddCustomer'; 
    final prefs = await SharedPreferences.getInstance();
    int instituteID = prefs.getInt('instID') ?? 0;
    int userID = prefs.getInt('userID') ?? 0;

    final body = jsonEncode({
      "CSno": customer.id, // Use the customer ID for modification
      "compid": instituteID,
      "CName": name,
      "Mail": email,
      "Mobile_Number": mobile,
      "userid": userID
    });

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token'
        },
        body: body,
      );

      if (response.statusCode == 200) {
        // Show success dialog
        _showQuickAlert(context, 'Success', 'Customer modified successfully!', true);
        _fetchCustomerData(); // Refresh customer list
      } else {
        // Show error dialog
        _showQuickAlert(context, 'Error', 'Failed to modify customer: ${response.body}', false);
      }
    } catch (e) {
      _showQuickAlert(context, 'Error', 'Error: $e', false);
    }
  }


  Future<void> _addCustomerAPI(String name, String email, String mobile) async {
    const url = 'http://192.168.100.50:98/api/Customer/AddCustomer';
    final prefs = await SharedPreferences.getInstance();
        int instituteID = prefs.getInt('instID') ?? 0;
        int userID= prefs.getInt('userID') ?? 0;

    final body = jsonEncode({
        "CSno": 0,
        "compid": instituteID, // Replace with your actual company ID
        "CName": name,
        "PostboxNo": "",
        "Address": "",
        "regid": 0,
        "distsno": 0,
        "wardsno": 0,
        "Tinno": "",
        "VatNo": "",
        "CoPerson": "",
        "Mail": email,
        "Mobile_Number": mobile,
        "dummy": true,
        "check_status": "",
        "userid": userID
      });

      try {
        final response = await http.post(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $_token'
          },
          body: body,
        );

        if (response.statusCode == 200) {
          // Handle success response
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Customer added successfully')),
          );
          _fetchCustomerData(); // Refresh customer list
        } else {
          // Handle error response
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add customer: ${response.body}')),
          );
        }
      } catch (e) {
        // Handle any exceptions
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
                        //  Navigator.push(
                        //   // context,
                        //   // MaterialPageRoute(builder: (context) => const CustomerDetailsPage(name: 'Cust_Name', email: 'Email', mobile: 'Phone')), // Navigate to customer_details.dart
                        // );
                        _viewCustomer(customer);
                        
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

void _showConfirmationDialog(BuildContext context, String name, String email, String mobile) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Add Customer'),
        content: const Text('Are you sure you want to add this customer? Would you also like to attach an invoice to this customer?'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: const Text('CLOSE'),
          ),
          TextButton(
            onPressed: () {
              // Navigator.of(context).pop(); // Close the dialog
              // Handle attaching invoice logic
            },
            child: const Text('YES, ATTACH INVOICE'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
              _addCustomerAPI(name, email, mobile); // Call API to add customer
            },
            child: const Text('CONFIRM'),
          ),
        ],
      );
    },
  );
}

void _viewCustomer(Customer customer) async {
  // Fetch customer details from the API
  Future<Customer?> fetchCustomerDetails(int customerId) async {
    const url = 'http://192.168.100.50:98/api/Customer/GetCustbyId';
    
    // Retrieve instituteID from shared preferences
    final prefs = await SharedPreferences.getInstance();
    int instituteID = prefs.getInt('instID') ?? 0;

    // Construct request body with the institute ID and customer ID
    final body = jsonEncode({
      "compid": instituteID,
      "Sno": "$customerId",
    });

    try {
      // Make the POST request to fetch customer details
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token', // Ensure _token is defined earlier in your code
        },
        body: body,
      );

      log('API Response Body: ${response.body}'); // Log the raw response body for debugging

      if (response.statusCode == 200) {
        // Parse the response body into a Map
        
        // Use the parsed data to create a Customer object
        final data = jsonDecode(response.body);
        log('Successfully fetched customer details'); // Log success message
        return Customer.fromJson(data); 
      } else {
        // Log the failure with the response status code
        log('Failed to fetch customer details: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      // Log any exceptions that occur during the request
      log('Error fetching customer details: $e');
      return null;
    }
  }

  // Fetch customer details using the customer ID
  final customerDetails = await fetchCustomerDetails(customer.id);
  // log(customer.id.toString());
  // log(customer.email);
  // log(customer.mobileNumber);
  // log(customer.name);
  // Check if customer details were successfully retrieved
  
  if (customerDetails != true) {
    // Navigate to the CustomerDetailsPage with the retrieved details
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomerDetailsPage(
          name: customer.name,
          email: customer.email,
          mobile: customer.mobileNumber,
        ),
      ),
    );

    // Log customer details for debugging purposes
    // log("Customer name: ${customer.name}");
    // log("Customer Email: ${customer.email}");
    // log("Customer Mobile: ${customer.mobileNumber}");
  } else {
    // Show an error message if customer details couldn't be fetched
    _showQuickAlert(context, 'Error', 'Failed to load customer details', false);
  }
}


 void _showAddCustomerSheet(BuildContext context) {
  // Controllers for input fields
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final mobileController = TextEditingController();

  // Email validation regex pattern
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  // Mobile number validation regex pattern (digits only)
  final mobileRegex = RegExp(r'^\d+$');

  // State variables for error messages
  String? nameError;
  String? emailError;
  String? mobileError;

  // Use StatefulBuilder to maintain local state in the bottom sheet
  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // Allows the sheet to expand when the keyboard appears
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
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
                    
                    // Name field with validation message
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        errorText: nameError, // Show error message if nameError is not null
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    
                    // Email field with validation message
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        errorText: emailError, // Show error message if emailError is not null
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    
                    // Mobile field with validation message
                    TextField(
                      controller: mobileController,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: 'Mobile Number',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        errorText: mobileError, // Show error message if mobileError is not null
                      ),
                      keyboardType: TextInputType.phone, // Set the keyboard to number
                    ),
                    const SizedBox(height: 16.0),
                    
                    ElevatedButton(
                      onPressed: () {
                        String name = nameController.text.trim();
                        String email = emailController.text.trim();
                        String mobile = mobileController.text.trim();

                        // Reset error messages before validation
                        setState(() {
                          nameError = null;
                          emailError = null;
                          mobileError = null;
                        });

                        // Validation
                        bool isValid = true;

                        if (name.isEmpty) {
                          setState(() {
                            nameError = 'Please enter your name';
                          });
                          isValid = false;
                        }

                        if (email.isEmpty || !emailRegex.hasMatch(email)) {
                          setState(() {
                            emailError = 'Please enter a valid email address';
                          });
                          isValid = false;
                        }

                        if (mobile.isEmpty || !mobileRegex.hasMatch(mobile)) {
                          setState(() {
                            mobileError = 'Please enter a valid mobile number';
                          });
                          isValid = false;
                        }

                        // If all fields are valid, proceed with the action
                        if (isValid) {
                          _showConfirmationDialog(context, name, email, mobile);
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
    },
  );
}


  void _showEditCustomerSheet(BuildContext context, Customer customer) {
  // Controllers for input fields with initial values
  final nameController = TextEditingController(text: customer.name);
  final emailController = TextEditingController(text: customer.email);
  final mobileController = TextEditingController(text: customer.mobileNumber);

  // Email validation regex pattern
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  // Mobile number validation regex pattern (digits only)
  final mobileRegex = RegExp(r'^\d+$');

  // State variables for error messages
  String? nameError;
  String? emailError;
  String? mobileError;

  // Use StatefulBuilder to maintain local state in the bottom sheet
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
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
                    
                    // Name field with validation message
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        errorText: nameError, // Show error message if nameError is not null
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    
                    // Email field with validation message
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        errorText: emailError, // Show error message if emailError is not null
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    
                    
                    // Mobile field with validation message
                    TextField(
                      controller: mobileController,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: 'Mobile Number',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        errorText: mobileError, // Show error message if mobileError is not null
                      ),
                      keyboardType: TextInputType.phone, // Set the keyboard to number
                    ),
                    const SizedBox(height: 16.0),
                    
                    ElevatedButton(
                      onPressed: () {
                        String name = nameController.text.trim();
                        String email = emailController.text.trim();
                        String mobile = mobileController.text.trim();

                        // Reset error messages before validation
                        setState(() {
                          nameError = null;
                          emailError = null;
                          mobileError = null;
                        });

                        // Validation
                        bool isValid = true;

                        if (name.isEmpty) {
                          setState(() {
                            nameError = 'Please enter your name';
                          });
                          isValid = false;
                        }

                        if (email.isEmpty || !emailRegex.hasMatch(email)) {
                          setState(() {
                            emailError = 'Please enter a valid email address';
                          });
                          isValid = false;
                        }

                        if (mobile.isEmpty || !mobileRegex.hasMatch(mobile)) {
                          setState(() {
                            mobileError = 'Please enter a valid mobile number';
                          });
                          isValid = false;
                        }

                        // If all fields are valid, proceed with the action
                        if (isValid) {
                          _showModifyConfirmationDialog(context, customer, name, email, mobile);
                        }
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
    },
  );
}


void _showModifyConfirmationDialog(BuildContext context, Customer customer, String name, String email, String mobile) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Modify Customer'),
        content: const Text('Are you sure you want to modify this customer?'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: const Text('CLOSE'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
              _modifyCustomerAPI(customer, name, email, mobile); // Call API to modify customer
            },
            child: const Text('CONFIRM'),
          ),
        ],
      );
    },
  );
}

void _showQuickAlert(BuildContext context, String title, String message, bool isSuccess) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}


  void _confirmDeleteCustomer(BuildContext context, Customer customer) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm'),
          content: const Text('Are you sure you want to delete this customer?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('CLOSE'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _deleteCustomerAPI(customer.id); // Call the delete API
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error, // Red button for delete
              ),
              child: const Text('REMOVE'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteCustomerAPI(int custSno) async {
    const url = 'http://192.168.100.50:98/api/Customer/DeleteCust';
    final prefs = await SharedPreferences.getInstance();
    int userID = prefs.getInt('userID') ?? 0;

    final body = jsonEncode({
      "sno": custSno,
      "userid": userID,
    });

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token', // Ensure token is available
        },
        body: body,
      );

      if (response.statusCode == 200) {
        // Success: Show a success alert
        Map<String,dynamic> jsonObject = json.decode(response.body);
        log(jsonObject['response'].toString());
        if (jsonObject['response'] == 0 && jsonObject['message'].length > 0) {
          log(jsonObject["message"].toString());
          String kitu = jsonObject["message"].toString();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(kitu)),
          );
        }
        else{
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Customer deleted successfully')),
          );
        }

        _fetchCustomerData(); // Refresh the customer list
      } 
      else {
        // Failure: Show an error alert
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete customer: ${response.body}')),
        );
      }
    } catch (e) {
      // Handle exceptions
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
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
      id: json['Cust_Sno'] ?? 0,
      name: json['Cust_Name'] ?? 'Unknown',
      email: json['Email'] ?? 'Unknown',
      mobileNumber: json['Phone'] ?? 'Unknown',
    );
  }
}
