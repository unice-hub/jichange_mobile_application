// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:typed_data';

import 'package:excel/excel.dart' as excelLib;
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:learingdart/core/api/endpoint_api.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';


String formatDate(String dateStr) {
  DateTime dateTime = DateTime.parse(dateStr);
  return DateFormat('yyyy-MM-dd').format(dateTime);
}

class InvoiceDetailsPage extends StatefulWidget {
  const InvoiceDetailsPage({super.key});

  @override
  _InvoiceDetailsPageState createState() => _InvoiceDetailsPageState();
}

class _InvoiceDetailsPageState extends State<InvoiceDetailsPage> {
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
    const url = ApiEndpoints.getInvReport; //endpoint for the invoice report

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

  Future<void> _selectDate(BuildContext context, bool isFrom) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
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
        title: const Text('Invoice Details', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        // backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
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
    //          try {
    //   await fetchInvoices(); // Fetch data from API
    // await  createAndDownloadExcel(invoices);
    // } catch (e) {
    //   print("Error downloading invoice: $e");
    // }
         },
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
          onPressed: () async{
            //  try {
            
            //   await fetchInvoices(); // Fetch invoices
            //   await downloadInvoiceDetailsPDF(context, invoices); // Pass the fetched invoices to the PDF download function
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
      itemCount: invoices.length + 2,
      itemBuilder: (context, index) {
        // final customer = index < customers.length ? customers[index] : null;
        print('Index:$index,Invoices length:${invoices.length}');
        
        if (index >= 0 && index < invoices.length && index < customers.length){
          return _InvoiceCard(invoice: invoices[index], custDet: customers[index],);
        }else{
        return const SizedBox.shrink();
      }
      },
    );
  }
}

Future<void> downloadInvoiceDetailsPDF(
    BuildContext context, List<InvoiceData> invoices) async {
  final pdf = pw.Document();

  // Debug: Print invoice data
  print('Invoices: ${invoices.length}');
  for (var invoice in invoices) {
    print('Invoice: ${invoice.invoiceNumber}, Customer: ${invoice.customerName}');
  }

  // Check if invoices list is empty
  if (invoices.isEmpty) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: const Text('No invoices found.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    return;
  }

  // Add a single page for all invoices
pdf.addPage(
  pw.Page(
    build: (pw.Context context) {
      return pw.Padding(
        padding: pw.EdgeInsets.all(5),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Title
            pw.Text(
              'Invoice Details',
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(height: 20),

            // Table with header and data rows
            pw.Table(
              border: pw.TableBorder.all(width: 1),
              columnWidths: {
                // Adjust column widths to fit the page
                0: pw.FlexColumnWidth(1.5), // Payment Date
                1: pw.FlexColumnWidth(2.5), // Customer
                2: pw.FlexColumnWidth(1.5), // Invoice N°
                3: pw.FlexColumnWidth(1.5), // Payment Type
                4: pw.FlexColumnWidth(1.5), // Status
                5: pw.FlexColumnWidth(1.5), // Total Amount
                // 6: pw.FlexColumnWidth(1.5), // Paid Amount
                7: pw.FlexColumnWidth(1.5), // Balance
                8: pw.FlexColumnWidth(1.5), // Control N°
              },
              children: [
                // Header Row
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: PdfColors.grey300),
                  children: [
                    _buildTableCell('Date Posted', isHeader: true),
                    _buildTableCell('Customer Name', isHeader: true),
                    _buildTableCell('Invoice N°', isHeader: true),
                    _buildTableCell('Control N°', isHeader: true),
                    _buildTableCell('Payment Type', isHeader: true),
                    _buildTableCell('Status', isHeader: true),
                    _buildTableCell('Total Amount', isHeader: true),
                    // _buildTableCell('Paid Amount', isHeader: true),
                    _buildTableCell('Invoice Date', isHeader: true),
                    _buildTableCell('Due Date', isHeader: true),
                    _buildTableCell('Expiry Date', isHeader: true),
                  ],
                ),

                // Data Rows (One row per invoice)
                for (var invoice in invoices)
                  pw.TableRow(
                    children: [
                        _buildTableCell(formatDate(invoice.pdate)),
                      _buildTableCell(invoice.customerName),
                      _buildTableCell(invoice.invoiceNumber),
                      _buildTableCell(invoice.controlNumber),
                      _buildTableCell(invoice.paymentType),
                      _buildTableCell(invoice.status),
                      _buildTableCell('\$${invoice.total}'),
                      // _buildTableCell('\$${invoice.paidAmount}'),
                      _buildTableCell(invoice.invoiceDate),
                      _buildTableCell(invoice.dueDate),
                      _buildTableCell(invoice.invoiceExpiredDate),
                    ],
                  ),
              ],
            ),

            pw.Spacer(),

            // Footer Message
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                'Thank you for your payment!',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    },
  ),
);
  // Debug: Save and print PDF bytes
  final pdfBytes = await pdf.save();
  print('PDF generated successfully with ${pdfBytes.length} bytes');

  // Share the PDF
  await Printing.sharePdf(
    bytes: pdfBytes,
    filename: 'invoices.pdf',
  );
}

