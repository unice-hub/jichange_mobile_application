
// import 'dart:ffi';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:learingdart/core/api/invoice_apis.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';
import 'dart:developer';

class EditInvoicePage extends StatefulWidget {
  final String invoiceNumber;
  final String invoiceDate;
  final String invoiceDueDate;
  final String invoiceExpiryDate;
  final String customer;
  final String paymentType;
  final String currency;

  const EditInvoicePage({
    super.key,
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.invoiceDueDate,
    required this.invoiceExpiryDate,
    required this.customer,
    required this.paymentType,
    required this.currency,
    
    });

  @override
  _EditInvoicePageState createState() => _EditInvoicePageState();
}

class _EditInvoicePageState extends State<EditInvoicePage> {
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
    _loadSessionInfo() ;

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
    const url = 'http://192.168.100.50:98/api/Invoice/GetCustomersS';

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
          customers = jsonResponse['response'];
          
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
    const url = 'http://192.168.100.50:98/api/Invoice/GetCurrency';

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

  try {
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
    setState(() {
      invoiceErrorMessage = 'Error checking invoice number'; // Error in the request
    });
  }
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
            child: const Text('CONFIRM'),
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

    const url = 'http://192.168.100.50:98/api/Invoice/AddInvoice';
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
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to submit invoice.')),
        );
      }
    } catch (e) {
      log('Error submitting invoice: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred. Please try again.')),
      );
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
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() {
        if (isInvoiceDate) {
          invoiceDate = picked;
        } else {
          dueDate = picked;
        }
      });
    }
  }

  Future<void> _selectExpiryDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );


    if (picked != null) {
      setState(() {
        expiryDate = picked;
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit invoice', style: TextStyle(color: Colors.white)),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

             TextField(
              controller: invoiceNumberController,
              enabled: false, 
              decoration: InputDecoration(
                // labelText: 'Invoice number',
                border: const OutlineInputBorder(),
                hintText: widget.invoiceNumber,
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
              onTap: null, // Disable onTap to prevent interaction
              child: InputDecorator(
                decoration: const InputDecoration(
                  // labelText: widget.invoiceDate, // Can be added back if needed
                  hintText: null, // No hint text, just displaying the value
                  suffixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                  enabled: false, // Disable input
                ),
                child: Text(
                  widget.invoiceDate != null
                    ? widget.invoiceDate.substring(0, widget.invoiceDate.lastIndexOf('T')) // Display formatted date from widget.invoiceDate
                    : invoiceDate!.toLocal().toString().split(' ')[0], // Fallback to `invoiceDate` if available   
                ),
              ),
            ),
            const SizedBox(height: 16),


            InkWell(
              onTap: () => _selectDate(context, false),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Invoice Due Date', // Label for the field
                  suffixIcon: Icon(Icons.calendar_today), // Calendar icon to indicate date selection
                  border: OutlineInputBorder(), // Field border
                ),
                child: Text(
                  // Check if the user has selected a date, otherwise use widget.invoiceDueDate
                  dueDate == null 
                    ? (widget.invoiceDueDate.substring(0, widget.invoiceDate.lastIndexOf('T'))) // Display widget.invoiceDueDate if available, otherwise show 'Choose a date'
                    : dueDate!.toLocal().toString().split(' ')[0], // If a date is selected, show it in 'yyyy-MM-dd' format
                ),
              ),
            ),
            const SizedBox(height: 16), // Adds space below the input field


            InkWell(
              onTap: () => _selectExpiryDate(context),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Invoice Expiry Date',
                  suffixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  // Check if the user has selected a date, otherwise use widget.invoiceDueDate
                  expiryDate == null 
                  ? (widget.invoiceExpiryDate.substring(0, widget.invoiceDate.lastIndexOf('T'))) // Display widget.invoiceDueDate if available, otherwise show 'Choose a date'
                    : expiryDate !.toLocal().toString().split(' ')[0], // If a date is selected, show it in 'yyyy-MM-dd' format
                
                  // expiryDate == null ? 'Choose a date' : expiryDate!.toLocal().toString().split(' ')[0],
                ),
              ),
            ),
            const SizedBox(height: 16),

            isLoading
            ? const Center(child: CircularProgressIndicator())
            : DropdownButtonFormField<String>(
                value: selectedCustomer, // Value to display the selected customer
                isExpanded: true,
                items: customers.map((dynamic value) {
                  // Check if widget.customer exists in the customer list and pre-select the respective customer
                  if (value['Customer_Name'] == widget.customer && selectedCustomer == null) {
                    selectedCustomer = value['Customer_Name'].toString(); // Preselect customer based on Cus_Mas_Sno
                    cusMasSno = value['Cus_Mas_Sno']; // Set Cus_Mas_Sno for the matched customer
                  }
                  return DropdownMenuItem<String>(
                    value: value['Cus_Mas_Sno'].toString(),
                    onTap: () => {cusMasSno = value['Cus_Mas_Sno']}, // Update cusMasSno when a customer is selected
                    child: Text(
                      value['Customer_Name'],
                      overflow: TextOverflow.ellipsis, // Handle long customer names with ellipsis
                    ),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    selectedCustomer = newValue; // Update the selected customer based on user selection
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Customer', // Label for the dropdown field
                  border: OutlineInputBorder(), // Border style for the dropdown
                ),
              ),
        const SizedBox(height: 16), // Adds space below the dropdown

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
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ElevatedButton.icon(
                  onPressed: addItem,
                  icon: const Icon(Icons.add),
                  label: const Text('ADD'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent,
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
                    keyboardType: TextInputType.number,
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
                    keyboardType: TextInputType.number,
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
                    subtitle: Text('Quantity: ${item['quantity']} | Unit Price: ${item['unitPrice']} | Total: ${item['total']}'),
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

            // Submit button
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _onSubmitButtonPressed,
              child: const Text('Submit'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
