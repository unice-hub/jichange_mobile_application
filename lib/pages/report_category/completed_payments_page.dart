import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CompletedPaymentsPage extends StatefulWidget {
  const CompletedPaymentsPage({super.key});

  @override
  _CompletedPaymentsPageState createState() => _CompletedPaymentsPageState();
}

class _CompletedPaymentsPageState extends State<CompletedPaymentsPage> {
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
    const url = 'http://192.168.100.50:98/api/Invoice/GetPaymentReport';
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
    const url = 'http://192.168.100.50:98/api/InvoiceRep/GetCustDetails';

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
    const url = 'http://192.168.100.50:98/api/RepCompInvoice/GetInvReport';

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
        title: const Text('Completed Payments', style: TextStyle(color: Colors.white)),
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
          icon: const Icon(Icons.download),
          label: const Text(''),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
        ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.picture_as_pdf),
          label: const Text(''),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
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
        return _InvoiceCard(invoice: invoices[index], custDet: customers[index], invoiceNo: invoiceNumbers[index],);
      },
    );
  }
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
            _buildInvoiceRow('Payment Date:', formatDate(invoice.paymentDate)),
            const SizedBox(height: 5),
            _buildInvoiceRow('Payer:', invoice.payerName),
            const SizedBox(height: 5),
            _buildInvoiceRow('Customer:', invoice.customerName),
            const SizedBox(height: 5),
            _buildInvoiceRow('Invoice N°:', invoice.invoiceSno),
            const SizedBox(height: 5),
            _buildInvoiceRow('Control N°:', invoice.controlNo),
            const SizedBox(height: 5),
            _buildInvoiceRow('Payment Method:', invoice.transChannel),
            const SizedBox(height: 5),
            _buildInvoiceRow('Transaction N°:', invoice.paymentTransNo),
            const SizedBox(height: 5),
            _buildInvoiceRow('Status:', _buildStatusContainer(invoice)),
            const SizedBox(height: 5),
            _buildInvoiceRow('Receipt N°:', invoice.receiptNo),
            const SizedBox(height: 5),
            _buildInvoiceRow('Total Amount:',"${ invoice.requestedAmount} ${invoice.currencyCode}"),
            const SizedBox(height: 5),
            _buildInvoiceRow('Paid Amount:',"${ invoice.paidAmount} ${invoice.currencyCode}"),
            const SizedBox(height: 5),
            _buildInvoiceRow('Payment type:', _buildPaymentTypeContainer(invoice)),
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

Widget _buildStatusContainer(InvoiceData invoice) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: invoice.status == 'Active' ? const Color.fromARGB(45, 68, 137, 255) : const Color.fromARGB(76, 82, 114, 255),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        invoice.status,
        style: const TextStyle(color: Color.fromARGB(255, 5, 130, 255)),
      ),
    );
  }



class InvoiceData {
  final String paymentDate;
  final String paymentType;
  final String payerName;
  final String paymentTransNo;
  final String receiptNo;
  final String status;
  final double paidAmount;
  final String currencyCode;
  final double requestedAmount;
  final String transChannel;
  final String controlNo;
  final String invoiceSno;
  final String customerName;

  InvoiceData({
    required this.paymentDate,
    required this.paymentType,
    required this.payerName,
    required this.paymentTransNo,
    required this.receiptNo,
    required this.status,
    required this.paidAmount,
    required this.currencyCode,
    required this.requestedAmount,
    required this.transChannel,
    required this.controlNo,
    required this.invoiceSno,
    required this.customerName,

  });

  factory InvoiceData.fromJson(Map<String, dynamic> json) {
    return InvoiceData(
      paymentDate: json['Payment_Date'],
      paymentType: json['Payment_Type'],
      payerName: json['Payer_Name'],
      paymentTransNo: json['Payment_Trans_No'],
      receiptNo: json['Receipt_No'],
      status: json['Status']?? "Unsent" ,
      paidAmount: json['PaidAmount'].toDouble(),
      currencyCode: json['Currency_Code'],
      requestedAmount: json['Requested_Amount'].toDouble(),
      transChannel: json['Trans_Channel'],
      controlNo: json['Control_No'],
      invoiceSno: json['Invoice_Sno'],
      customerName: json['Customer_Name'],  
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