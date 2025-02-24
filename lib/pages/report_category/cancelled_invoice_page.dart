import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:learingdart/core/api/endpoint_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CancelledInvoicePage extends StatefulWidget {
  const CancelledInvoicePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CancelledInvoicePageState createState() => _CancelledInvoicePageState();
}


class _CancelledInvoicePageState extends State<CancelledInvoicePage> {
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
    const url = ApiEndpoints.getCancelledInvoice; //endpoint for the cancelled invoice
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

  Future<void> getPaymentReport() async {
    setState(() => isLoading = true);
    const url = ApiEndpoints.getInvReport; //endpoint for the getinvoice report

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
          "allowCancelInvoice": true
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
        title: const Text('Cancelled Invoices', style: TextStyle(color: Colors.white)),
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
          onPressed: () {},
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
          onPressed: () {},
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
           invoiceNo: invoiceNumbers[index],
           );
      }else{
        return const SizedBox.shrink();
      }
      },
    );
  }
}

class _InvoiceCard extends StatelessWidget {
  final formatter = NumberFormat('#,###');
  final InvoiceData invoice;
  final CustDetData custDet;
  final InvoiceNumberData invoiceNo;

  _InvoiceCard({super.key, required this.invoice, required this.custDet, required this.invoiceNo});

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
            _buildInvoiceRow('Posted:', formatDate(invoice.invoiceDate)),
            const SizedBox(height: 5),
            _buildInvoiceRow('Customer name:', invoice.customerName),
            const SizedBox(height: 5),
            _buildInvoiceRow('Invoice N°:', invoice.invoiceNo),
            const SizedBox(height: 5),
            _buildInvoiceRow('Status:', _buildPaymentTypeContainer(invoice)),
            const SizedBox(height: 5),
            _buildInvoiceRow('Payment type:', "${formatter.format(invoice.invoiceAmount)} ${invoice.currencyCode}"),
            const SizedBox(height: 5),
            _buildInvoiceRow('Control N°:', invoice.controlNo),
            const SizedBox(height: 5),
            _buildInvoiceRow('Reason:', invoice.reason),
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
    final isFixed = invoice.status == 'cancelled';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isFixed ? const Color.fromARGB(82, 241, 202, 248) : const Color.fromARGB(72, 241, 229, 229),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        invoice.status,
        style: TextStyle(
          color: isFixed ? const Color(0xFF834BCC) : const Color.fromARGB(255, 100, 228, 88),
        ),
      ),
    );
  }
}

class InvoiceData {
  final String invoiceDate;
  final String customerName;
  final String invoiceNo;
  final double invoiceAmount;
  final String controlNo;
  final String status;
  final String reason;
  final String currencyCode;
  

  InvoiceData({
    required this.invoiceDate,
    required this.customerName,
    required this.invoiceNo,
    required this.invoiceAmount,
    required this.controlNo,
    required this.status,
    required this.reason,
    required this.currencyCode,
    
  });

  factory InvoiceData.fromJson(Map<String, dynamic> json) {
    return InvoiceData(
      invoiceDate: json['Audit_Date'],
      customerName: json['Customer_Name'],
      invoiceNo: json['Invoice_No'],
      status: "Cancelled",
      invoiceAmount: json['Invoice_Amount'],
      controlNo: json['Control_No'],
      reason: json['Reason'],
      currencyCode: json['Currency_Code'],
     
      
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