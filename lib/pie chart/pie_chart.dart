import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:learingdart/pie%20chart/pie_data.dart';

class MyPieChart extends StatelessWidget {
  final List<int> invoiceSummary;

  const MyPieChart({
    super.key,
    required this.invoiceSummary,
  });

  @override
  Widget build(BuildContext context) {
    // Initialize pie data
    PieData myPieData = PieData(
     invoiceCounts: invoiceSummary
    );

    myPieData.initializePieData();

    return PieChart(
      PieChartData(
        sections: myPieData.pieData.map((data) {
          return PieChartSectionData(
            value: data.y.toDouble(),
            title: '${data.y}',
            color: _getColor(data.x),
            radius: 50,
            titleStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }).toList(),
        
        centerSpaceRadius: 40,
        sectionsSpace: 4,
        startDegreeOffset: 90+90+90,
      ),
    );
  }

  

  Color _getColor(int index) {
    switch (index) {
      case 0:
        return const Color.fromARGB(255, 131, 75, 204);// Fixed Invoices
      case 1:
        return const Color.fromARGB(255, 51, 134, 88);// Flexible Invoices
      case 2:
        return const Color.fromARGB(255, 194, 6, 252);// Flexible Invoices
      default:
        return Colors.grey;
    }
  }
}
