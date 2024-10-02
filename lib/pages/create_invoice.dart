import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:developer';

class CreateInvoicePage extends StatefulWidget {
  const CreateInvoicePage({super.key});

  @override
  _CreateInvoicePageState createState() => _CreateInvoicePageState();
}

class _CreateInvoicePageState extends State<CreateInvoicePage> {
  String searchQuery = "";
  String _token = 'Not logged in';
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

  // List to hold added items
  List<Map<String, dynamic>> addedItems = [];

  // Sample customer list
  List<String> customers = [];
  List<String> paymentTypes = ['Fixed', 'Flexible'];
  List<String> currency = [];

  @override
  void initState() {
    super.initState();
    _loadSessionInfo() ;
  }

  Future<void> _loadSessionInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('token') ?? 'Not logged in';
    });
    _fetchCustomerName();
    _fetchCurrency();
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
          final List<dynamic> customerName = jsonResponse['response'];
          setState(() {
             customers = customerName.map((branch) => branch['Customer_Name'] as String).toList();
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
        title: const Text('Create Invoice', style: TextStyle(color: Colors.white)),
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
          children: [
            const TextField(
              decoration: InputDecoration(
                labelText: 'Invoice number',
                border: OutlineInputBorder(),
                hintText: 'Enter invoice number',
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
              items: customers.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, overflow: TextOverflow.ellipsis),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedCustomer = newValue;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Customer',
                border: OutlineInputBorder(),
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
            const TextField(
              decoration: InputDecoration(
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
              onPressed: submitInvoice,
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
