import 'package:learingdart/pie%20chart/individual_pie.dart';

class PieData {
  final List<int> invoiceCounts; // Accepts dynamic counts
  List<IndividualPie> pieData = [];

  PieData({required this.invoiceCounts});

  // Initialize pie data dynamically
  void initializePieData() {
    pieData = List.generate(
      invoiceCounts.length,
      (index) => IndividualPie(x: index, y: invoiceCounts[index]),
    );
  }
}
