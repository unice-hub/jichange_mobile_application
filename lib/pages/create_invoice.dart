// import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:learingdart/core/api/endpoint_api.dart';
import 'package:learingdart/core/api/invoice_apis.dart';
import 'package:learingdart/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';
import 'dart:developer';


class CreateInvoicePage extends StatefulWidget {
  const CreateInvoicePage({super.key});

  @override
  _CreateInvoicePageState createState() => _CreateInvoicePageState();
}

class _CreateInvoicePageState extends State<CreateInvoicePage> {
  String searchQuery = "";
  String _token = 'Not logged in';
  int compid = 0;
  bool isLoading = true;

  String? selectedCustomer;
  String? selectedPaymentType;
  String? selectedCurrency;
  DateTime? invoiceDate;
  DateTime? dueDate;
  DateTime? expiryDate;
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController unitPriceController = TextEditingController();
  double totalPrice = 0;
  int cusMasSno = -1;

  // List to hold added items
  List<Map<String, dynamic>> addedItems = [];

  // Sample customer list
  List<dynamic> customers = [];
  List<String> paymentTypes = ['Fixed', 'Flexible'];
  List<String> currency = [];

  TextEditingController invoiceNumberController = TextEditingController();
  TextEditingController remarks = TextEditingController();
  String? invoiceErrorMessage;

  @override
  void initState() {
    super.initState();
    _loadSessionInfo();

     // Add a listener to the invoice number field to check if it exists
    invoiceNumberController.addListener(() {
      String invno = invoiceNumberController.text;
      if (invno.isNotEmpty) {
        _isExistInvoice(compid.toString(), invno);
      }
    });
  }

  Future<void> _loadSessionInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('token') ?? 'Not logged in';
      compid = prefs.getInt('instID')?? 0;
    });
    _fetchCustomerName();
    _fetchCurrency();
    // _isExistInvoice(compid, invno);
  }
  
  Future<void> _fetchCustomerName() async {
    const url = ApiEndpoints.customerName;

    try {
       final prefs = await SharedPreferences.getInstance();
        int instituteID = prefs.getInt('instID') ?? 0;
        int userID = prefs.getInt('userID') ?? 0;
        
        log(userID.toString());

        final response = await http.post(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $_token',
          },
          body: jsonEncode({"compid": instituteID}),
        );

        if (response.statusCode == 200) {
          final jsonResponse = json.decode(response.body);
          
          //customers = customerName.map((branch) => branch['Customer_Name'] ['Cus_Mas_Sno'] as String).toList();
          
          setState(() {
             customers = jsonResponse['response'];
            isLoading = false;
          });
          
        } else {
          throw Exception('Failed to load branches');
        }
      } catch (e) {
        if (e is http.ClientException) {
          // Network error
          _showErrorDialog('Network error. Please check your connection and try again.');

        } else {
          // Other exceptions
          _showErrorDialog('An unexpected error occurred. Please try again.');
          
        }
      setState(() {
        isLoading = false;
      });
      // Handle error (show a message to the user, etc.)
      // print('Error fetching branches: $e');
    }
  }

  Future<void> _fetchCurrency() async {
    const url = ApiEndpoints.getCurrency;

    try {
       final prefs = await SharedPreferences.getInstance();
        // int instituteID = prefs.getInt('instID') ?? 0;
        int userID = prefs.getInt('userID') ?? 0;
        
        log(userID.toString());

        final response = await http.get(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $_token',
          },
          // body: jsonEncode({"compid": instituteID}),
        );

        if (response.statusCode == 200) {
          final jsonResponse = json.decode(response.body);
          final List<dynamic> currencyCode = jsonResponse['response'];
          setState(() {
             currency = currencyCode.map((branch) => branch['Currency_Code'] as String).toList();
            isLoading = false;
          });
          
        } else {
          throw Exception('Failed to load branches');
        }
      } catch (e) {
        if (e is http.ClientException) {
          // Network error
          _showErrorDialog('Network error. Please check your connection and try again.');

        } else {
          // Other exceptions
          _showErrorDialog('An unexpected error occurred. Please try again.');
          
        }
      setState(() {
        isLoading = false;
      });
      // Handle error (show a message to the user, etc.)
      // print('Error fetching branches: $e');
    }
  }

  Future<Map<String,dynamic>> isExistInvoice(String compid, String invno) async {
    return await InvoiceApis.isExistInvoice.sendRequest(urlParam: '?compid=$compid&invno=$invno');
  }


  Future<void> _isExistInvoice(String compid, String invno) async {
    //  final prefs = await SharedPreferences.getInstance();
    //final getchDetails = await InvoiceApis.getchDetails.sendRequest(body: body);
    // Base URL of the API
    // const String baseUrl = 'http://192.168.100.50:98/api/Invoice/IsExistInvoice';

    // Constructing the full URL with query parameters
    //String url = '$baseUrl?compid=$compid&invno=$invno';

    try {
        // Sending the GET request
        // final response = await http.get(
        //   Uri.parse(url),
        //   headers: {
        //     'Content-Type': 'application/json',
        //     'Accept': 'application/pdf',
        //     'Authorization': 'Bearer $_token',
        //   },
        // );

        // Handling the response
          //final responseBody = jsonDecode(response.body);
          final exists = await isExistInvoice(compid,invno);

          // Checking if the "response" field is true or false
          if (exists['response'] == true) {
            setState(() {
              invoiceErrorMessage = 'Invoice number already exists'; // Display the error
            });
          } else {
            setState(() {
              invoiceErrorMessage = null; // No error message as invoice does not exist
            });

        }
    } catch (e) {
       if (e is http.ClientException) {
          // Network error
          _showErrorDialog('Network error. Please check your connection and try again.');

        } else {
          // Other exceptions
          _showErrorDialog('An unexpected error occurred. Please try again.');
          
        }
        setState(() {
        isLoading = false;
      });
    }
  }

