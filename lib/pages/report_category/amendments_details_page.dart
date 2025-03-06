import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:learingdart/core/api/endpoint_api.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show Uint8List, rootBundle;
import 'package:printing/printing.dart';
import 'package:open_file/open_file.dart';
import 'package:excel/excel.dart' as excelLib;

class AmendmentsDetailsPage extends StatefulWidget {
  const AmendmentsDetailsPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AmendmentsDetailsPageState createState() => _AmendmentsDetailsPageState();
}


class _AmendmentsDetailsPageState extends State<AmendmentsDetailsPage> {
  String? selectedBranch;
  String? selectedVendor;
  String? selectedCustomer;
  String? selectedInvoiceNumber;
  DateTime? fromDate;
  DateTime? toDate;
  String _token = 'Not logged in';
  List<int> customerIds = [];
  List<int> invoiceNumber1 = [];

  List<String> branches = ['Magomeni', 'Ilala', 'Kawe', 'Joshua Speaker Urio'];
  List<String> vendors = ['Me&U Apparel'];
  List<CustDetData> customers = [];
  List<InvoiceNumberData> invoiceNumbers = [];

  List<InvoiceData> invoices = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSessionInfo();
    fetchInvoices();
    getcustDetReport();
    getPaymentReport();
  }

  Future<void> _loadSessionInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('token') ?? 'Not logged in';
    });
  }

  Future<void> fetchInvoices() async {
    setState(() => isLoading = true);
    const url = ApiEndpoints.getAmendReport;//endpoint for the amend report
    final prefs = await SharedPreferences.getInstance();
    int instituteID = prefs.getInt('instID') ?? 0;
    int userID = prefs.getInt('userID') ?? 0;

    final Map<String, dynamic> requestBody = {
      "invoiceIds": invoiceNumber1.isNotEmpty ? invoiceNumber1 : [0],
      "companyIds": [instituteID],
      "customerIds": customerIds.isNotEmpty ? customerIds : [0],
      "stdate": fromDate?.toIso8601String() ?? "",
      "enddate": toDate?.toIso8601String() ?? "",
      "allowCancelInvoice": true
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
    const url =ApiEndpoints.getCustDetails; //endpoint for the customer details

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

  Future<void> getPaymentReport() async {
    setState(() => isLoading = true);
    const url = ApiEndpoints.getInvReport; //endpoint for the get invoice report

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
          "customerIds": [0],
          "stdate": "",
          "enddate": "",
          "allowCancelInvoice": false
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          invoiceNumbers = (data['response'] as List)
              .map((e) => InvoiceNumberData.fromJson(e))
              .toList();
          var y = InvoiceNumberData(invMasSno: 0, invoiceNos: "All"); 
          invoiceNumbers.insert(0, y);
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
        title: const Text('Amendments', style: TextStyle(color: Colors.white)),
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
      body:SingleChildScrollView(
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
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: selectedInvoiceNumber,
                isExpanded: true,
                hint: const Text('Select Invoice number'),
                items: invoiceNumbers.map((invoiceNo) {
                  return DropdownMenuItem<String>(
                    value: invoiceNo.invMasSno.toString(),
                    child: Text(
                       invoiceNo.invoiceNos,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedInvoiceNumber = value;
                    invoiceNumber1 = [int.parse(value!)];
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Invoice number',
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
          onPressed: () async{
            await fetchInvoices();
            await createAndDownloadExcel(invoices);
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
          onPressed: () async {
            await fetchInvoices();
            await downloadAmmendmentsDetailsPDF(context, invoices);
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

        print('Index:$index,Invoices length:${invoices.length}, Customers length: ${customers.length}');
       
       if (index >= 0 && index < invoices.length && index < customers.length && index < invoiceNumbers.length) {
        return _InvoiceCard(
          invoice: invoices[index], 
          custDet: customers[index], 
          invoiceNo: invoiceNumbers[index],);
      }else{
        return const SizedBox.shrink();
      }
      },
    );
  }
}

Future<void> downloadAmmendmentsDetailsPDF(BuildContext context, List<InvoiceData> invoices) async {
  final pdf = pw.Document();

  Future<pw.Font> _loadFont() async {
    try {
      final fontData = await rootBundle.load('assets/fonts/Roboto/static/Roboto-Regular.ttf');
      return pw.Font.ttf(fontData.buffer.asByteData());
    } catch (e) {
      print('Error loading font: $e');
      return pw.Font.courier(); // Fallback to a default font
    }
  }

  // Load custom font
  final ttf = await _loadFont();

  pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8.0),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: ttf, // Use the custom font
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  

  // Check if invoices list is empty
  if (invoices.isEmpty) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('No data found'),
        content: const Text('No data to export to PDF'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    return;
  }

  // Define the number of rows per page
  const int rowsPerPage = 10; // Adjust this value based on your layout

  // Split invoices into chunks for multiple pages
  for (var i = 0; i < invoices.length; i += rowsPerPage) {
    final chunk = invoices.sublist(i, i + rowsPerPage > invoices.length ? invoices.length : i + rowsPerPage);

    pdf.addPage(
      pw.Page(
        pageFormat:PdfPageFormat.a4.landscape,
        build: (pw.Context context) {
          return pw.Padding(
            padding: pw.EdgeInsets.all(10),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Title
                pw.Text(
                  'Amendments Details',
                  style: pw.TextStyle(
                    font: ttf, // Use the custom font
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),

                // Table
                pw.Table(
                  border: pw.TableBorder.all(width: 1),
                  columnWidths: {
                    0: pw.FlexColumnWidth(1.5), // Posted Date
                    1: pw.FlexColumnWidth(1.5), // Customer Name
                    2: pw.FlexColumnWidth(1.5), // Invoice N°
                    3: pw.FlexColumnWidth(1.5), // Status
                    4: pw.FlexColumnWidth(1.5), // Payment Type
                    5: pw.FlexColumnWidth(1.5), // Control N°
                    6: pw.FlexColumnWidth(1.5), // Reason
                  },
                  children: [
                    // Header Row
                    pw.TableRow(
                      decoration: pw.BoxDecoration(color: PdfColors.grey300),
                      children: [
                        _buildTableCell('Invoice Date', isHeader: true),
                        _buildTableCell('Customer', isHeader: true),
                        _buildTableCell('Invoice N°', isHeader: true),
                        _buildTableCell('Control N°', isHeader: true),
                        _buildTableCell('Payment Type', isHeader: true),
                        _buildTableCell('Reason', isHeader: true),
                        _buildTableCell('Expiry Date', isHeader: true),
                      ],
                    ),

                    // Data Rows
                    for (var invoice in chunk)
                      pw.TableRow(
                        children: [
                          _buildTableCell(_formatDate(invoice.invoiceDate)),
                          _buildTableCell(invoice.customerName),
                          _buildTableCell(invoice.invoiceNo),
                          _buildTableCell(invoice.controlNo),
                          _buildTableCell(invoice.paymentType),
                          _buildTableCell(invoice.reason),
                          _buildTableCell(_formatDate(invoice.invoiceExpiredDate)),
                        ],
                      ),
                  ],
                ),

                // Footer (only on the last page)
                if (i + rowsPerPage >= invoices.length)
                  pw.Column(
                    children: [
                      pw.SizedBox(height: 20),
                      pw.Align(
                        alignment: pw.Alignment.centerRight,
                        child: pw.Text(
                          'Thank you for your payment!',
                          style: pw.TextStyle(
                            font: ttf, // Use the custom font
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Save and share the PDF
  final pdfBytes = await pdf.save();
  print('PDF generated successfully with ${pdfBytes.length} bytes');

  // Save to file for debugging
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/Ammendments Details.pdf');
  await file.writeAsBytes(pdfBytes);
  print('PDF saved to: ${file.path}');

  // Share the PDF
  await Printing.sharePdf(
    bytes: pdfBytes,
    filename: 'Ammendments Details.pdf',
  );
}

// Helper function to format date
String _formatDate(String? dateStr) {
  if (dateStr == null || dateStr.isEmpty) return 'N/A';
  try {
    DateTime dateTime = DateTime.parse(dateStr);
    return DateFormat('yyyy-MM-dd').format(dateTime);
  } catch (e) {
    print('Error formatting date: $e');
    return 'Invalid Date';
  }
}



Future<void> createAndDownloadExcel(List<InvoiceData> invoices) async {
  final excel = excelLib.Excel.createExcel();
  final sheet = excel['Ammendments Details'];

  sheet.appendRow([
    excelLib.TextCellValue('S/N'),
    excelLib.TextCellValue('Invoice Date'),
    excelLib.TextCellValue('Customer'),
    excelLib.TextCellValue('Invoice N°'),
    excelLib.TextCellValue('Control N°'),
    excelLib.TextCellValue('Payment type'),
    excelLib.TextCellValue('Reason'),
    excelLib.TextCellValue('Expiry Date'),
  ]);

  for (final invoice in invoices) {
    var index = invoices.indexOf(invoice);

    sheet.appendRow([
     excelLib.IntCellValue(index + 1),
     excelLib.TextCellValue(invoice.invoiceDate),
      excelLib.TextCellValue(invoice.customerName),
      excelLib.TextCellValue(invoice.invoiceNo),
      excelLib.TextCellValue(invoice.controlNo),
      excelLib.TextCellValue(invoice.invoiceExpiredDate),
      excelLib.TextCellValue(invoice.paymentType),
      excelLib.TextCellValue(invoice.reason),

      
    ]);
  }
Directory tempDir = await getTemporaryDirectory();
  String filePath = '${tempDir.path}/Ammendments Details.xlsx';
  File file = File(filePath);

  // Write data to file
  await file.writeAsBytes(excel.encode() as Uint8List);

  // Open the file so the user can view it
  await OpenFile.open(filePath);
  
}


class _InvoiceCard extends StatelessWidget {
  final InvoiceData invoice;
  final CustDetData custDet;
  final InvoiceNumberData invoiceNo;

  const _InvoiceCard({super.key, required this.invoice, required this.custDet, required this.invoiceNo});

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
            _buildInvoiceRow('Invoice Date:', formatDate(invoice.invoiceDate)),
            const SizedBox(height: 5),
            _buildInvoiceRow('Customer:', invoice.customerName),
            const SizedBox(height: 5),
            _buildInvoiceRow('Invoice N°:', invoice.invoiceNo),
            const SizedBox(height: 5),
            _buildInvoiceRow('Control N°:', invoice.controlNo),
            const SizedBox(height: 5),
            _buildInvoiceRow('Payment type:', _buildPaymentTypeContainer(invoice)),
            const SizedBox(height: 5),
            _buildInvoiceRow('Reason:', invoice.reason),
            const SizedBox(height: 5),
            _buildInvoiceRow('Expiry date:', formatDate(invoice.invoiceExpiredDate)),
            const SizedBox(height: 5),
            
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
        color: isFixed ? const Color.fromARGB(82, 240, 154, 255) : const Color.fromARGB(76, 105, 240, 175),
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
  final String invoiceDate;
  final String customerName;
  final String invoiceNo;
  final String controlNo;
  final String paymentType;
  final String reason;
  final String invoiceExpiredDate;
  

  InvoiceData({
    required this.invoiceDate,
    required this.customerName,
    required this.invoiceNo,
    required this.controlNo,
    required this.paymentType,
    required this.reason,
    required this.invoiceExpiredDate,
    
  });

  factory InvoiceData.fromJson(Map<String, dynamic> json) {
    return InvoiceData(
      invoiceDate: json['Invoice_Date'],
      customerName: json['Customer_Name'],
      invoiceNo: json['Invoice_No'],
      controlNo: json['Control_No'],
      paymentType: json['Payment_Type'],
      reason: json['Reason'],
      invoiceExpiredDate: json['Invoice_Expired_Date'],
     
      
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

class InvoiceNumberData {
  final int invMasSno;
  final String invoiceNos;

  InvoiceNumberData({
    required this.invMasSno,
    required this.invoiceNos,
  });

  factory InvoiceNumberData.fromJson(Map<String, dynamic> json){
    return InvoiceNumberData(
      invMasSno: json['Inv_Mas_Sno'],
      invoiceNos: json['Invoice_No'],

      );
  }
}