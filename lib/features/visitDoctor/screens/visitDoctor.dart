import 'package:date_picker_plus/date_picker_plus.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medicle_sales_rbsh/features/dashboard/widgets/custrom_drawer.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/text_strings.dart';
import '../../../utils/helpers/zoom_in_out_anim.dart';
import '../../dashboard/screen/dashboard.dart';

class VisitDoctorScreen extends StatefulWidget {
  const VisitDoctorScreen({super.key});

  @override
  State<VisitDoctorScreen> createState() => _VisitDoctorScreenState();
}

class _VisitDoctorScreenState extends State<VisitDoctorScreen> {
  final List<Map<String, String>> _salesCalLog = [
    {
      "name": "Dr. John Doe",
      "time": "10:30 AM",
      "callnotes": "It was a good call",
    },
    {
      "name": "Dr. Emily Smith",
      "time": "11:15 AM",
      "callnotes": "Follow-up needed"
    },
    {
      "name": "Dr. Michael Brown",
      "time": "12:00 PM",
      "callnotes": "Scheduled next meeting",
    },
  ];

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  void _showAddDoctorDialog() {
    TextEditingController nameController = TextEditingController();
    TextEditingController dateController = TextEditingController();
    TextEditingController callNotesController = TextEditingController();
    String selectedDate = "";

    Future<void> _pickDate() async {
      final pickedDate = await showDatePickerDialog(
        context: context,
        minDate: DateTime(2020),
        maxDate: DateTime(2034), // Increased maxDate to avoid the issue
        initialDate: DateTime.now(), // Set initial date to today
        selectedCellDecoration: const BoxDecoration(
          color: Colors.blue, // Selected date background color
          shape: BoxShape.circle,
        ),
        selectedCellTextStyle: const TextStyle(
          color: Colors.white, // Selected date text color
          fontWeight: FontWeight.bold,
        ),
        leadingDateTextStyle: const TextStyle(
          color: Colors.white, // Month & Year text color
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        highlightColor: Colors.blue, // Highlight color for the selected area
        splashColor: Colors.blueAccent, // Splash effect color
        splashRadius: 20.0, // Radius for the ripple effect

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
                    labelText: TTexts.date, // Keeping the same label
                    hintText: "Date (DD-MM-YYYY)", // Hint text added
                    border: OutlineInputBorder(), // Same border style
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  onTap: _pickDate,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: callNotesController,
                  maxLines: 3, // Increased height
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
                      _salesCalLog.add({
                        "name": nameController.text,
                        "time": formattedTime,
                        "callnotes": callNotesController.text,

                      });
                    });
                    Navigator.pop(context);
                  }
                },
                child: const Text(TTexts.submit),
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
                  _salesCalLog.removeAt(index);
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
    List<Map<String, String>> filteredDoctors = _salesCalLog
        .where((doctor) =>
        doctor["name"]!.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
     /* appBar: AppBar(title: Text(TTexts.doctorVisit),),
      drawer: CustomDrawer(
        onMenuSelected: (screen){
          // This will ensure navigation happens within the drawer structure
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => DashboardScreen()
          ));
        },
      ),*/
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: TTexts.searchDoctor,
                border: OutlineInputBorder(),
                prefixIcon: const Icon(Icons.search),
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
                        Text("Sales Rep: ${doctor["salesrepresentative"] ?? ""}"),
                        Text("Time: ${doctor["time"] ?? ""}"),
                        Text("Call Notes: ${doctor["callnotes"] ?? ""}"),

                        const SizedBox( height: TSizes.spaceBtwText),
                        Center(
                          child: SizedBox(

                            child: ElevatedButton(onPressed: (){
                              QuickAlert.show(
                                context: context,
                                type: QuickAlertType.success,
                                text: TTexts.confirmVisitSuccessfullyMarked,
                                backgroundColor: Colors.blue.shade50, // Light blue background
                                confirmBtnColor: Colors.blue, // Blue confirm button

                              );
                            }, child:
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20), // Left & Right Margin
                              child: Text(TTexts.confirmVisit,
                              ),
                            )),
                          ),
                        ),
                      ],
                    ),




                  ),
                );
              },
            ),
          ),
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
