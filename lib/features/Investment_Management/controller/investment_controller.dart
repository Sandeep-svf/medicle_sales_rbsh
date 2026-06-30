import 'package:get/get.dart';

import '../enum.dart';
import '../model/investment_model.dart';

class InvestmentController extends GetxController {

  /// Toggle between Table & Card View
  final RxBool tableView = true.obs;

  /// Search Text
  final RxString search = "".obs;

  /// Investment List
  final RxList<InvestmentModel> investments = <InvestmentModel>[].obs;

  /// Filtered List
  List<InvestmentModel> get filteredInvestments {
    if (search.value.trim().isEmpty) {
      return investments;
    }

    final keyword = search.value.toLowerCase();

    return investments.where((investment) {
      return investment.doctorName.toLowerCase().contains(keyword) ||
          investment.type.toLowerCase().contains(keyword) ||
          investment.purpose.toLowerCase().contains(keyword) ||
          investment.amount.toString().contains(keyword);
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    loadDummy();
  }

  /// Change Table / Card View
  void toggleView(bool value) {
    tableView.value = value;
  }

  /// Clear Search
  void clearSearch() {
    search.value = "";
  }

  /// Dummy Data
  void loadDummy() {
    investments.assignAll([
      InvestmentModel(
        id: "1",
        doctorName: "Dr. Meenakshi Rao",
        type: "Cash",
        amount: 5000,
        submittedDate: DateTime(2025, 6, 16),
        purpose: "Quarterly Clinic Support",
        status: InvestmentStatus.pending,
      ),

      InvestmentModel(
        id: "2",
        doctorName: "Dr. Sharma",
        type: "NEFT",
        amount: 15000,
        submittedDate: DateTime(2025, 6, 14),
        purpose: "CME Speaker Honorarium",
        status: InvestmentStatus.approved,
        //
      ),

      InvestmentModel(
        id: "3",
        doctorName: "Dr. Khan",
        type: "Item Gift",
        amount: 2400,
        submittedDate: DateTime(2025, 6, 11),
        purpose: "Derm Atlas",
        status: InvestmentStatus.paid,
       // 
      ),

      InvestmentModel(
        id: "4",
        doctorName: "Dr. Tyagi",
        type: "Cash",
        amount: 8000,
        submittedDate: DateTime(2025, 6, 9),
        purpose: "Quarterly Support",
        status: InvestmentStatus.rejected,
        
      ),
      InvestmentModel(
        id: "1",
        doctorName: "Dr. Meenakshi Rao",
        type: "Cash",
        amount: 5000,
        submittedDate: DateTime(2025, 6, 16),
        purpose: "Quarterly Clinic Support",
        status: InvestmentStatus.pending,
      ),

      InvestmentModel(
        id: "2",
        doctorName: "Dr. Sharma",
        type: "NEFT",
        amount: 15000,
        submittedDate: DateTime(2025, 6, 14),
        purpose: "CME Speaker Honorarium",
        status: InvestmentStatus.approved,
        
      ),

      InvestmentModel(
        id: "3",
        doctorName: "Dr. Khan",
        type: "Item Gift",
        amount: 2400,
        submittedDate: DateTime(2025, 6, 11),
        purpose: "Derm Atlas",
        status: InvestmentStatus.paid,
        
      ),

      InvestmentModel(
        id: "4",
        doctorName: "Dr. Tyagi",
        type: "Cash",
        amount: 8000,
        submittedDate: DateTime(2025, 6, 9),
        purpose: "Quarterly Support",
        status: InvestmentStatus.rejected,
        
      ),
      InvestmentModel(
        id: "1",
        doctorName: "Dr. Meenakshi Rao",
        type: "Cash",
        amount: 5000,
        submittedDate: DateTime(2025, 6, 16),
        purpose: "Quarterly Clinic Support",
        status: InvestmentStatus.pending,
      ),

      InvestmentModel(
        id: "2",
        doctorName: "Dr. Sharma",
        type: "NEFT",
        amount: 15000,
        submittedDate: DateTime(2025, 6, 14),
        purpose: "CME Speaker Honorarium",
        status: InvestmentStatus.approved,
        
      ),

      InvestmentModel(
        id: "3",
        doctorName: "Dr. Khan",
        type: "Item Gift",
        amount: 2400,
        submittedDate: DateTime(2025, 6, 11),
        purpose: "Derm Atlas",
        status: InvestmentStatus.paid,
        
      ),

      InvestmentModel(
        id: "4",
        doctorName: "Dr. Tyagi",
        type: "Cash",
        amount: 8000,
        submittedDate: DateTime(2025, 6, 9),
        purpose: "Quarterly Support",
        status: InvestmentStatus.rejected,
        
      ),
    ]);
  }
}