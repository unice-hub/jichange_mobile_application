// ignore_for_file: deprecated_member_use, avoid_print

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// import 'package:intl/intl.dart';
import 'package:learingdart/bar%20graph/bar_graph.dart';
import 'package:learingdart/pages/invoices_tabs/generated_invoice_tab.dart';
import 'package:learingdart/pie%20chart/pie_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class HomeSection extends StatefulWidget {
  const HomeSection({super.key});

  @override
  _HomeSectionState createState() => _HomeSectionState();
}

class _HomeSectionState extends State<HomeSection> {
  String searchQuery = "";
  String _token = 'Not logged in';
  int _userID = 0;
  int _instID = 0;
  // String _userName = 'Unknown';
  // int _braid = 0;

  bool isLoading = true;
  List<InvoiceData> generatedInvoices = [];

   // Define invoiceSummary to hold the fixed and flexible invoice counts
  List<int> invoiceSummary = [0, 0];

  Map<String, String> overviewData = {
    "Transaction": "0",
    "Customer": "0",
    "Users": "0",
    "Pendings": "0",
    "Due": "0",
    "Expired": "0",
  };
  Map<String, String> overviewData1 = {
    "Company_Name": "",
  };

  @override
  void initState() {
    super.initState();
    _loadSessionInfo();
  }

