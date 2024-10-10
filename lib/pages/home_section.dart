import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:learingdart/bar%20graph/bar_graph.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class HomeSection extends StatefulWidget {
  const HomeSection({super.key});

  @override
  _HomeSectionState createState() => _HomeSectionState();
}

class _HomeSectionState extends State<HomeSection> {
  String _token = 'Not logged in';
  int _userID = 0;
  int _instID = 0;
  String _userName = 'Unknown';
  int _braid = 0;

  bool isLoading = true;
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
      _userName = prefs.getString('userName') ?? 'Unknown';
      _braid = prefs.getInt('braid') ?? 0;
    });
    _fetchOverview();
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
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Overview',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
                      'Invoice summary',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    
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
                    const SizedBox(height: 20),

                    const Text(
                      'Generated invoice summary',

                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 200,
                      color: Colors.grey[200],
                      child: const Center(child: Text('Pie Chart Placeholder')),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Generated invoice(s)',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    _buildGeneratedInvoiceTable(),
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
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneratedInvoiceTable() {
    return Container(
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
      child: DataTable(
        columns: const <DataColumn>[
          DataColumn(label: Text('No.')),
          DataColumn(label: Text('Customer name')),
          DataColumn(label: Text('Invoice No')),
          DataColumn(label: Text('Invoice Date')),
          DataColumn(label: Text('Payment type')),
          DataColumn(label: Text('Total Amount')),
        ],
        rows: const <DataRow>[
          DataRow(
            cells: <DataCell>[
              DataCell(Text('1')),
              DataCell(Text('Joshua')),
              DataCell(Text('App/108')),
              DataCell(Text('Tue Oct 08 2024')),
              DataCell(Text('Flexible')),
              DataCell(Text('11,425 TZS')),
            ],
          ),
        ],
      ),
    );
  }
}
