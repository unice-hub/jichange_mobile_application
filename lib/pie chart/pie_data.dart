import 'package:learingdart/pie%20chart/individual_pie.dart';

class PieData {
  final int fixedInvoices;
  final int flexibleInvoices;

  PieData({
    required this.fixedInvoices,
    required this.flexibleInvoices,
  });

  List<IndividualPie> pieData = [];

  // Initialize pie data
  void initializePieData() {
    pieData = [
      IndividualPie(x: 0, y: fixedInvoices),
      IndividualPie(x: 1, y: flexibleInvoices),
    ];
  }
}