  Future<void> _loadSessionInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('token') ?? 'Not logged in';
      _userID = prefs.getInt('userID') ?? 0;
      _instID = prefs.getInt('instID') ?? 0;
      // _userName = prefs.getString('userName') ?? 'Unknown';
      // _braid = prefs.getInt('braid') ?? 0;
    });
    _fetchOverview();
     _fetchInvoicesData();
     _getCompanyS();
  }

  Future<void> _fetchOverview() async {
    const url = 'http://192.168.100.50:98/api/Setup/Overview';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({"compid": _instID}),
      );

      print('Overview Response status: ${response.statusCode}');
      print('Overview Response body: ${response.body}');


      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final responseData = jsonResponse['response'];

        // Update the overviewData map with the API data
        setState(() {
          for (var item in responseData) {
            overviewData[item['Name']] = item['Statistic'];
          }
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load overview data');
      }
    } catch (e) {
      _showErrorDialog('An error occurred while fetching overview data.');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _getCompanyS() async {
    const url = 'http://192.168.100.50:98/api/Invoice/GetcompanyS';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({"compid": _instID}),
      );

      // print('Response status: ${response.statusCode}');
      // print('Response body: ${response.body}');


      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final responseData = jsonResponse['response'];

        setState(() {
          overviewData1["Company_Name"] = responseData["Company_Name"] ?? "Unknown";
        });
      } else {
        throw Exception('Failed to load company data');
      }
    } catch (e) {
      _showErrorDialog('An error occurred while fetching company data.');
      setState(() {
        isLoading = false;
      });
    }
  }
  Future<void> _fetchInvoicesData() async {
    const url = 'http://192.168.100.50:98/api/Invoice/GetSignedDetails';
    try {
      final prefs = await SharedPreferences.getInstance();
      int instituteID = prefs.getInt('instID') ?? 0;

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({"compid": instituteID}),
      );

      // print('Response status: ${response.statusCode}');
      // print('Response body: ${response.body}');


      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        if (responseBody['response'] is List) {
          setState(() {
            generatedInvoices = (responseBody['response'] as List)
                .map((item) => InvoiceData.fromJson(item, _userID))
                .toList();

            // Count the number of fixed and flexible invoices
          int fixedCount = generatedInvoices
              .where((invoice) => invoice.paymentType == 'Fixed')
              .length;
          int flexibleCount = generatedInvoices
              .where((invoice) => invoice.paymentType == 'Flexible')
              .length;

          // Pass the data to the pie chart
          _updatePieChartData(fixedCount, flexibleCount);

            isLoading = false;
          });
        } else {
          _showErrorDialog('Unexpected data format: response is not a list');
        }
      } else {
        _showErrorDialog('Error: Failed to fetch invoices');
      }
    } catch (e) {
      _showErrorDialog('An unexpected error occurred. Please try again.');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Update the pie chart with the new data
  void _updatePieChartData(int fixed, int flexible) {
    setState(() {
      invoiceSummary = [fixed.toInt(), flexible.toInt()];
    });
  }


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

  @override
  Widget build(BuildContext context) {
     final filteredInvoices = generatedInvoices.where((invoice) {
      return invoice.customerName.toLowerCase().contains(searchQuery.toLowerCase()) ||
          invoice.invoiceNumber.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
backgroundColor: Theme.of(context).colorScheme.surface,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 10),
                    _buildOverviewRows(),
                    const SizedBox(height: 20),
                    _buildSectionTitle('Invoice summary'),
                    const SizedBox(height: 20),
                    _buildBarGraph(),
                    const SizedBox(height: 20),
                    _buildSectionTitle('Generated invoice summary'),
                    const SizedBox(height: 20),
                    _buildPieChartSection(),
                    const SizedBox(height: 20),
                    _buildSectionTitle('Generated invoice(s)'),
                    const SizedBox(height: 20),
                    _buildSearchField(),
                    const SizedBox(height: 20),
                    _buildInvoiceList(filteredInvoices),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      onChanged: (value) => setState(() => searchQuery = value),
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search),
        labelText: 'Search',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Overview',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: Center(
            child: Text(
              overviewData1['Company_Name'] ?? '',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewRows() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildOverviewCard(overviewData['Transaction'] ?? '0', 'Transactions'),
            _buildOverviewCard(overviewData['Customer'] ?? '0', 'Customers'),
            _buildOverviewCard(overviewData['Users'] ?? '0', 'Users'),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildOverviewCard(overviewData['Pendings'] ?? '0', 'Pending'),
            _buildOverviewCard(overviewData['Due'] ?? '0', 'Due'),
            _buildOverviewCard(overviewData['Expired'] ?? '0', 'Expired'),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildBarGraph() {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: SizedBox(
        height: 350,
        // padding: const EdgeInsets.all(10.0),
        // color: Theme.of(context).colorScheme.surface,
        child: MyBarGraph(
          weeklySummary: [
            double.parse(overviewData['Pendings'] ?? '0'),
            double.parse(overviewData['Due'] ?? '0'),
            double.parse(overviewData['Expired'] ?? '0'),
          ],
        ),
      ),
    );
  }

 Widget _buildPieChartSection() {
  return Container(
    padding: const EdgeInsets.all(12.0),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(8),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.5),
          spreadRadius: 2,
          blurRadius: 5,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Chart Summary',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        _buildChartInfoRow(
          label: 'Fixed Invoices:',
          value: '${invoiceSummary[0].toInt()}',
          color: const Color.fromARGB(255, 131, 75, 204),
        ),
        const SizedBox(height: 5),
        _buildChartInfoRow(
          label: 'Flexible Invoices:',
          value: '${invoiceSummary[1].toInt()}',
          color: const Color.fromARGB(255, 51, 134, 88),
        ),
        const SizedBox(height: 10),
        Container(
          height: 200,
          padding: const EdgeInsets.all(10.0),
          color: Theme.of(context).colorScheme.surface,
          child: MyPieChart(
            invoiceSummary: invoiceSummary, // Fixed and Flexible invoices
          ),
        ),
      ],
    ),
  );
}


  Widget _buildOverviewCard(String value, String title) {
    return Container(
      width: MediaQuery.of(context).size.width / 3.5,
      height: 100,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceList(List<InvoiceData> invoices) {
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


 class _InvoiceCard extends StatelessWidget {
  final formatter = NumberFormat('#,###');
  final InvoiceData invoice;
  // final formatter = NumberFormat('#,###');

  _InvoiceCard({super.key, required this.invoice});
  

    @override
    Widget build(BuildContext context) {
      return Card(
        elevation: 4,
        child: InkWell(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              
              children: [
                _buildInvoiceRow('Customer name:', invoice.customerName),
                 const SizedBox(height: 5),
                _buildInvoiceRow('Invoice N°:', invoice.invoiceNumber ),
                const SizedBox(height: 5),
                _buildInvoiceRow('Invoice Date:', formatDate(invoice.invoiceDate)),
                const SizedBox(height: 5),
                _buildInvoiceRow('Payment type:', _buildPaymentTypeContainer()),
                const SizedBox(height: 5),
                _buildInvoiceRow('Total:', "${formatter.format(invoice.total)}  ${invoice.currencyCode}"),
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

    Widget _buildPaymentTypeContainer() {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: invoice.paymentType == 'Fixed' ? const Color.fromARGB(255, 240, 154, 255) : Colors.greenAccent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          invoice.paymentType,
          style: TextStyle(color: invoice.paymentType == 'Fixed' ? const Color.fromARGB(255, 131, 75, 204) : const Color.fromARGB(255, 51, 134, 88)),
        ),
      );
    }
  }

  Widget _buildChartInfoRow({
  required String label,
  required String value,
  required Color color,
}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Row(
        children: [
          Container(
            width: 12,
            height: 12,
            color: color,
          ),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
      Text(
        value,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  );
}