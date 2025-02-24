import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:learingdart/core/api/endpoint_api.dart';
import 'package:learingdart/pages/all_transactions.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';

String formatDate(String dateStr) {
  DateTime dateTime = DateTime.parse(dateStr);
  return DateFormat('yyyy-MM-dd').format(dateTime);
}

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
  List<int> customerIds = [];

  List<String> vendors = ['Me&U Apparel'];
 
  List<InvoiceData> invoices = [];
  List<CustDetData> customers = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSessionInfo();
    fetchInvoices();
    getcustDetReport();
  }

  Future<void> _loadSessionInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('token') ?? 'Not logged in';
    });
  }

  Future<void> fetchInvoices() async {
    setState(() => isLoading = true);
    const url = ApiEndpoints.getInvoiceTransact; //endpoint for the invoice transactions

    try {
      final prefs = await SharedPreferences.getInstance();
      int instituteID = prefs.getInt('instID') ?? 0;
      int userID = prefs.getInt('userID') ?? 0;
      // log(userID.toString());
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({
          "companyIds": [instituteID],
          "customerIds": customerIds.isNotEmpty ? customerIds : [0],
          "stdate": fromDate?.toIso8601String() ?? "",
          "enddate": toDate?.toIso8601String() ?? "",
          "allowCancelInvoice": false,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          invoices = (data['response'] as List)
              .map((e) => InvoiceData.fromJson(e))
              .toList();
        });
      } else {
        showError('Failed to load invoices. Status: ${response.statusCode}');
      }
    } catch (e) {
      showError('Error fetching data: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> getcustDetReport() async {
    setState(() => isLoading = true);
    const url = ApiEndpoints.getCustDetails; //endpoint for the customer details

    try {
      final prefs = await SharedPreferences.getInstance();
      int instituteID = prefs.getInt('instID') ?? 0;
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({
          "companyIds": [instituteID],
          
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          customers = (data['response'] as List)
              .map((e) => CustDetData.fromJson(e))
              .toList();
          var y = CustDetData(custSno: 0,custName: 'All',phone: '',postedDate: '',companySno: 0); 
          customers.insert(0, y);
        });
      } else {
        showError('Failed to load customers. Status: ${response.statusCode}');
      }
    } catch (e) {
      showError('Error fetching data: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Theme.of(context).colorScheme.surface // Dark mode
          : Theme.of(context).colorScheme.primary, // Light mode
        title: const Text('Payment Details', style: TextStyle(color: Colors.white)),
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
          children: [
            _buildFilters(),
            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: fetchInvoices,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Submit',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),

            _buildExportButtons(),
            const SizedBox(height: 16),

            isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildInvoiceList(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFilters() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: selectedVendor,
                hint: const Text('Select Vendor'),
                items: vendors.map((vendor) {
                  return DropdownMenuItem(value: vendor, child: Text(vendor));
                }).toList(),
                onChanged: (value) => setState(() => selectedVendor = value),
                decoration: const InputDecoration(
                  labelText: 'Vendor',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 16),

            Expanded(
              child: DropdownButtonFormField<String>(
                value: selectedCustomer,
                isExpanded: true,
                hint: const Text('Select Customer'),
                items: customers.map((custDet) {
                  return DropdownMenuItem<String>(
                    value: custDet.custSno.toString(),
                    child: Text(
                      "${custDet.custName} - ${custDet.phone}",
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCustomer = value;
                    customerIds = [int.parse(value!)];
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
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => _selectDate(context, true),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'From Date',
                    suffixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    fromDate != null
                        ? DateFormat('yyyy-MM-dd').format(fromDate!)
                        : 'Select Date',
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
                    labelText: 'To Date',
                    suffixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    toDate != null
                        ? DateFormat('yyyy-MM-dd').format(toDate!)
                        : 'Select Date',
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
  Widget _buildExportButtons() {
    return Row(
      children: [
        ElevatedButton.icon(
          onPressed: () async {
             try {
      await fetchInvoices(); // Fetch data from API
      await downloadPaymentDetailsPDF(invoices); // Generate and share PDF
    } catch (e) {
      print("Error downloading invoice: $e");
    }
  },// Define the action to download
          icon: const Icon(Icons.download, color: Colors.white),
          label: const Text(''),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          onPressed: () async {
            // try {
            //   await fetchInvoices(); // Fetch invoices
            //   await downloadPaymentDetailsPDF(invoices); // Pass the fetched invoices to the PDF download function
            // } catch (e) {
            //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
            // }
          },
          icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
          label: const Text(''),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInvoiceList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: invoices.length,
      itemBuilder: (context, index) {
        return _InvoiceCard(invoice: invoices[index], custDet: customers[index],);
      },
    );
  }
}


Future<void> downloadPaymentDetailsPDF(List<dynamic> invoices) async {
  final pdf = pw.Document();

  const url = ApiEndpoints.downloadInvoice; // Endpoint for downloading invoice

  for (var invoice in invoices) {
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Payment Date: ${formatDate(invoice.paymentDate)}', 
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)
              ),
              pw.Text('Customer: ${invoice.customerName}'),
              pw.Text('Invoice N°: ${invoice.invoiceSno}'),
              pw.Text('Payment type: ${invoice.paymentType}'),
              pw.Text('Status: ${invoice['status']}'),
              pw.Text('Total Amount: ${invoice['requestedAmount']}'),
              pw.Text('Paid Amount: ${invoice['paidAmount']}'),
              pw.Text('Balance: \$${invoice['balance']}'),
              pw.Text('Control N°: ${invoice['controlNumber']}'),
            ],
          );
        },
      ),
    );
  }

  await Printing.sharePdf(
    bytes: await pdf.save(),
    filename: 'invoices.pdf',
  );
}

class _InvoiceCard extends StatelessWidget {
  
   final formatter = NumberFormat('#,###');
  final InvoiceData invoice;
  final CustDetData custDet;

  _InvoiceCard({super.key, required this.invoice, required this.custDet});

 @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInvoiceRow('Payment Date:', formatDate(invoice.paymentDate)),
            const SizedBox(height: 5),
            _buildInvoiceRow('Customer:', invoice.customerName),
            const SizedBox(height: 5),
            _buildInvoiceRow('Invoice N°:', invoice.invoiceSno),
            const SizedBox(height: 5),
            _buildInvoiceRow('Payment type:', _buildPaymentTypeContainer(invoice)),
            const SizedBox(height: 5),
            _buildInvoiceRow('Status:', invoice.status),
            const SizedBox(height: 5),
            _buildInvoiceRow('Total Amount:', "${formatter.format(invoice.requestedAmount)} ${invoice.currencyCode}"),
            const SizedBox(height: 5),
            _buildInvoiceRow('Paid Amount:', "${formatter.format(invoice.paidAmount)} ${invoice.currencyCode}"),
            const SizedBox(height: 5),
            _buildInvoiceRow('Balance:', "${formatter.format(invoice.balance)} ${invoice.currencyCode}"),
            const SizedBox(height: 5),
            _buildInvoiceRow('Control N°:', invoice.controlNumber),
            const SizedBox(height: 5),
            _buildInvoiceRow('Payment Method:', invoice.transChannel),
            const SizedBox(height: 5),
            _buildInvoiceRow('Transaction N°:', invoice.paymentTransNo),
            const SizedBox(height: 5),
            _buildInvoiceRow('Receipt N°:', invoice.receiptNo),
            const SizedBox(height: 5),
            _buildInvoiceRow('Action(s):', _buildIconActionButton(Icons.visibility, '', () {
            // Define the action to view details
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AllTransactionsPage(
                    invoiceSno: invoice.invoiceSno,
                                
                    ),
                  ),
                );
            }, const Color.fromARGB(255, 128, 116, 12)),),
          ],
        ),
      ),
    );
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

  String formatDate(String dateStr) {
  DateTime dateTime = DateTime.parse(dateStr);
  return DateFormat('EEE MMM dd yyyy').format(dateTime);
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

   Widget _buildPaymentTypeContainer(InvoiceData invoice) {
       return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: invoice.paymentType == 'Fixed' ? const Color.fromARGB(47, 240, 154, 255) : const Color.fromARGB(61, 105, 240, 175),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        invoice.paymentType,
        style: TextStyle(color: invoice.paymentType == 'Fixed' ? const Color.fromARGB(255, 112, 45, 199) : const Color.fromARGB(255, 16, 116, 61)),
      ),
    );
  }
}



