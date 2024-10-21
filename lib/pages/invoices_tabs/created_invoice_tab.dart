import 'dart:io';
import 'package:flutter/material.dart';
import 'package:learingdart/core/api/invoice_apis.dart';
import 'package:learingdart/pages/edit_invoice.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../invoices_section.dart';
import 'dart:convert';
import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class CreatedInvoiceTab extends StatefulWidget {
  final List<Invoice> createdInvoices;
  final List<Invoice> filteredCreatedInvoices;

  const CreatedInvoiceTab({
    required this.createdInvoices,
    required this.filteredCreatedInvoices,
    super.key,
  });

  @override
  _CreatedInvoiceTabState createState() => _CreatedInvoiceTabState();
}

class _CreatedInvoiceTabState extends State<CreatedInvoiceTab> {
  String searchQuery = "";
  // String _token = 'Not logged in';
  bool isLoading = true;
  List<InvoiceData> createdInvoices = [];
  // List<RawInvoice> findRawInvoice  = [];
  
  
  @override
  void initState() {
    super.initState();
    _loadSessionInfo();
  }

  Future<void> _loadSessionInfo() async {
    // final prefs = await SharedPreferences.getInstance();
    // setState(() {
    //   _token = prefs.getString('token') ?? 'Not logged in';
    // });
    _fetchInvoicesData();
  }

  Future<void> _fetchInvoicesData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      int instituteID = prefs.getInt('instID') ?? 0;
      int userID = prefs.getInt('userID') ?? 0;

      // Body of the API request
      final Map<String, int> body = {
        "compid": instituteID
      };

      // Start loading
      setState(() {
        isLoading = true;
      });

      // Make the API request
      final getchDetails = await InvoiceApis.getchDetails.sendRequest(body: body);

      // Check if the response is valid
      if (getchDetails['response'] != null) {
        setState(() {
          createdInvoices = (getchDetails['response'] as List)
              .map((item) => InvoiceData.fromJson(item, userID))
              .toList();
        });
      } else {
        // Handle empty or invalid response
        _showErrorDialog("Invalid response from the server.");
      }
    } 
    on http.ClientException {
          _showErrorDialog("No internet connection. Please check your network.");
    } on HttpException {
      // Handle server-related errors
      _showErrorDialog("Couldn't retrieve data from the server.");
    } on FormatException {
      // Handle invalid response format (JSON parsing errors)
      _showErrorDialog("Invalid response format.");
    } catch (e) {
      // Handle any other errors
      _showErrorDialog("An unexpected error occurred: $e");
    } finally {
      // Stop loading in any case
      setState(() {
        isLoading = false;
      });
    }
    
  }

// Function to show error dialog
void _showErrorDialog(String message) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text("Error"),
      content: Text(message),
      actions: <Widget>[
        TextButton(
          child: const Text("OK"),
          onPressed: () {
            Navigator.of(ctx).pop();
          },
        ),
      ],
    ),
  );
}


  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    // Filter the invoices based on the search query
    final filteredCreatedInvoices = createdInvoices.where((invoice) {
      return invoice.customerName.toLowerCase().contains(searchQuery.toLowerCase()) ||
             invoice.invoiceNumber.toLowerCase().contains(searchQuery.toLowerCase()) ||
             invoice.approve.toLowerCase().contains(searchQuery.toLowerCase()) ||
             invoice.paymentType.toLowerCase().contains(searchQuery.toLowerCase()) ||
             invoice.status.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              children: [
                _buildSearchField(),
                const SizedBox(height: 8.0),
                _buildInvoiceList(filteredCreatedInvoices),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      onChanged: (value) {
        setState(() {
          searchQuery = value;
        });
      },
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search),
        labelText: 'Search',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
    );
  }

  
  Widget _buildInvoiceList(List<InvoiceData> invoices) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (invoices.isEmpty) {
      return const Center(child: Text("No invoices found"));
    }
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.66,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: invoices.length,
        itemBuilder: (context, index) {
          final invoice = invoices[index];
          return _InvoiceCard(invoice: invoice);
        },
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        // Define what happens when the button is pressed
        Navigator.pushNamed(context, '/create_invoice');
      },
      backgroundColor: Theme.of(context).colorScheme.primary,
      child: const Icon(Icons.add),
    );
  }
}



