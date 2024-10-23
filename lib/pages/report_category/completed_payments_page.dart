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

  List<String> branches = ['Magomeni', 'Ilala', 'Kawe', 'Joshua Speaker Urio'];
  List<String> vendors = ['Me&U Apparel'];
  List<CustDetData> customers = [];
  List<String> invoiceNumbers = ['All', 'Invoice A', 'Invoice B', 'Joshua Speaker Urio'];

  List<InvoiceData> invoices = [];
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
    const url = 'http://192.168.100.50:98/api/Invoice/GetPaymentReport';
    final prefs = await SharedPreferences.getInstance();
    int instituteID = prefs.getInt('instID') ?? 0;
    int userID = prefs.getInt('userID') ?? 0;

    final Map<String, dynamic> requestBody = {
      "invoiceIds": [
        0
      ],
      "companyIds": [
        40140
      ],
      "customerIds": [
        0
      ],
      "stdate": "",
      "enddate": "",
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
              child: const Text('Submit'),
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
        return _InvoiceCard(invoice: invoices[index], custDet: customers[index],);
      },
    );
  }
}

class _InvoiceCard extends StatelessWidget {
  final InvoiceData invoice;
  final CustDetData custDet;

  const _InvoiceCard({super.key, required this.invoice, required this.custDet});

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
  final int sno;
  final String paymentSNo;
  final String paymentDate;
  final String paymentType;
  final String amountType;
  final String payerName;
  final String paymentTransNo;
  final String? currency;
  final double invoiceAmount;
  final double invoiceAmountLocal;
  final String receiptNo;
  final String? batchNo;
  final String? remarks;
  final String? authorizeId;
  final String? secureHash;
  final String? responseCode;
  final String? merchant;
  final String? message;
  final String? card;
  final String? token;
  final String status;
  final String? response;
  final String auditDate;
  final String? auditAction;
  final String? auditDone;
  final int auditID;
  final double paidAmount;
  final double modifiedAmount;
  final double amount30;
  final double amount70;
  final double bot;
  final int academicSno;
  final String? acadYear;
  final String? col1;
  final String? col2;
  final String? col3;
  final String? termType;
  final int feeSno;
  final int termSno;
  final String paymentTime;
  final String approveDate;
  final String? feeDataSno;
  final String currencyCode;
  final double requestedAmount;
  final String? paymentDesc;
  final String? payerId;
  final String transChannel;
  final String? prWbId;
  final String institutionId;
  final String controlNo;
  final String? chksum;
  final String? chargeType;
  final String invoiceSno;
  final String? currencyType;
  final String? postedBy;
  final String? approvedBy;
  final String postedDate;
  final double amount;
  final double surchargeFee;
  final String? examined;
  final String? authorized;
  final int receiptNoService;
  final int compMasSno;
  final String companyName;
  final int custMasSno;
  final String customerName;
  final int classSno;
  final String? className;
  final int sectionSno;
  final String? sectionName;
  final double itemTotalAmount;
  final String? errorText;
  final double balance;

  InvoiceData({
    required this.sno,
    required this.paymentSNo,
    required this.paymentDate,
    required this.paymentType,
    required this.amountType,
    required this.payerName,
    required this.paymentTransNo,
    this.currency,
    required this.invoiceAmount,
    required this.invoiceAmountLocal,
    required this.receiptNo,
    this.batchNo,
    this.remarks,
    this.authorizeId,
    this.secureHash,
    this.responseCode,
    this.merchant,
    this.message,
    this.card,
    this.token,
    required this.status,
    this.response,
    required this.auditDate,
    this.auditAction,
    this.auditDone,
    required this.auditID,
    required this.paidAmount,
    required this.modifiedAmount,
    required this.amount30,
    required this.amount70,
    required this.bot,
    required this.academicSno,
    this.acadYear,
    this.col1,
    this.col2,
    this.col3,
    this.termType,
    required this.feeSno,
    required this.termSno,
    required this.paymentTime,
    required this.approveDate,
    this.feeDataSno,
    required this.currencyCode,
    required this.requestedAmount,
    this.paymentDesc,
    this.payerId,
    required this.transChannel,
    this.prWbId,
    required this.institutionId,
    required this.controlNo,
    this.chksum,
    this.chargeType,
    required this.invoiceSno,
    this.currencyType,
    this.postedBy,
    this.approvedBy,
    required this.postedDate,
    required this.amount,
    required this.surchargeFee,
    this.examined,
    this.authorized,
    required this.receiptNoService,
    required this.compMasSno,
    required this.companyName,
    required this.custMasSno,
    required this.customerName,
    required this.classSno,
    this.className,
    required this.sectionSno,
    this.sectionName,
    required this.itemTotalAmount,
    this.errorText,
    required this.balance,
  });

