import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting time

import '../../../utils/constants/colors.dart';
import '../../../utils/constants/text_strings.dart';
import '../../../utils/helpers/zoom_in_out_anim.dart';
import '../../dashboard/screen/dashboard.dart';
import '../../dashboard/widgets/custrom_drawer.dart';


class SalesactivityScreen extends StatefulWidget {
  const SalesactivityScreen({super.key});

  @override
  State<SalesactivityScreen> createState() => _SalesactivityScreenState();
}

class _SalesactivityScreenState extends State<SalesactivityScreen> {
  final List<Map<String, String>> _salesCalLog = [
    {
      "name": "Dr. John Doe",
      "salesrepresentative": "Aarav Maurya",
  "time": "10:30 AM",
      "callnotes": "It was a good call",

    },
    {
      "name": "Dr. Emily Smith",
      "salesrepresentative": "Aarav Maurya",
     "time": "11:15 AM",
      "callnotes": "Follow-up needed"

    },
    {
      "name": "Dr. Michael Brown",
      "salesrepresentative": "Aarav Maurya",
    "time": "12:00 PM",
      "callnotes": "Scheduled next meeting",

    },
  ];

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  void _showAddDoctorDialog() {
    TextEditingController nameController = TextEditingController();
    TextEditingController salesRepController = TextEditingController();
    TextEditingController callNotesController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ZoomInOutDialog(
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text(TTexts.salesActivityTitle),
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
                  controller: salesRepController,
                  decoration: const InputDecoration(
                    labelText: TTexts.salesRepresentative,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: callNotesController,
                  maxLines: 3, // Increased height
                  decoration: const InputDecoration(
                    labelText: TTexts.callNotes,
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
                      salesRepController.text.isNotEmpty &&
                      callNotesController.text.isNotEmpty) {

                    String formattedTime = DateFormat('hh:mm a').format(DateTime.now());

                    setState(() {
                      _salesCalLog.add({
                        "name": nameController.text,
                        "salesrepresentative": salesRepController.text,
                        "callnotes": callNotesController.text,
                        "time": formattedTime,
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
     /* appBar: AppBar(title: Text(TTexts.salesActivity),),
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

                      ],
                    ),
                    /*trailing: IconButton(
                      icon: const Icon(Icons.delete, color: TColors.primary),
                      onPressed: () => _showDeleteConfirmationDialog(index),
                    ),*/
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
