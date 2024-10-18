import 'dart:convert';
import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
import 'package:learingdart/bar%20graph/bar_graph.dart';
import 'package:learingdart/pages/invoices_tabs/generated_invoice_tab.dart';
import 'package:learingdart/pie%20chart/pie_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class OverviewPage extends StatefulWidget {
  const OverviewPage({super.key});

  @override
  _OverviewPageState createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
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
        appBar: AppBar(
        title: const Text('Overview', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    
                    const Text(
                      'Sale(s) summary',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    
                    // Bar Graph goes here
                    Container(
                      height: 350,
                      padding: const EdgeInsets.all(10.0),
                      color: Colors.grey[300],
                      child: MyBarGraph(
                        weeklySummary: [
                          double.parse(overviewData['Pendings'] ?? '0'),
                          double.parse(overviewData['Due'] ?? '0'),
                          double.parse(overviewData['Expired'] ?? '0'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    const Text(
                      'Invoice(s) summary',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),

                    // Information section about the pie chart
                    Container(
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
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
                            label: 'Pendings:',
                            value: '${int.parse(overviewData['Pendings'] ?? '0')}',
                            color: const Color.fromARGB(255, 138, 72, 224),
                          ),
                          const SizedBox(height: 5),
                          _buildChartInfoRow(
                            label: 'Due:',
                            value: '${int.parse(overviewData['Due'] ?? '0')}',
                            color: const Color.fromARGB(255, 66, 211, 131),
                          ),
                          const SizedBox(height: 5),
                          _buildChartInfoRow(
                            label: 'Expired:',
                            value: '${int.parse(overviewData['Expired'] ?? '0')}',
                            color: const Color.fromARGB(255, 151, 64, 190),
                          ),
                          
                        ],
                      ),
                    ),

                    Container(
                      height: 200,
                      color: Colors.grey[200],
                      child: MyPieChart(
                        invoiceSummary: [int.parse(overviewData['Pendings'] ?? '0'),
                          int.parse(overviewData['Due'] ?? '0'),
                          int.parse(overviewData['Expired'] ?? '0'),], // Fixed and Flexible invoices
                      ),
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      'Statistics',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),

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
                    const SizedBox(height: 20),

                    const Text(
                      'Latest transactions',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildOverviewCard(overviewData['Customer'] ?? '0', 'Customer(s)'),
                        _buildOverviewCard(overviewData['Due'] ?? '0', 'Due'),
                        _buildOverviewCard(overviewData['Expired'] ?? '0', 'Expired'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildOverviewCard(String value, String title) {
    return Container(
      width: MediaQuery.of(context).size.width / 3.5,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
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
            title,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          
        ],
      ),
    );
  }
}

 

Widget _buildChartInfoRow({
  required String label,
  required String value,
  required Color color,
  }) 
  
  {
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