class InvoiceData {
  final String customerName;
  final String invoiceNumber;
  final String invoiceDate;
  final String approve;
  final String paymentType;
  final String status;
  final double total;
  final String currencyCode;
  final String dueDate;
  final String expiryDate;
  final int invMasSno;
  final int compid;
  final String companyName;
  final String controlNumber;
  // final String remarks;
  // final String goodsStatus;
  // final String approvalStatus;
  // final String currencyName;
  // final double totalWithoutVAT;
  // final double totalVAT;
  // final int itemQty;
  // final int itemUnitPrice;
  // final int itemTotalAmount;
  final int invMasNo;
  // final String deliveryStatus;
  // final int invDetSno;

  InvoiceData(
    this.customerName,
    this.invoiceNumber,
    this.invoiceDate,
    this.approve,
    this.paymentType,
    this.status,
    this.total,
    this.currencyCode,
    this.dueDate,
    this.expiryDate,
    this.invMasSno,
    this.compid,
    this.companyName,
    this.controlNumber,
    // this.remarks,
    // this.goodsStatus,
    // this.approvalStatus,
    // this.currencyName,
    // this.totalWithoutVAT,
    // this.totalVAT,
    // this.itemQty,
    // this.itemUnitPrice,
    // this.itemTotalAmount,
    this.invMasNo,
    // this.deliveryStatus,
    // this.invDetSno,
  );

  factory InvoiceData.fromJson(Map<String, dynamic> json, int userID) {
    return InvoiceData(
      json['Chus_Name'],
      json['Invoice_No'],
      json['Invoice_Date'],
      (json['AuditBy'] == userID.toString()) ? "No Access" : "Access",
      json['Payment_Type'],
      json['Status'],
      json['Total'],
      json['Currency_Code'],
      json['Due_Date'],
      json['Invoice_Expired_Date'],
      json['Inv_Mas_Sno'],
      json['Com_Mas_Sno'],
      json['Company_Name'],
      json['Control_No'] ?? '',
      
      
      // json['Remarks'] ?? '',
      // json['goods_status'] ?? '',
      // json['approval_status'] ?? '',
      // json['Currency_Name'] ?? '',
      // json['Total_Without_Vt'] ?? '',
      // json['Total_Vt'] ?? '',
      // json['Item_Qty'] ?? '',
      // json['Item_Unit_Price'] ?? '',
      // json['Item_Total_Amount'] ?? '',
      json['Chus_Mas_No'] ?? '',
      // json['delivery_status'] ?? '',
      // json['Inv_Det_Sno'] ?? '',
    );
  }
}


String formatDate(String dateStr) {
  DateTime dateTime = DateTime.parse(dateStr);
  return DateFormat('EEE MMM dd yyyy').format(dateTime);
}


class _InvoiceCard extends StatefulWidget {
  final InvoiceData invoice;

  const _InvoiceCard({super.key, required this.invoice});

  @override
  _InvoiceCardState createState() => _InvoiceCardState();
}

class _InvoiceCardState extends State<_InvoiceCard> {
  bool _isExpanded = false;

