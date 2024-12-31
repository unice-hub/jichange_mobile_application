// ignore_for_file: deprecated_member_use

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
            color: _getColor(context, data.x),
            radius: 50,
            titleStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black
                  : Colors.white, // Ensure text is visible in both themes
            ),
          );
        }).toList(),
        centerSpaceRadius: 40,
        sectionsSpace: 1,
        startDegreeOffset: 270,
        pieTouchData: PieTouchData(
          enabled: true,
        ),
      ),
      swapAnimationDuration: const Duration(milliseconds: 1500), // Animation duration
      swapAnimationCurve: Curves.easeInOut, // Animation curve
    );
  }

  Color _getColor(BuildContext context, int index) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    switch (index) {
      case 0:
        return isDarkTheme
            ? const Color.fromARGB(255, 131, 75, 204) // Dark theme color for Fixed Invoices
            : const Color.fromARGB(255, 95, 0, 130); // Light theme color for Fixed Invoices
      case 1:
        return isDarkTheme
            ? const Color.fromARGB(255, 51, 134, 88) // Dark theme color for Flexible Invoices
            : const Color.fromARGB(255, 0, 128, 0); // Light theme color for Flexible Invoices
      case 2:
        return isDarkTheme
            ? const Color.fromARGB(255, 194, 6, 252) // Dark theme color for Expired Invoices
            : const Color.fromARGB(255, 230, 0, 150); // Light theme color for Expired Invoices
      default:
        return Colors.grey;
    }
  }
}
