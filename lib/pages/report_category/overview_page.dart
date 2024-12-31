// ignore_for_file: deprecated_member_use

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

  Map<String, String> detailsData = {
    "Total": "0",
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
     _getchDetails();
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
  
  Future<void> _getchDetails() async {
  const url = 'http://192.168.100.50:98/api/Invoice/GetchDetails';

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

      // Calculate total number of invoices and sum of all 'Total' fields
      int invoiceCount = responseData.length;
      double totalInvoiceAmount = responseData.fold(0.0, (sum, item) {
        return sum + (item['Total'] ?? 0.0);
      });

      // Update the UI state with the new data
      setState(() {
        detailsData['Due'] = invoiceCount.toString();
        detailsData['Expired'] = totalInvoiceAmount.toStringAsFixed(2);
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load details data');
    }
  } catch (e) {
    _showErrorDialog('An error occurred while fetching details data.\n${e.toString()}');
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
          backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Theme.of(context).colorScheme.surface // Dark mode
          : Theme.of(context).colorScheme.primary, // Light mode
        title: const Text('Overview', style: TextStyle(color: Colors.white)),
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
                    // _buildOverviewRows(),
                    // const SizedBox(height: 20),
                    // _buildSectionTitle('Invoice summary'),
                    const SizedBox(height: 20),
                    _buildBarGraph(),
                    const SizedBox(height: 20),
                    _buildSectionTitle('Invoice(s) summary'),
                    const SizedBox(height: 20),
                    _buildPieChartSection(),
                    const SizedBox(height: 20),
                    _buildSectionTitle('Statistics'),
                    const SizedBox(height: 20),
                    _buildStatisticRows(),
                    const SizedBox(height: 20),
                    _buildSectionTitle('Latest transactions'),
                    const SizedBox(height: 20),
                    _buildtransactionsRows(),
                    const SizedBox(height: 40),
                    
                    
                    // const Text(
                    //   'Sale(s) summary',
                    //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    // ),
                    // const SizedBox(height: 20),
                    
                    // // Bar Graph goes here
                    // Container(
                    //   height: 350,
                    //   padding: const EdgeInsets.all(10.0),
                    //   color: Colors.grey[300],
                    //   child: MyBarGraph(
                    //     weeklySummary: [
                    //       double.parse(overviewData['Pendings'] ?? '0'),
                    //       double.parse(overviewData['Due'] ?? '0'),
                    //       double.parse(overviewData['Expired'] ?? '0'),
                    //     ],
                    //   ),
                    // ),
                    // const SizedBox(height: 10),

                    // const Text(
                    //   'Invoice(s) summary',
                    //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    // ),
                    // const SizedBox(height: 10),

                    // // Information section about the pie chart
                    // Container(
                    //   padding: const EdgeInsets.all(12.0),
                    //   decoration: BoxDecoration(
                    //     color: Colors.white,
                    //     borderRadius: BorderRadius.circular(8),
                    //     boxShadow: [
                    //       BoxShadow(
                    //         color: Colors.grey.withOpacity(0.5),
                    //         spreadRadius: 2,
                    //         blurRadius: 5,
                    //         offset: const Offset(0, 3),
                    //       ),
                    //     ],
                    //   ),
                    //   child: Column(
                    //     crossAxisAlignment: CrossAxisAlignment.start,
                    //     children: [
                    //       const Text(
                    //         'Chart Summary',
                    //         style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    //       ),
                    //       const SizedBox(height: 10),
                    //       _buildChartInfoRow(
                    //         label: 'Pendings:',
                    //         value: '${int.parse(overviewData['Pendings'] ?? '0')}',
                    //         color: const Color.fromARGB(255, 138, 72, 224),
                    //       ),
                    //       const SizedBox(height: 5),
                    //       _buildChartInfoRow(
                    //         label: 'Due:',
                    //         value: '${int.parse(overviewData['Due'] ?? '0')}',
                    //         color: const Color.fromARGB(255, 66, 211, 131),
                    //       ),
                    //       const SizedBox(height: 5),
                    //       _buildChartInfoRow(
                    //         label: 'Expired:',
                    //         value: '${int.parse(overviewData['Expired'] ?? '0')}',
                    //         color: const Color.fromARGB(255, 151, 64, 190),
                    //       ),
                          
                    //     ],
                    //   ),
                    // ),

                    // Container(
                    //   height: 200,
                    //   color: Colors.grey[200],
                    //   child: MyPieChart(
                    //     invoiceSummary: [int.parse(overviewData['Pendings'] ?? '0'),
                    //       int.parse(overviewData['Due'] ?? '0'),
                    //       int.parse(overviewData['Expired'] ?? '0'),], // Fixed and Flexible invoices
                    //   ),
                    // ),
                    // const SizedBox(height: 20),

                    // const Text(
                    //   'Statistics',
                    //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    // ),
                    // const SizedBox(height: 10),

                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    //   children: [
                    //     _buildOverviewCard(overviewData['Transaction'] ?? '0', 'Transactions'),
                    //     _buildOverviewCard(overviewData['Customer'] ?? '0', 'Customers'),
                    //     _buildOverviewCard(overviewData['Users'] ?? '0', 'Users'),
                    //   ],
                    // ),

                    // const SizedBox(height: 10),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    //   children: [
                    //     _buildOverviewCard(overviewData['Pendings'] ?? '0', 'Pending'),
                    //     _buildOverviewCard(overviewData['Due'] ?? '0', 'Due'),
                    //     _buildOverviewCard(overviewData['Expired'] ?? '0', 'Expired'),
                    //   ],
                    // ),
                    // const SizedBox(height: 20),

                    // const Text(
                    //   'Latest transactions',
                    //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    // ),
                    // const SizedBox(height: 10),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    //   children: [
                    //    _buildOverviewCard(overviewData['Customer'] ?? '0', 'Customer(s)'),
                    //    _buildOverviewCard(detailsData['Due'] ?? '0','Total Created\n Invoices',),
                    //    _buildOverviewCard(detailsData['Expired'] ?? '0','Total Invoice\n Amount',),
                    //   //  _buildOverviewCard(overviewData['Customer'] ?? '0', 'Customer(s)'),
                    //   //  _buildOverviewCard(detailsData['Due'] ?? '0','Total Created\n Invoices',),
                    //   //  _buildOverviewCard('1000000000000','Total Invoice\n Amount',),
                    //   ],
                    // ),
                    // const SizedBox(height: 10),
                    // const SizedBox(height: 10),
                    // const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Sale(s) summary',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
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
        const SizedBox(height: 10),
        Container(
          height: 200,
          padding: const EdgeInsets.all(10.0),
          color: Theme.of(context).colorScheme.surface,
          child: MyPieChart(
          invoiceSummary: [int.parse(overviewData['Pendings'] ?? '0'),
            int.parse(overviewData['Due'] ?? '0'),
            int.parse(overviewData['Expired'] ?? '0'),], // Fixed and Flexible invoices
          ),
        ),                   
      ],
    ),
  );
}

  Widget _buildStatisticRows() {
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

  Widget _buildtransactionsRows() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildOverviewCard(overviewData['Customer'] ?? '0', 'Customer(s)'),
            _buildOverviewCard(detailsData['Due'] ?? '0','Total Created\n Invoices',),
            _buildOverviewCard(detailsData['Expired'] ?? '0','Total Invoice\n Amount',),
            //  _buildOverviewCard(overviewData['Customer'] ?? '0', 'Customer(s)'),
            //  _buildOverviewCard(detailsData['Due'] ?? '0','Total Created\n Invoices',),
            //  _buildOverviewCard('1000000000000','Total Invoice\n Amount',),
          ],
        ),
      ],
    );
  }

 

  Widget _buildOverviewCard(String value, String title) {
    // Convert value to a formatted string with commas
    String formattedValue;
    try {
      // double formatted = NubemrFormat('#,##0').format(double.parse(value)) as double;
      int number = double.parse(value).toInt();
      
      String formatNumber(int num) {
      if (num >= 1e15) {
        return '${(num / 1e15)}Q'; // Quadrillions
      } else if (num >= 1e12) {
        return '${(num / 1e12)}T'; // Trillions
      } else if (num >= 1e9) {
        return '${(num / 1e9)}B'; // Billions
      } else if (num >= 1e6) {
        return '${(num / 1e6)}M'; // Millions
      } else if (num >= 1e3) {
        return '${(num / 1e3)}K'; // Thousands
      } else {
        return num.toString(); // Default format for smaller numbers
      }
    }
      // formattedValue = formatNumber(formatted);
      formattedValue = formatNumber(number);
    } catch (e) {
      formattedValue = value; // Fallback if parsing fails
    }


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
            title,
            style: const TextStyle(fontSize: 16),
           
          ),
          const SizedBox(height: 5),
          Text(
            formattedValue,
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