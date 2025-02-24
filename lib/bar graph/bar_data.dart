import 'package:learingdart/bar%20graph/individual_bar.dart';

class BarData {
  final double pendingAmount;
  final double dueAmount;
  final double expiredAmount;

  BarData({
    required this.pendingAmount,
    required this.dueAmount,
    required this.expiredAmount,
  });

  List<IndividualBar> barData = [];

  // Initialize bar data
  void initializeBarData() {
    barData = [
      // Pending
      IndividualBar(x: 0, y: pendingAmount),
      // Due
      IndividualBar(x: 1, y: dueAmount),
      // Expired
      IndividualBar(x: 2, y: expiredAmount),
    ];
  }
}
