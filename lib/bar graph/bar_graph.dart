// ignore_for_file: deprecated_member_use

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:learingdart/bar%20graph/bar_data.dart';

class MyBarGraph extends StatelessWidget {
  final List weeklySummary; //[pendingAmount, dueAmount, expiredAmount]

  const MyBarGraph({
    super.key,
    required this.weeklySummary,
  });

  @override
  Widget build(BuildContext context) {
    // Find the maximum value in weeklySummary and round it up to the nearest 10
    double maxSummaryValue = weeklySummary.reduce((a, b) => a > b ? a : b);
    double maxY = (maxSummaryValue / 10).ceil() * 10 + 10;  // Round up to nearest 10

    // Initialize bar data
    BarData myBarData = BarData(
      pendingAmount: weeklySummary[0],
      dueAmount: weeklySummary[1],
      expiredAmount: weeklySummary[2],
    );
    myBarData.initializeBarData();

    return BarChart(
      BarChartData(
        maxY: maxY,
        minY: 0,
        // Removing grid
        gridData: const FlGridData(show: true),
        // Removing border
        borderData: FlBorderData(show: true),
        // Adding titles
        titlesData: FlTitlesData(
          show: true,
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            axisNameWidget: Padding(
              padding: const EdgeInsets.only(left: 10.0),  // Add padding for left axis title
              child: Text(
                'Total',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,  // Adjust text color based on the theme
                ),
              ),
            ),
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,  // Increase reserved size to accommodate 5 digits
              getTitlesWidget: (value, meta) {
                const style = TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                );
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 10,  // Add space to give padding between titles and chart
                  child: Text(value.toInt().toString(), style: style),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            axisNameWidget: Padding(
              padding: const EdgeInsets.only(top: 1),  // Add padding for bottom axis title
              child: Text(
                'Status',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,  // Adjust text color based on the theme
                ),
              ),
            ),
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: getBottomTitles,
            ),
          ),
        ),
        barGroups: myBarData.barData
            .map(
              (data) => BarChartGroupData(
                x: data.x,
                barRods: [
                  BarChartRodData(
                    toY: data.y,
                    color: _getColor(data.x, context),  // Use theme-based color
                    width: 95,
                    borderRadius: BorderRadius.circular(4),
                    backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      toY: maxY,  // Set based on dynamic maxY
                      color: Colors.grey[200],
                    ),
                  ),
                ],
              ),
            )
            .toList(),
        // Enable animation
        alignment: BarChartAlignment.spaceAround,
        barTouchData: BarTouchData(enabled: true),
      ),
      // Add animation duration and curve
      swapAnimationDuration: const Duration(milliseconds: 1500), // Animation duration
      swapAnimationCurve: Curves.easeInOut, // Animation curve
    );
  }

  Color _getColor(int index, BuildContext context) {
    switch (index) {
      case 0:
        return Theme.of(context).brightness == Brightness.dark
            ? Colors.purple.shade300 // Dark theme color for Fixed Invoices
            : Colors.purple.shade700; // Light theme color for Fixed Invoices
      case 1:
        return Theme.of(context).brightness == Brightness.dark
            ? Colors.blue.shade300 // Dark theme color for Flexible Invoices
            : Colors.blue.shade700; // Light theme color for Flexible Invoices
      case 2:
        return Theme.of(context).brightness == Brightness.dark
            ? Colors.green.shade300 // Dark theme color for Expired Invoices
            : Colors.green.shade700; // Light theme color for Expired Invoices
      default:
        return Colors.grey;
    }
  }

  Widget getBottomTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    Widget text;
    switch (value.toInt()) {
      case 0:
        text = const Text('Pending', style: style);
        break;
      case 1:
        text = const Text('Due', style: style);
        break;
      case 2:
        text = const Text('Expired', style: style);
        break;
      default:
        text = const Text('', style: style);
        break;
    }

    return SideTitleWidget(axisSide: meta.axisSide, space: 10, child: text);
  }
}