class InvoiceData {
  final int sno;
  final String paymentSno;
  final String paymentDate;
  final String paymentType;
  final String payerName;
  final String paymentTransNo;
  final String status;
  final String currencyCode;
  final double requestedAmount;
  final double paidAmount;
  final String controlNumber;
  final String? remarks;
  final String? paymentDesc;
  final String? transChannel;
  final String? institutionId;
  final String companyName;
  final String customerName;
  final String invoiceSno;
  final double balance;
  final String receiptNo;

  InvoiceData({
    required this.sno,
    required this.paymentSno,
    required this.paymentDate,
    required this.paymentType,
    required this.payerName,
    required this.paymentTransNo,
    required this.status,
    required this.currencyCode,
    required this.requestedAmount,
    required this.paidAmount,
    required this.controlNumber,
    this.remarks,
    this.paymentDesc,
    this.transChannel,
    this.institutionId,
    required this.companyName,
    required this.customerName,
    required this.invoiceSno,
    required this.balance,
    required this.receiptNo,
  });
  

  factory InvoiceData.fromJson(Map<String, dynamic> json) {
    return InvoiceData(
      sno: json['SNO'] ?? 0,
      paymentSno: json['Payment_SNo'] ?? '',
      paymentDate: json['Payment_Date']?.split('T')[0] ?? '',
      paymentType: json['Payment_Type'] ?? '',
      payerName: json['Payer_Name'] ?? '',
      paymentTransNo: json['Payment_Trans_No'] ?? '',
      status: json['Status'] ?? '',
      currencyCode: json['Currency_Code'] ?? '',
      requestedAmount: (json['Requested_Amount'] ?? 0).toDouble(),
      paidAmount: (json['PaidAmount'] ?? 0).toDouble(),
      controlNumber: json['Control_No'] ?? '',
      remarks: json['Remarks'],
      paymentDesc: json['Payment_Desc'],
      transChannel: json['Trans_Channel'],
      institutionId: json['Institution_ID'],
      companyName: json['Company_Name'] ?? '',
      customerName: json['Customer_Name'] ?? '',
      invoiceSno: json['Invoice_Sno'] ?? '',
      balance: (json['Balance'] ?? 0).toDouble(),
      receiptNo: json['Receipt_No'],
    );
  }
}


class CustDetData {
  final int custSno;
  final int companySno;
  final String custName;
  final String? phone;
  final String? postedDate;

  CustDetData({
    required this.custSno,
    required this.companySno,
    required this.custName,
    this.phone,
    this.postedDate,
  });

  factory CustDetData.fromJson(Map<String, dynamic> json) {
    return CustDetData(
      custSno: json['Cust_Sno'] ?? 0,
      companySno: json['CompanySno'] ?? 0,
      custName: json['Cust_Name'] ?? '',
      phone: json['Phone'],
      postedDate: json['Posted_Date']?.split('T')[0], // Extract date only
    );
  }
}