  factory InvoiceData.fromJson(Map<String, dynamic> json) {
    return InvoiceData(
      sno: json['SNO'],
      paymentSNo: json['Payment_SNo'],
      paymentDate: json['Payment_Date'],
      paymentType: json['Payment_Type'],
      amountType: json['Amount_Type'],
      payerName: json['Payer_Name'],
      paymentTransNo: json['Payment_Trans_No'],
      currency: json['Currency'],
      invoiceAmount: json['Invoice_Amount'].toDouble(),
      invoiceAmountLocal: json['Invoice_Amount_Local'].toDouble(),
      receiptNo: json['Receipt_No'],
      batchNo: json['Batch_No'],
      remarks: json['Remarks'],
      authorizeId: json['Authorize_Id'],
      secureHash: json['Secure_Hash'],
      responseCode: json['Response_Code'],
      merchant: json['Merchant'],
      message: json['Message'],
      card: json['Card'],
      token: json['Token'],
      status: json['Status']?? "Unsent" ,
      response: json['Response'],
      auditDate: json['Audit_Date'],
      auditAction: json['AuditAction'],
      auditDone: json['AuditDone'],
      auditID: json['AuditID'],
      paidAmount: json['PaidAmount'].toDouble(),
      modifiedAmount: json['ModifiedAmount'].toDouble(),
      amount30: json['Amount30'].toDouble(),
      amount70: json['Amount70'].toDouble(),
      bot: json['BOT'].toDouble(),
      academicSno: json['AcademicSno'],
      acadYear: json['Acad_Year'],
      col1: json['Col1'],
      col2: json['Col2'],
      col3: json['Col3'],
      termType: json['Term_Type'],
      feeSno: json['Fee_Sno'],
      termSno: json['Term_Sno'],
      paymentTime: json['Payment_Time'],
      approveDate: json['Approve_Date'],
      feeDataSno: json['Fee_Data_Sno'],
      currencyCode: json['Currency_Code'],
      requestedAmount: json['Requested_Amount'].toDouble(),
      paymentDesc: json['Payment_Desc'],
      payerId: json['Payer_Id'],
      transChannel: json['Trans_Channel'],
      prWbId: json['PR_WB_ID'],
      institutionId: json['Institution_ID'],
      controlNo: json['Control_No'],
      chksum: json['Chksum'],
      chargeType: json['Charge_Type'],
      invoiceSno: json['Invoice_Sno'],
      currencyType: json['Currency_Type'],
      postedBy: json['Posted_By'],
      approvedBy: json['Approved_By'],
      postedDate: json['Posted_Date'],
      amount: json['Amount'].toDouble(),
      surchargeFee: json['Surcharge_Fee'].toDouble(),
      examined: json['Examined'],
      authorized: json['Authorized'],
      receiptNoService: json['Receipt_No_Service'],
      compMasSno: json['Comp_Mas_Sno'],
      companyName: json['Company_Name'],
      custMasSno: json['Cust_Mas_Sno'],
      customerName: json['Customer_Name'],
      classSno: json['Class_Sno'],
      className: json['Class_Name'],
      sectionSno: json['Section_Sno'],
      sectionName: json['Section_Name'],
      itemTotalAmount: json['Item_Total_Amount'].toDouble(),
      errorText: json['Error_Text'],
      balance: json['Balance'].toDouble(),
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