// Function to build table cells with optional header styling
pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
  return pw.Padding(
    padding: pw.EdgeInsets.symmetric(
      vertical: 5,
      horizontal: 3,
    ),
    child: pw.Text(
      text,
      style: pw.TextStyle(
        fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        fontSize: isHeader ? 14 : 10,
      ),
    ),
  );
}

Future<void> createAndDownloadExcel(List<dynamic> invoices) async {
  // Create an Excel document
  var excel =  excelLib.Excel.createExcel();
  var sheet = excel['Sheet1']; // Name of the sheet

  // Add headers
  sheet.appendRow([
excelLib.TextCellValue('SNo:'),
 excelLib.TextCellValue('Payment Date:'),
     excelLib.TextCellValue('Customer'),
     excelLib.TextCellValue('Invoice N°'),
     excelLib.TextCellValue('Payment type'),
      excelLib.TextCellValue('Status'),
      excelLib.TextCellValue('Total Amount'),
      excelLib.TextCellValue('Paid Amount'),
      excelLib.TextCellValue('Balance'),
      excelLib.TextCellValue('Control N°'),

     
  ]);

 for (var invoice in invoices) {
  var index= invoices.indexOf(invoice);
  // Add data rows
  sheet.appendRow([
     excelLib.IntCellValue(index+1),
      excelLib.TextCellValue('${invoice.paymentDate}'),
      excelLib.TextCellValue('${invoice.customerName}'),
      excelLib.TextCellValue('${invoice.invoiceSno}'),
      excelLib.TextCellValue('${invoice.paymentType}'),
      excelLib.TextCellValue('${invoice.status}'),
      excelLib.TextCellValue('${invoice.TotalAmount}'),
      excelLib.TextCellValue('${invoice.paidAmount}'),
      excelLib.TextCellValue('${invoice.balance}'),
      excelLib.TextCellValue('${invoice.controlNumber}'),

     
  ]);}




  // Save the file in a temporary directory
  Directory tempDir = await getTemporaryDirectory();
  String filePath = '${tempDir.path}/PaymentDetails.xlsx';
  File file = File(filePath);

  // Write data to file
  await file.writeAsBytes( excel.encode() as Uint8List);

  // Open the file so the user can view it
  await OpenFile.open(filePath);
}

class _InvoiceCard extends StatelessWidget {
  final formatter = NumberFormat('#,###');
  final InvoiceData invoice;
  final CustDetData custDet;

