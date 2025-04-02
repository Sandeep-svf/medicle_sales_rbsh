import 'package:date_picker_plus/date_picker_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:medicle_sales_rbsh/features/visitDoctor/models/visitSalesData.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/text_strings.dart';
import '../../../utils/helpers/zoom_in_out_anim.dart';
import '../controllers/visitListController.dart';

class VisitDoctorScreen extends StatefulWidget {
  const VisitDoctorScreen({super.key});

  @override
  State<VisitDoctorScreen> createState() => _VisitDoctorScreenState();
}

class _VisitDoctorScreenState extends State<VisitDoctorScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  late VisitListController _visitListController;

  @override
  void initState() {
    super.initState();
    _visitListController = VisitListController();
    _visitListController.fetchSalesList(); // Fetch the visit data when screen loads
  }

  void _showAddDoctorDialog() {
    TextEditingController nameController = TextEditingController();
    TextEditingController dateController = TextEditingController();
    TextEditingController callNotesController = TextEditingController();
    String selectedDate = "";

    Future<void> _pickDate() async {
      final pickedDate = await showDatePickerDialog(
        context: context,
        minDate: DateTime(2020),
        maxDate: DateTime(2034),
        initialDate: DateTime.now(),
        selectedCellDecoration: const BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
        ),
        selectedCellTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        leadingDateTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        highlightColor: Colors.blue,
        splashColor: Colors.blueAccent,
        splashRadius: 20.0,
      );

      if (pickedDate != null) {
        setState(() {
          dateController.text =
          "${pickedDate.day}-${pickedDate.month}-${pickedDate.year}";
        });
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ZoomInOutDialog(
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text(TTexts.scheduleVisitTitle),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: TTexts.doctorName,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: dateController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: TTexts.date,
                    hintText: "Date (DD-MM-YYYY)",
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  onTap: _pickDate,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: callNotesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: TTexts.notes,
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(TTexts.cancel),
              ),
              ElevatedButton(
                onPressed: () {
                  if (nameController.text.isNotEmpty &&
                      dateController.text.isNotEmpty &&
                      callNotesController.text.isNotEmpty) {

                    String formattedTime = DateFormat('hh:mm a').format(DateTime.now());

                    setState(() {
                     /* _visitListController.salesList.add({
                        "name": nameController.text,
                        "time": formattedTime,
                        "callnotes": callNotesController.text,
                      });*/
                    });
                    Navigator.pop(context);
                  } else {
                    Get.snackbar("Error", "Field cannot be empty.");
                  }
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(TTexts.submit),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(TTexts.confirmDeletion),
          content: const Text(TTexts.areYouSureYouWantToDeleteThisLog),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(TTexts.no, style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _visitListController.salesList.removeAt(index);
                });
                Navigator.pop(context);
              },
              child: const Text(TTexts.yes),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<VisitSalesLogModel> filteredDoctors = _visitListController.salesList
        .where((doctor) =>
        doctor.doctor?.name?.toLowerCase().contains(_searchQuery.toLowerCase())??false)
        .toList();

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: TTexts.searchDoctor,
                border: OutlineInputBorder(),
                prefixIcon: const Icon(Icons.search,color: TColors.primary),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      _searchQuery = "";
                    });
                  },
                )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          Expanded(
            child: _visitListController.salesList.isEmpty
                ? const Center(child: Text(TTexts.noRecentCallAvailable))
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _visitListController.salesList.length,
              itemBuilder: (context, index) {
                final doctorVisit = _visitListController.salesList[index];

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    title: Text(
                      doctorVisit.doctor?.name ?? "Unknown Doctor",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Sales Rep: ${doctorVisit.user.name ?? ""}"),
                        Text("Time: ${DateFormat('hh:mm a').format(doctorVisit.date)}"),
                        Text("Call Notes: ${doctorVisit.notes ?? "No Notes"}"),
                        const SizedBox(height: TSizes.spaceBtwText),
                        Center(
                          child: ElevatedButton(
                            onPressed: doctorVisit.confirmed
                                ? null
                                : () {
                              setState(() {
                                doctorVisit.confirmed = true; // Mark as confirmed
                              });
                              QuickAlert.show(
                                context: context,
                                type: QuickAlertType.success,
                                text: TTexts.confirmVisitSuccessfullyMarked,
                                backgroundColor: TColors.primary,
                                confirmBtnColor: TColors.primary,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: doctorVisit.confirmed
                                  ? TColors.dark
                                  : TColors.primary,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0), // Horizontal padding
                              child: Text(
                                doctorVisit.confirmed
                                    ? TTexts.visitConfirmed
                                    : TTexts.confirmVisit,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          /* Expanded(
            child: filteredDoctors.isEmpty
                ? const Center(child: Text(TTexts.noRecentCallAvailable))
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredDoctors.length,
              itemBuilder: (context, index) {
                final doctor = filteredDoctors[index];

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    title: Text(
                      doctor["name"] ?? "",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Sales Rep: ${doctor["salesRep"] ?? ""}"),
                        Text("Time: ${doctor["time"] ?? ""}"),
                        Text("Call Notes: ${doctor["callnotes"] ?? ""}"),
                        const SizedBox( height: TSizes.spaceBtwText),
                        Center(
                          child: ElevatedButton(
                            onPressed: doctor["confirmed"] == "true"
                                ? null
                                : () {
                              setState(() {
                                doctor["confirmed"] = "true"; // Mark as confirmed
                              });
                              QuickAlert.show(
                                context: context,
                                type: QuickAlertType.success,
                                text: TTexts.confirmVisitSuccessfullyMarked,
                                backgroundColor: Colors.blue.shade50,
                                confirmBtnColor: Colors.blue,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: doctor["confirmed"] == "true"
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                            child: Text(
                              doctor["confirmed"] == "true"
                                  ? TTexts.visitConfirmed
                                  : TTexts.confirmVisit,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),*/
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDoctorDialog,
        backgroundColor: TColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