//API to add new customer
 Future<void> _addCustomerAPI(String name, String email, String mobile) async {
    const url = ApiEndpoints.addCustomer;
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
           final Map<String, dynamic> responseBody = jsonDecode(response.body);
          if (responseBody['response'] == 0) {
           // Extract the message from the "message" array
            String errorMessage = responseBody['message'].isNotEmpty
                ? responseBody['message'][0]
                : 'An error occurred'; // Default message if empty

            _showQuickAlert(context, 'Error', errorMessage, true);
          } else {
            // Handle success
            _showQuickAlert(context, 'Success', 'Customer added successfully', true);
            _loadSessionInfo();
          }

        } else {
          // Handle error response
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add customer: ${response.body}')),
          );
        }
      } catch (e) {

        if (e is http.ClientException) {
          // Network error
          _showErrorDialog('Network error. Please check your connection and try again.');

        } else {
          // Other exceptions
          _showErrorDialog('An unexpected error occurred. Please try again.');
          
        }
        setState(() {
        isLoading = false;
      });
      }
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

  void _showConfirmationDialog1(BuildContext context, String name, String email, String mobile) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Add Customer'),
        content: const Text('Are you sure you want to add this customer?'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
              _loadSessionInfo();
            },
            child: const Text('CLOSE'),
          ),
          
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
              _addCustomerAPI(name, email, mobile); // Call API to add customer
              _loadSessionInfo();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'CONFIRM',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      );
    },
  );
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
                      'Add new customer',
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
                        labelText: 'Email(Optional)',
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

                      // if (email.isEmpty || !emailRegex.hasMatch(email)) {
                      //   setState(() {
                      //   emailError = 'Please enter a valid email address';
                      //   });
                      //   isValid = false;
                      // }

                      if (mobile.isEmpty || !mobileRegex.hasMatch(mobile)) {
                        setState(() {
                        mobileError = 'Please enter a valid mobile number';
                        });
                        isValid = false;
                      }

                      // If all fields are valid, proceed with the action
                      if (isValid) {
                        _addCustomerAPI(name, email, mobile).then((_) {
                        
                        _showQuickAlert(context, 'Success', 'Customer added successfully', true);
                        _loadSessionInfo();
                        });
                      }
                      Navigator.pop(context); // Close the bottom sheet
                      },
                      style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      ),
                      child: const Text(
                      'Add Customer',
                      style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              )
            ),
          );
        },
      );
    },
  );
}


  // Show error dialog in case of failure
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Function to validate inputs
  bool _validateInputs() {
    if (invoiceNumberController.text.isEmpty ||
        invoiceDate == null ||
        dueDate == null ||
        expiryDate == null ||
        selectedCustomer == null ||
        selectedPaymentType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return false;
    }

    if (addedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one item to submit.')),
      );
      return false;
    }

    return true;
  }

  // Function to show confirmation dialog
  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm'),
        content: const Text('Save changes?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CLOSE'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
              _submitInvoice();
            },
            style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'CONFIRM',
            style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // Function to submit the invoice
  Future<void> _submitInvoice() async {
    if (!_validateInputs()) return;

    final prefs = await SharedPreferences.getInstance();
    final int userId = prefs.getInt('userID') ?? 0;
    final int instituteID = prefs.getInt('instID') ?? 0;

     if (invoiceDate == null || dueDate == null || expiryDate == null) {
      // Handle null dates if necessary
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all the date fields.')),
      );
      return;
    }

  // Calculate total invoice amount
  final double totalAmount = addedItems.fold(0.0, (sum, item) => sum + item['total']);
  log(totalAmount.toString());

    // Preparing the data for API call
    final Map<String, dynamic> invoiceData = {
      'userid': userId,
      'vtamou': 0,
      'compid': instituteID,
      'invno': invoiceNumberController.text,
      'auname': totalAmount.toString(), // Example data, adjust as needed
      'date': invoiceDate!.toIso8601String(),
      'edate': dueDate!.toIso8601String(),
      'iedate': expiryDate!.toIso8601String(),
      'lastrow': 0,
      'ptype': selectedPaymentType,
      'sno': 0,
      'chus': cusMasSno, // Example customer number
      'ccode': selectedCurrency,
      'total': totalAmount.toString(),
      'twvat': 0,
      'details': addedItems.map((item) {
        return {
          'Item_Description': item['description'],
          'Item_Qty': item['quantity'],
          'Item_Unit_Price': item['unitPrice'],
          'Item_Total_Amount': item['total'],
          'remarks': "",
          // Add other necessary fields
        };
      }).toList(),
      'Inv_remark': '', // Example, adjust as needed
    };

    const url = ApiEndpoints.addInvoice;
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode(invoiceData),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invoice submitted successfully!')),
        );
        // Navigate to MainPage with created invoice tab as the initial tab
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const HomePage(initialIndex: 3),
          ),
          (route) => false,
        );
        
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to submit invoice.')),
        );
      }
    } catch (e) {
       if (e is http.ClientException) {
          // Network error
          _showErrorDialog('Network error. Please check your connection and try again.');

        } else {
          // Other exceptions
          _showErrorDialog('An unexpected error occurred. Please try again.');
          
        }
      setState(() {
        isLoading = false;
      });
    }
  }

  // Button to trigger validation and confirmation
  void _onSubmitButtonPressed() {
    if (_validateInputs()) {
      _showConfirmationDialog();
    }
  }



  Future<void> _selectDate(BuildContext context, bool isInvoiceDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),//Minimum date
      lastDate: DateTime(2101),//Maximum date
      
    );

    if (picked != null) {
      setState(() {
        if (isInvoiceDate) {
          invoiceDate = picked;
          // Ensure dueDate is not earlier than invoiceDate
          if (dueDate != null && dueDate!.isBefore(invoiceDate!)) {
            dueDate = invoiceDate;
          }
          // Ensure expiryDate is not earlier than invoiceDate
          if (expiryDate != null && expiryDate!.isBefore(invoiceDate!)) {
            expiryDate = invoiceDate;
          }
        } else {
          // Ensure dueDate is not earlier than invoiceDate
          if (invoiceDate != null && picked.isBefore(invoiceDate!)) {
            invoiceErrorMessage = 'Due date cannot be earlier than invoice date';
          } else {
            dueDate = picked;
            invoiceErrorMessage = null;
          }
        }
      });
    }
  }

  Future<void> _selectExpiryDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );


    if (picked != null) {
      setState(() {
        // Ensure expiryDate is not earlier than invoiceDate or dueDate
        if ((invoiceDate != null && picked.isBefore(invoiceDate!)) ||
            (dueDate != null && picked.isBefore(dueDate!))) {
          invoiceErrorMessage = 'Expiry date cannot be earlier than invoice date or due date';
        } else {
          expiryDate = picked;
          invoiceErrorMessage = null;
        }
      });
    }
  }

  void calculateTotalPrice() {
    final quantity = double.tryParse(quantityController.text) ?? 0;
    final unitPrice = double.tryParse(unitPriceController.text) ?? 0;
    setState(() {
      totalPrice = quantity * unitPrice;
    });
  }

   // Calculate the total of all added items
  double calculateTotalOfAllItems() {
    return addedItems.fold(0, (sum, item) => sum + item['total']);
  }

  void addItem() {
    final description = descriptionController.text;
    final quantity = double.tryParse(quantityController.text) ?? 0;
    final unitPrice = double.tryParse(unitPriceController.text) ?? 0;
    final total = quantity * unitPrice;

    if (description.isNotEmpty && quantity > 0 && unitPrice > 0) {
      setState(() {
        addedItems.add({
          'description': description,
          'quantity': quantity,
          'unitPrice': unitPrice,
          'total': total,
        });

        // Clear input fields
        descriptionController.clear();
        quantityController.clear();
        unitPriceController.clear();
        totalPrice = 0;
      });
    } else {
      // Show an error or warning for invalid inputs
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields with valid data')),
      );
    }
  }

  void submitInvoice() {
    if (addedItems.isNotEmpty) {
      // Perform your submission logic here
      // For example, making an API call to submit the invoice data
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invoice submitted successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one item to submit.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###.##');
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Theme.of(context).colorScheme.surface // Dark mode
          : Theme.of(context).colorScheme.primary, // Light mode
        title: const Text('Create Invoice', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        // backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
             TextField(
              controller: invoiceNumberController,
              decoration: const InputDecoration(
                labelText: 'Invoice number',
                border: OutlineInputBorder(),
                hintText: 'Enter invoice number',
                // errorText: invoiceErrorMessage,// Display error message
              ),
            ),
            if (invoiceErrorMessage != null) 
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  invoiceErrorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            const SizedBox(height: 16),

            InkWell(
              onTap: () => _selectDate(context, true),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Invoice Date',
                  suffixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  invoiceDate == null ? 'Choose a date' : invoiceDate!.toLocal().toString().split(' ')[0],
                ),
              ),
            ),
            const SizedBox(height: 16),

            InkWell(
              onTap: () => _selectDate(context, false),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Invoice Due Date',
                  suffixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  dueDate == null ? 'Choose a date' : dueDate!.toLocal().toString().split(' ')[0],
                ),
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () => _selectExpiryDate(context),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Invoice Expiry Date',
                  suffixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  expiryDate == null ? 'Choose a date' : expiryDate!.toLocal().toString().split(' ')[0],
                ),
              ),
            ),
            const SizedBox(height: 16),

            isLoading
            ? const Center(child: CircularProgressIndicator())

            : DropdownButtonFormField<String>(
              value: selectedCustomer,
              isExpanded: true,
              hint: const Text('Select Customer'),
              items: customers.map((dynamic value) {
                return DropdownMenuItem<String>(
                  value: value['Cus_Mas_Sno'].toString(),
                  onTap: () => {cusMasSno = value['Cus_Mas_Sno']},
                  child: Text(value['Customer_Name'], overflow: TextOverflow.ellipsis),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedCustomer = newValue;
                });
              },
                decoration: InputDecoration(
                      labelText: 'Customer',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          // Add action for the add button
                          _showAddCustomerSheet(context);
                          // You can navigate to a page to add a customer or show a dialog
                        },
                      ),
                    ),
                  ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: selectedPaymentType,
              isExpanded: true,
              hint: const Text('Select payment type'),
              items: paymentTypes.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, overflow: TextOverflow.ellipsis),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedPaymentType = newValue;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Payment type',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            
            isLoading
            ? const Center(child: CircularProgressIndicator())
            : DropdownButtonFormField<String>(

              value: selectedCurrency,
              isExpanded: true,
              hint: const Text('Select a currency'),
              items: currency.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, overflow: TextOverflow.ellipsis),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedCurrency = newValue;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Currency',
                border: OutlineInputBorder(),
              ),
            ),
            
            const SizedBox(height: 16),

            TextField(
              controller: remarks,
              decoration: const InputDecoration(
                labelText: 'Invoice remarks (Optional)',
                border: OutlineInputBorder(),
                hintText: 'Enter invoice remarks',
              ),
            ),
            const SizedBox(height: 16),

            const Divider(),
            const Text(
              'Item Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: addItem,
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    'ADD', 
                    style: TextStyle(color: Colors.white),
                    ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(0, 158, 96, 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: quantityController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
               FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                   ],
                    decoration: const InputDecoration(
                      labelText: 'Quantity',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => calculateTotalPrice(),
                  ),
                ),
                const SizedBox(width: 16),
                
                Expanded(
                  child: TextField(
                    controller: unitPriceController,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Unit Price',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => calculateTotalPrice(),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Total price: $totalPrice',
                // 'Total price: ${formatter.format(totalPrice)}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),

            // Display the added items
            const Divider(),
            const Text(
              'Added Items',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            ListView.builder(
              shrinkWrap: true, // Ensure it doesn't scroll separately
              itemCount: addedItems.length,
              itemBuilder: (context, index) {
                final item = addedItems[index];
                return Card(
                  child: ListTile(
                    title: Text(item['description']),
                    subtitle: Text(
                      'Quantity: ${formatter.format(item['quantity'])} | '
                      'Unit Price: ${formatter.format(item['unitPrice'])} | '
                      'Total: ${formatter.format(item['total'])}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () {
                        setState(() {
                          addedItems.removeAt(index);
                        });
                      },
                    ),
                  ),
                );
              },
            ),

          // Show total of all added items
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Total of all items: ${formatter.format(calculateTotalOfAllItems())}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
         
            // Submit button
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _onSubmitButtonPressed,
              
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                minimumSize: const Size(double.infinity, 48),
                
              ),
              child: const Text('Submit', style: TextStyle(color: Colors.white)),
              
            ),
          ],
        ),
      ),
    );
  }
}