  _InvoiceCard({required this.invoice, required this.custDet});

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
            _buildInvoiceRow('Date Posted:', formatDate(invoice.pdate)),
            const SizedBox(height: 5),
            _buildInvoiceRow('Customer name:', invoice.customerName),
            const SizedBox(height: 5),
            _buildInvoiceRow('Invoice N°:', invoice.invoiceNumber),
            const SizedBox(height: 5),
            _buildInvoiceRow('Control N°:', invoice.controlNumber),
            const SizedBox(height: 5),
            _buildInvoiceRow('Payment type:', _buildPaymentTypeContainer(invoice)),
            const SizedBox(height: 5),
            _buildInvoiceRow('Delivery Status:', invoice.deliveryStatus),
            const SizedBox(height: 5),
            _buildInvoiceRow('Status:', invoice.status),
            const SizedBox(height: 5),
            _buildInvoiceRow('Total Amount:',"${ formatter.format(invoice.total)} ${invoice.currencyCode}"),
            const SizedBox(height: 5),
            _buildInvoiceRow('Posted by:', invoice.auditBy),
            const SizedBox(height: 5),
            _buildInvoiceRow('Invoice Date:', formatDate(invoice.invoiceDate)),
            const SizedBox(height: 5),
            _buildInvoiceRow('Due Date:', formatDate(invoice.dueDate)),
            const SizedBox(height: 5),
            _buildInvoiceRow('Expiry Date:', formatDate(invoice.invoiceExpiredDate)),
          ],
        ),
      ),
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
    final isFixed = invoice.paymentType == 'Fixed';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isFixed ? const Color(0xFFF09AFF) : Colors.greenAccent,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        invoice.paymentType,
        style: TextStyle(
          color: isFixed ? const Color(0xFF834BCC) : const Color(0xFF338658),
        ),
      ),
    );
  }
}



class InvoiceData {
  final int invMasSno;
  final String invoiceNumber;
  final String invoiceDate;
  final String paymentType;
  final String customerName;
  final String companyName;
  final String dueDate;
  final String invoiceExpiredDate;
  final String status;
  final String currencyCode;
  final double total;
  final String controlNumber;
  final double balance;
  final String? goodsStatus;
  final String? remarks;
  final String? mobile;
  final String? email;
  final String pdate;
  final String deliveryStatus;
  final String auditBy;
  final int chusMasNo;

  InvoiceData({
    required this.invMasSno,
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.paymentType,
    required this.customerName,
    required this.companyName,
    required this.dueDate,
    required this.invoiceExpiredDate,
    required this.status,
    required this.currencyCode,
    required this.total,
    required this.controlNumber,
    required this.balance,
    this.goodsStatus,
    this.remarks,
    this.mobile,
    this.email,
    required this.pdate,
    required this.deliveryStatus,
    required this.auditBy,
    required this.chusMasNo,
  });

  factory InvoiceData.fromJson(Map<String, dynamic> json) {
    return InvoiceData(
      invMasSno: json['Inv_Mas_Sno'] ?? 0,
      invoiceNumber: json['Invoice_No'] ?? '',
      invoiceDate: json['Invoice_Date']?.split('T')[0] ?? '',
      paymentType: json['Payment_Type'] ?? '',
      customerName: json['Chus_Name'] ?? '',
      companyName: json['Company_Name'] ?? '',
      dueDate: json['Due_Date']?.split('T')[0] ?? '',
      invoiceExpiredDate: json['Invoice_Expired_Date']?.split('T')[0] ?? '',
      status: json['Status'] ?? '',
      currencyCode: json['Currency_Code'] ?? '',
      balance: (json['Balance'] ?? 0).toDouble(),
      controlNumber: json['Control_No'] ?? '',
      goodsStatus: json['goods_status'],
      remarks: json['Remarks'],
      mobile: json['Mobile'],
      email: json['Email'],
      pdate:json['p_date']?.split('T')[0] ?? '',
      deliveryStatus: json['delivery_status']?? 'Unsent',
      auditBy: json['AuditBy']?? '',
      chusMasNo: json['Chus_Mas_No'], total: (json['Total'] ?? 0).toDouble(),
    );
  }
  
  String? get paymentdate => null;
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

