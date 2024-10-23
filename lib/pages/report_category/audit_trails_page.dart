import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuditTrailsPage extends StatefulWidget {
  const AuditTrailsPage({super.key});

  @override
  _AuditTrailsPageState createState() => _AuditTrailsPageState();
}

class _AuditTrailsPageState extends State<AuditTrailsPage>  {
String? selectedVendor;
  String? selectedCustomer;
  DateTime? fromDate;
  DateTime? toDate;
  String _token = 'Not logged in';
 String customerIds = "";
 String selectPage = "";

  List<String> vendors = ['Me&U Apparel'];
 
  List<InvoiceData> invoices = [];
  List<String> auditTypes = [];
  List<String> page = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSessionInfo();
    fetchInvoices();
    getcustDetReport();
    getpage();

  }

  Future<void> _loadSessionInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('token') ?? 'Not logged in';
    });
  }

  Future<void> fetchInvoices() async {
    setState(() => isLoading = true);
    const url = 'http://192.168.100.50:98/api/AuditTrail/report';

    try {
      final prefs = await SharedPreferences.getInstance();
      int instituteID = prefs.getInt('instID') ?? 0;
      int userID = prefs.getInt('userID') ?? 0;
      int braid = prefs.getInt('braid')?? 0;
      // log(userID.toString());
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({
          "tbname": selectPage.isNotEmpty ? selectPage: "",
          "Startdate": fromDate?.toIso8601String() ?? "",
          "Enddate": toDate?.toIso8601String() ?? "",
          "act": customerIds.isNotEmpty ? customerIds : "",
          "branch": braid,
          "pageNumber": 1,
          "pageSize": 5,
          "userid": userID
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          invoices = (data['response']['content'] as List)
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
   final prefs = await SharedPreferences.getInstance();
   int instituteID = prefs.getInt('instID') ?? 0;
   int userID = prefs.getInt('userID') ?? 0;

    // Base URL of the API
  const String baseUrl = 'http://192.168.100.50:98/api/AuditTrail/GetAvailableAuditTypes';

  // Constructing the full URL with query parameters
  String url = '$baseUrl?userid=$userID';

    try {
      final prefs = await SharedPreferences.getInstance();
      int instituteID = prefs.getInt('instID') ?? 0;
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
  
        auditTypes = (data['response'] as List).map((e) => e.toString()).toList();
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

  Future<void> getpage() async {
   final prefs = await SharedPreferences.getInstance();
   int instituteID = prefs.getInt('instID') ?? 0;
   int userID = prefs.getInt('userID') ?? 0;

    // Base URL of the API
  const String baseUrl = 'http://192.168.100.50:98/api/AuditTrail/GetAvailablePages';

  // Constructing the full URL with query parameters
  String url = '$baseUrl?userid=$userID';

    try {
      final prefs = await SharedPreferences.getInstance();
      int instituteID = prefs.getInt('instID') ?? 0;
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
  
        page = (data['response'] as List).map((e) => e.toString()).toList();
      });
      } else {
        showError('Failed to select page Status: ${response.statusCode}');
      }
    } catch (e) {
      showError('Error select page: $e');
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
        title: const Text('Audit Trails', style: TextStyle(color: Colors.white)),
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
                isExpanded: true,
                hint: const Text('Select Page'),
                items: page.map((String type) {
                  return DropdownMenuItem(
                      value: type, 
                      child: Text(
                        type,
                        overflow: TextOverflow.ellipsis,
                      )
                    );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedVendor = value;
                    selectPage = value ?? "";
                  });
                },
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
                hint: const Text('Select Actions'),
                items: auditTypes.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(
                      type,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCustomer = value;
                    customerIds = value ?? "";
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Actions',
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
        return _InvoiceCard(invoice: invoices[index]);
      },
    );
  }
}

class _InvoiceCard extends StatefulWidget {
  final InvoiceData invoice;
  

  const _InvoiceCard({required this.invoice});

  @override
  _InvoiceCardState createState() => _InvoiceCardState();
}

class _InvoiceCardState extends State<_InvoiceCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded; // Toggle expansion
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInvoiceRow('Title:', "'${widget.invoice.columnsName}' into '${widget.invoice.tableName}'"),
              const SizedBox(height: 5),
              _buildInvoiceRow('Type:', widget.invoice.auditType),
              const SizedBox(height: 5),
              _buildInvoiceRow('User:', widget.invoice.auditorNam),
              const SizedBox(height: 5),
              if (_isExpanded) ...[
                Container(
                  color: Colors.grey, // Set background color to gray
                  padding: const EdgeInsets.all(8.0), // Optional: add some padding
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.invoice.columnsName),
                      const SizedBox(height: 5),
                      Text('Field was left blank: ${widget.invoice.auditDate}'),
                      const SizedBox(height: 5),
                      Text(widget.invoice.ipAddress),
                      const SizedBox(height: 5),
                    ],
                  ),
                ),
              ],
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

class InvoiceData {
  final int auditSno;
  final String auditType;
  final String tableName;
  final String columnsName;
  final String auditBy;
  final String auditorNam;
  final String ipAddress;
  final String auditDate;

  InvoiceData({
    required this.auditSno,
    required this.auditType,
    required this.tableName,
    required this.columnsName,
    required this.auditBy,
    required this.auditorNam,
    required this.ipAddress,
    required this.auditDate,
    
  });

  factory InvoiceData.fromJson(Map<String, dynamic> json) {
    return InvoiceData(
      auditSno: json['Audit_Sno'] ?? 0,
      auditType: json['Audit_Type'] ?? '',
      tableName: json['Table_Name'] ?? '',
      columnsName: json['ColumnsName'] ?? '',
      auditBy: json['AuditBy'] ?? '',
      auditorNam: json['AuditorName'] ?? '',
      ipAddress: json['ipAddress'] ?? '',
      auditDate: json['Audit_Date'] ?? '',
      
    );
  }
}



