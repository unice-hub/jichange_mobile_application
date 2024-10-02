import 'dart:io';
import 'package:flutter/material.dart';
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
  String _token = 'Not logged in';
  bool isLoading = true;
  List<InvoiceData> createdInvoices = [];
  
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
    _fetchInvoicesData();
  }

  Future<void> _fetchInvoicesData() async {
    const url = 'http://192.168.100.50:98/api/Invoice/GetchDetails';
    
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
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        if (responseBody['response'] is List) {
          setState(() {
            createdInvoices = (responseBody['response'] as List)
                .map((item) => InvoiceData.fromJson(item, userID))
                .toList();
            isLoading = false;
          });
        } else {
          _showSnackBar('Unexpected data format: response is not a list');
        }
      } else {
        _showSnackBar('Error: Failed to fetch invoices');
      }
    } catch (e) {
      _showSnackBar('Error: $e');
    }
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
  final String remarks;
  final String goodsStatus;
  final String approvalStatus;
  final String currencyName;
  final double totalWithoutVAT;
  final double totalVAT;
  final int itemQty;
  final int itemUnitPrice;
  final int itemTotalAmount;
  final int invMasNo;
  final String deliveryStatus;
  final int invDetSno;

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
    this.remarks,
    this.goodsStatus,
    this.approvalStatus,
    this.currencyName,
    this.totalWithoutVAT,
    this.totalVAT,
    this.itemQty,
    this.itemUnitPrice,
    this.itemTotalAmount,
    this.invMasNo,
    this.deliveryStatus,
    this.invDetSno,
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
      json['Control_No'],
      json['Remarks'] ?? '',
      json['goods_status'] ?? '',
      json['approval_status'] ?? '',
      json['Currency_Name'] ?? '',
      json['Total_Without_Vt'] ?? '',
      json['Total_Vt'] ?? '',
      json['Item_Qty'] ?? '',
      json['Item_Unit_Price'] ?? '',
      json['Item_Total_Amount'] ?? '',
      json['Chus_Mas_No'] ?? '',
      json['delivery_status'] ?? '',
      json['Inv_Det_Sno'] ?? '',
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
              _buildInvoiceRow('Customer11 name:', widget.invoice.customerName),
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
              _buildInvoiceRow('Total:', "${widget.invoice.total}  ${widget.invoice.currencyCode}"),
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
        ElevatedButton(
          onPressed: () {
            // Define the action to perform when the button is pressed
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.invoice.approve == 'Access' ? Colors.blue : Colors.yellow,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(widget.invoice.approve, style: const TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildPaymentTypeContainer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: widget.invoice.paymentType == 'Fixed' ? Colors.purpleAccent : Colors.greenAccent,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        widget.invoice.paymentType,
        style: TextStyle(color: widget.invoice.paymentType == 'Fixed' ? Colors.white : Colors.black),
      ),
    );
  }

  Widget _buildStatusContainer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: widget.invoice.status == 'Active' ? Colors.blueAccent : Colors.redAccent,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        widget.invoice.status,
        style: const TextStyle(color: Colors.white),
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
        children: [
          _buildIconActionButton(Icons.visibility, 'View Details', () {
            // Define the action to view details
          }),
          _buildIconActionButton(Icons.picture_as_pdf, 'Download PDF', () {
            // Define the action to download PDF
            _downloadInvoicePDF(widget.invoice.compid.toString(), widget.invoice.invMasSno.toString());
          }),
          _buildIconActionButton(Icons.edit, 'Edit', () {
            // Define the action to edit the invoice
          }),
          _buildIconActionButton(Icons.cancel, 'Cancel', () {
            // Define the action to cancel
            _showCancelPopup();
          }),
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
      "cino": widget.invoice.controlNumber, // Control number
      "twvat": "", // Total without VAT
      "vtamou": "", // VAT amount
      "total": widget.invoice.total.toString(), // Total amount
      "Inv_remark": "", // Invoice remarks
      "lastrow": 0, // Last row
      // "userid": userID, // User ID

      // Invoice details section
      "details": [
        {
          "Inv_Mas_Sno": widget.invoice.invMasSno,
          "Inv_Det_Sno": widget.invoice.invDetSno,
          "Invoice_Date": widget.invoice.invoiceDate,
          "Payment_Type": widget.invoice.paymentType,
          "Invoice_No": widget.invoice.invoiceNumber,
          "Due_Date": widget.invoice.dueDate,
          "Invoice_Expired_Date": widget.invoice.expiryDate,
          "Chus_Mas_No": widget.invoice.invMasNo,
          "Chus_Name": widget.invoice.customerName,
          "Com_Mas_Sno": widget.invoice.compid,
          "Company_Name": widget.invoice.companyName,
          // "Inv_Remarks": null,
          "Remarks": widget.invoice.remarks,
          // "vat_category": null,
          "Currency_Code": widget.invoice.currencyCode,
          "Currency_Name": widget.invoice.currencyName,
          "Total_Without_Vt": widget.invoice.totalWithoutVAT,
          "Total_Vt": widget.invoice.totalVAT,
          "Total": widget.invoice.total,
          "Item_Qty": widget.invoice.itemQty,
          "Item_Unit_Price": widget.invoice.itemUnitPrice,
          "Item_Total_Amount": widget.invoice.itemTotalAmount,
          // "Vat_Percentage": widget.invoice.vatPercentage,
          // "Vat_Amount": widget.invoice.vatAmount,
          // "Item_Without_vat": widget.invoice.itemWithoutVAT,
          // "Item_Description": widget.invoice.itemDescription,
          "AuditBy": "Admin", // Audit by user
          // "warrenty": widget.invoice.warranty, // Warranty details
          // "Vat_Type": widget.invoice.vatType,
          // "goods_status": widget.invoice.goodsStatus,
          // "delivery_status": widget.invoice.deliveryStatus,
          // "Audit_Date": DateTime.now().toIso8601String(),
          // "grand_count": widget.invoice.grandCount,
          // "daily_count": widget.invoice.dailyCount,
          "approval_status": widget.invoice.approvalStatus,
          // "approval_date": DateTime.now().toIso8601String(),
          // "p_date": widget.invoice.pDate,
          // "Customer_ID_Type": widget.invoice.customerIDType,
          // "Customer_ID_No": widget.invoice.customerIDNo,
          // "Zreport_Sno": widget.invoice.zreportSno,
          // "Zreport_Status": widget.invoice.zreportStatus,
          // "Zreport_Status1": widget.invoice.zreportStatus1,
          // "Zreport_Date": widget.invoice.zreportDate,
          // "Zreport_Date1": widget.invoice.zreportDate1,
          // "Zreport_Date2": widget.invoice.zreportDate2,
          "Control_No": widget.invoice.controlNumber,
          "Reason": _reasonController.text, // Reason for cancellation
          "Status": widget.invoice.status,
          "Mobile": "",
          "Email": "",
        }
      ],

      "sno": widget.invoice.invMasSno,
      // "warrenty": widget.invoice.warranty, // Warranty details
      // "goods_status": widget.invoice.goodsStatus, // Goods status
      "delivery_status": widget.invoice.deliveryStatus, // Delivery status
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
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      // Handle success, e.g., showing a snackbar or downloading the PDF
      _showSnackBar('Invoice cancelled successfully $responseBody');
    } else {
      _showSnackBar('Failed to cancel the invoice');
    }
  } catch (e) {
    _showSnackBar('Error: $e');
  }
}



    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(content: Text('Invoice "${widget.invoice.invoiceNumber}" cancelled')),
    // );
    // Add logic here to trigger the cancellation API or further actions

  // }


 

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
    log('Error: $e');
    _showSnackBar('Error downloading the PDF: $e');
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

Widget _buildIconActionButton(IconData icon, String label, VoidCallback onPressed) {
  return Column(
    children: [
      IconButton(
        icon: Icon(icon, color: Theme.of(context).colorScheme.primary),
        onPressed: onPressed,
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
