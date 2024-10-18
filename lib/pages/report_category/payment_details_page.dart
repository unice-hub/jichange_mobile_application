import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PaymentDetailsPage extends StatefulWidget {
  const PaymentDetailsPage({super.key});

  @override
  _PaymentDetailsPageState createState() => _PaymentDetailsPageState();
}

class _PaymentDetailsPageState extends State<PaymentDetailsPage> {
  String? selectedVendor;
  String? selectedCustomer;
  DateTime? fromDate;
  DateTime? toDate;
  String _token = 'Not logged in';

  List<String> vendors = ['Me&U Apparel', 'Vendor 2', 'Vendor 3', 'joshua speaker urio'];
  List<String> customers = ['All', 'Customer 1', 'Customer 2', 'joshua speaker urio'];

  List<Map<String, dynamic>> invoices = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSessionInfo();
    fetchInvoices();
  }

  Future<void> _loadSessionInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('token') ?? 'Not logged in';
    });
  }

  Future<void> fetchInvoices() async {
    setState(() => isLoading = true);
    const url = 'http://192.168.100.50:98/api/RepCompInvoice/GetInvReport';
    final prefs = await SharedPreferences.getInstance();
    int instituteID = prefs.getInt('instID') ?? 0;
    int userID = prefs.getInt('userID') ?? 0;

    final Map<String, dynamic> requestBody = {
      "companyIds": [40140],
      "customerIds": [0],
      "stdate": "",
      "enddate": "",
      "allowCancelInvoice": true,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          invoices = List<Map<String, dynamic>>.from(data['response']);
          isLoading = false;
        });
      } else {
        showError('Failed to load invoices. Status: ${response.statusCode}');
      }
    } catch (e) {
      showError('Error fetching data: $e');
    }
  }

  // Function to pick a date
  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2125),
    );
    if (picked != null) {
      setState(() {
        if (isFromDate) {
          fromDate = picked;
        } else {
          toDate = picked;
        }
      });
    }
  }

   void showError(String message) {
    setState(() => isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Details', style: TextStyle(color: Colors.white)),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Wrapping filter section in SingleChildScrollView to avoid overflow
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildFilterSection(),
                    const SizedBox(height: 16.0),
                    // Action buttons for downloading filtered data
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            // Download as spreadsheet action
                          },
                          icon: const Icon(Icons.download),
                          label: const Text('Spreadsheet'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                        ),
                        const SizedBox(width: 16.0),
                        ElevatedButton.icon(
                          onPressed: () {
                            // Download as PDF action
                          },
                          icon: const Icon(Icons.picture_as_pdf),
                          label: const Text('PDF'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    isLoading
                ? const Center(child: CircularProgressIndicator())
                : invoices.isEmpty
                    ? const Center(child: Text('No invoices available'))
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: invoices.length,
                        itemBuilder: (context, index) {
                          final invoice = invoices[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: ExpansionTile(
                              title: Text('Invoice No: ${invoice['Invoice_No']}'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Customer: ${invoice['Chus_Name']}'),
                                  Text('Total Amount: ${invoice['Total']} TZS'),
                                  Text('Status: ${invoice['Status']}'),
                                ],
                              ),
                              children: [
                                ListTile(
                                  title: const Text('Details'),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Control No: ${invoice['Control_No']}'),
                                      Text('Payment Type: ${invoice['Payment_Type']}'),
                                      Text('Invoice Date: ${invoice['Invoice_Date'].split("T")[0]}'),
                                      Text('Due Date: ${invoice['Due_Date'].split("T")[0]}'),
                                      Text('Posted by: ${invoice['AuditBy']}'),
                                      Text('Status: ${invoice['goods_status']}'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Column(
      children: [
        Row(
          children: [
            // Vendor Dropdown
            Expanded(
              flex: 1,
              child: DropdownButtonFormField<String>(
                value: selectedVendor,
                isExpanded: true,
                items: vendors.map((vendor) {
                  return DropdownMenuItem(
                    value: vendor,
                    child: Text(vendor, overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedVendor = value;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Vendor',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 16.0),
            // Customer Dropdown
            Expanded(
              flex: 1,
              child: DropdownButtonFormField<String>(
                value: selectedCustomer,
                isExpanded: true,
                items: customers.map((customer) {
                  return DropdownMenuItem(
                    value: customer,
                    child: Text(customer, overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCustomer = value;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Customer',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16.0),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => _selectDate(context, true),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'From (Payment date)',
                    suffixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    fromDate == null ? 'Choose a date' : fromDate.toString().substring(0, 10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: InkWell(
                onTap: () => _selectDate(context, false),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'To (Payment date)',
                    suffixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    toDate == null ? 'Choose a date' : toDate.toString().substring(0, 10),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16.0),
        // Submit button for filtering
        ElevatedButton(
          onPressed: () {
            // Filter action
          },
          child: const Text('SUBMIT'),
        ),
      ],
    );
  }
}