  final TextEditingController _reasonController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInvoiceRow('Customer name:', widget.invoice.customerName),
              const SizedBox(height: 5),
              _buildInvoiceRow('Invoice N°:', widget.invoice.invoiceNumber),
              const SizedBox(height: 5),
              _buildInvoiceRow('Invoice Date:', formatDate(widget.invoice.invoiceDate)),
              const SizedBox(height: 5),
              _buildApprovalRow(),
              const SizedBox(height: 5),
              _buildInvoiceRow('Payment type:', _buildPaymentTypeContainer()),
              const SizedBox(height: 5),
              _buildInvoiceRow('Status:', _buildStatusContainer()),
              const SizedBox(height: 5),
              _buildInvoiceRow('Total:', "${widget.invoice.total.toString()}  ${widget.invoice.currencyCode}"),
              const SizedBox(height: 5),
              _buildInvoiceRow('Due Date:', formatDate(widget.invoice.dueDate)),
              const SizedBox(height: 5),
              _buildInvoiceRow('Expiry Date:', formatDate(widget.invoice.expiryDate)),
              if (_isExpanded) _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInvoiceRow(String label, dynamic value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        value is Widget ? value : Text(value.toString()),
      ],
    );
  }

  Widget _buildApprovalRow() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      const Text('Approve:'),
      widget.invoice.approve == 'Access'
          ? ElevatedButton(
              onPressed: () {
                // Define the action to perform when the button is pressed
                _showAccessConfirmationPopup();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Access',
                style: TextStyle(color: Colors.black),
              ),
            )
          : const Text(
              ' No Access ',
              style: TextStyle(
                backgroundColor: Color(0xFFFFEB3B),
                color: Colors.black, // Color for 'No Access' text
                // fontWeight: FontWeight.bold,
              ),
            ),
    ],
  );
}

  Widget _buildPaymentTypeContainer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: widget.invoice.paymentType == 'Fixed' ? const Color.fromARGB(255, 240, 154, 255) : Colors.greenAccent,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        widget.invoice.paymentType,
        style: TextStyle(color: widget.invoice.paymentType == 'Fixed' ? const Color.fromARGB(255, 131, 75, 204) : const Color.fromARGB(34, 51, 134, 88)),
      ),
    );
  }

  Widget _buildStatusContainer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: widget.invoice.status == 'Active' ? const Color.fromARGB(45, 68, 137, 255) : Colors.redAccent,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        widget.invoice.status,
        style: const TextStyle(color: Colors.blueAccent),
      ),
    );
  }

 Widget _buildActionButtons() {
  return Column(
    children: [
      const SizedBox(height: 10),
      const Divider(),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children:  [
          _buildIconActionButton(Icons.edit, 'Edit', () {
            // Define the action to edit the invoice
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditInvoicePage(
                  invoiceNumber:widget.invoice.invoiceNumber,
                  invoiceDate:widget.invoice.invoiceDate,
                  invoiceDueDate:widget.invoice.dueDate,
                  invoiceExpiryDate:widget.invoice.expiryDate,
                  customer:widget.invoice.customerName,
                  paymentType:widget.invoice.paymentType,
                  currency:widget.invoice.currencyCode,
                  customerSno:widget.invoice.invMasNo,
                  invMasSno:widget.invoice.invMasSno,
                ),
              ),
            );
            // Navigator.pushNamed(context, '/edit_invoice');
          }, Colors.blue),

          _buildIconActionButton(Icons.cancel, 'Cancel', () {
            // Define the action to cancel
            _findInvoice(widget.invoice.compid.toString(), widget.invoice.invMasSno.toString());
            _showCancelPopup();
          }, Colors.red),

          _buildIconActionButton(Icons.visibility, 'View Details', () {
            // Define the action to view details
          }, const Color.fromARGB(255, 128, 116, 12)),

          _buildIconActionButton(Icons.download, 'Download', () {
            // Define the action to download PDF
            _downloadInvoicePDF(widget.invoice.compid.toString(), widget.invoice.invMasSno.toString());
          }, Colors.black),
          
        ],
      ),
    ],
  );
}

void _showCancelPopup() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cancel Invoice'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Reason'),
              const SizedBox(height: 8),
              TextField(
                //to get the data form the textfild 
                controller: _reasonController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter reason for cancellation',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              const Text(
                'Once cancelled, changes cannot be undone. Please proceed with caution.',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the popup
              },
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () {
                _validateAndProceed();
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  void _validateAndProceed() {
    if (_reasonController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a reason for cancellation')),
      );
    } else {
      Navigator.pop(context); // Close the first popup
      _showConfirmationPopup();
    }
  }

  void _showConfirmationPopup() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cancel Invoice'),
          content: Text(
            'Are you sure you want to cancel invoice "${widget.invoice.invoiceNumber}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the popup
              },
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () {
                _confirmCancellation();
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

void _confirmCancellation() {
  Navigator.pop(context); // Close the confirmation popup
  cancelInvoice();
}

void _showAccessConfirmationPopup() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cancel Invoice'),
          content: Text(
            'Are you sure you want to approve invoice "${widget.invoice.invoiceNumber}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the popup
              },
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () {
                _confirmApprovellation();
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
}

void _confirmApprovellation() {
  Navigator.pop(context); // Close the confirmation popup
  approvelInvoice();
}

bool isLoading = true;

Future<void> approvelInvoice() async {
  try {
    // SharedPreferences to get stored values
    final prefs = await SharedPreferences.getInstance();
    int instituteID = prefs.getInt('instID') ?? 0;
    int userID = prefs.getInt('userID') ?? 0;
    String token = prefs.getString('token') ?? ''; // Token from SharedPreferences

    // Define your API URL
    const String url = 'http://192.168.100.50:98/api/Invoice/AddInvoice';

    // Prepare the body with necessary details
    Map<String, dynamic> requestBody = {
      "compid": instituteID, // Company ID
      "invno": widget.invoice.invoiceNumber, // Invoice number
      "auname": "", // Actual user name
      "date": DateTime.now().toIso8601String(), // Current date
      "edate": DateTime.now().toIso8601String(), // End date
      "goods_status": "Approved",
      "iedate": DateTime.now().toIso8601String(), // Invoice expired date
      "ptype": widget.invoice.paymentType, // Payment type
      "chus": widget.invoice.invMasNo, // Customer number
      "comno": 0, // Company number
      "ccode": widget.invoice.currencyCode, // Currency code
      "ctype": "0", // Placeholder for type information
      "cino": "0", // Control number
      "twvat": 0, // Total without VAT
      "vtamou": 0, // VAT amount
      "total": widget.invoice.total.toString(), // Total amount
      "Inv_remark": "", // Invoice remarks
      "lastrow": 0, // Last row
      "details": [
        {
          "Inv_Mas_Sno": widget.invoice.invMasSno,
          "Invoice_Date": widget.invoice.invoiceDate,
          "Payment_Type": widget.invoice.paymentType,
          "Invoice_No": widget.invoice.invoiceNumber,
          "Invoice_Expired_Date": widget.invoice.expiryDate,
          "Reason": _reasonController.text, // Reason for cancellation
          "Status": widget.invoice.status,
          "Mobile": "",
        }
      ],

      "sno": widget.invoice.invMasSno,
      "reason": _reasonController.text, // Cancellation reason
      "userid": userID, // User ID
    };

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      setState(() {
        isLoading = false;
        
      });

      _showSnackBar('Invoice approved successfully');
    } else {
      _showSnackBar('Failed to approve the invoice');
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
      // _showSnackBar ('Error checking invoice number'); // Error in the request
      isLoading = false;
    });
  }
}

String _token = 'Not logged in';

 @override
  void initState() {
    super.initState();
    _loadSessionInfo();
  }

  Future<void> _loadSessionInfo() async {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _token = prefs.getString('token') ?? 'Not logged in';
      });
      
    }

// bool isLoading = true;

Future<void> cancelInvoice() async {
  try {
    // SharedPreferences to get stored values
    final prefs = await SharedPreferences.getInstance();
    int instituteID = prefs.getInt('instID') ?? 0;
    int userID = prefs.getInt('userID') ?? 0;
    String token = prefs.getString('token') ?? ''; // Token from SharedPreferences

    // Define your API URL
    const String url = 'http://192.168.100.50:98/api/Invoice/AddCancel';

    // Prepare the body with necessary details
    Map<String, dynamic> requestBody = {
      "compid": instituteID, // Company ID
      "invno": widget.invoice.invoiceNumber, // Invoice number
      "auname": "", // Actual user name
      "date": DateTime.now().toIso8601String(), // Current date
      "edate": DateTime.now().toIso8601String(), // End date
      "iedate": DateTime.now().toIso8601String(), // Invoice expired date
      "ptype": widget.invoice.paymentType, // Payment type
      "chus": widget.invoice.invMasNo, // Customer number
      "comno": 0, // Company number
      "ccode": widget.invoice.currencyCode, // Currency code
      "ctype": "0", // Placeholder for type information
      "cino": "0", // Control number
      "twvat": 0, // Total without VAT
      "vtamou": 0, // VAT amount
      "total": widget.invoice.total.toString(), // Total amount
      "Inv_remark": "", // Invoice remarks
      "lastrow": 0, // Last row
      "details": [
        {
          "Inv_Mas_Sno": widget.invoice.invMasSno,
          "Invoice_Date": widget.invoice.invoiceDate,
          "Payment_Type": widget.invoice.paymentType,
          "Invoice_No": widget.invoice.invoiceNumber,
          "Invoice_Expired_Date": widget.invoice.expiryDate,
          "Reason": _reasonController.text, // Reason for cancellation
          "Status": widget.invoice.status,
          "Mobile": "",
        }
      ],

      "sno": widget.invoice.invMasSno,
      "reason": _reasonController.text, // Cancellation reason
      "userid": userID, // User ID
    };

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      setState(() {
        isLoading = false;
        
      });

      _showSnackBar('Invoice cancelled successfully');
    } else {
      _showSnackBar('Failed to cancel the invoice');
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
      // _showSnackBar ('Error checking invoice number'); // Error in the request
      isLoading = false;
    });
  }
}

  //  List<RawInvoice> findRawInvoice  = [];
  Future<Map<String,dynamic>> findInvoice(String compid, String invno) async {
    return await InvoiceApis.findInvoice.sendRequest(urlParam: '?compid=$compid&inv=$invno');
  }

  Future<void> _findInvoice(String compid, String invno) async {
  try {
        final exists = await findInvoice(compid,invno);

        // Checking if the "response" field is true or false
        if (exists['response'] != null) {
        } else {
          setState(() {
            _showSnackBar ('Failed to find the invoice'); // No error message as invoice does not exist
          });

      }
  } 
    on http.ClientException {
        _showErrorDialog("No internet connection. Please check your network.");
  } on HttpException {
    // Handle server-related errors
    _showErrorDialog("Couldn't retrieve data from the server.");
  } on FormatException {
    // Handle invalid response format (JSON parsing errors)
    _showErrorDialog("Invalid response format.");
  } catch (e) {
    // Handle any other errors
    _showErrorDialog("An unexpected error occurred: $e");
  } finally {
    // Stop loading in any case
    setState(() {
      isLoading = false;
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

Future<void> _downloadInvoicePDF(String compid, String inv) async {
  // Base URL of the API
  const String baseUrl = 'http://192.168.100.50:98/api/Invoice/FindInvoice';

  // Constructing the full URL with query parameters
  String url = '$baseUrl?compid=$compid&inv=$inv';

  try {
    // Request storage permission
    if (await Permission.storage.request().isGranted) {
      // Sending the GET request
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/pdf', // Expecting a PDF file
          'Authorization': 'Bearer $_token',
        },
      );

      // log(_token);

      // Handling the response
      if (response.statusCode == 200) {
        // Get the directory to store the downloaded PDF
        final Directory? directory = await getExternalStorageDirectory();
        String filePath = '${directory?.path}/invoice_$inv.pdf';

        // Save the PDF file
        File file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        log('PDF saved at $filePath');
        _showSnackBar('Invoice PDF downloaded successfully.');
      } else {
        // Handle error
        log('Error: ${response.statusCode}');
        log('Response Body: ${response.body}');
        _showSnackBar('Failed to download PDF. Status: ${response.statusCode}');
      }
    } else {
      _showSnackBar('Storage permission denied');
    }
  } catch (e) {
    // Handle any exception
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

Future<void> requestStoragePermission() async {
  var status = await Permission.storage.status;
  if (!status.isGranted) {
    await Permission.storage.request();
  }
}

Future<void> downloadInvoice() async {
  await requestStoragePermission();
  // Proceed to download the PDF...
}

void downloadFile(String url) async {
  final directory = await getExternalStorageDirectory();
  final String filePath = '${directory?.path}/invoice.pdf';

  // Start the download
  final response = await HttpClient().getUrl(Uri.parse(url));
  final file = File(filePath);

  // Write the response to the file
  final bytes = await response.close().then((response) => response.fold<List<int>>([], (List<int> bytes, List<int> chunk) {
    bytes.addAll(chunk);
    return bytes;
  }));
  await file.writeAsBytes(bytes);

  // Optionally notify the user or handle the file as needed
  print('File downloaded to $filePath');
}

Widget _buildIconActionButton(IconData icon, String label, VoidCallback onPressed, Color iconColor) {
  return Column(
    children: [
      Container(
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          border: Border.all(color: iconColor, width: 2),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),        // Flat edge
            topRight: Radius.circular(16),       // Curved edge
            bottomLeft: Radius.circular(16),     // Curved edge
            bottomRight: Radius.circular(16),     // Flat edge
          ), // Apply caved corner effect
        ),
        child: IconButton(
          icon: Icon(icon, color: iconColor),
          onPressed: onPressed,
        ),
      ),
      Text(label, style: const TextStyle(fontSize: 12)),
    ],
  );
}


void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

Widget _buildActionButton(String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(label),
    );
  }
}