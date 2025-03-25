import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import 'package:provider/provider.dart';
import '../../../utils/constants/text_strings.dart';
import '../controllers/SalesController.dart';

class SalesactivityScreen extends StatefulWidget {
  const SalesactivityScreen({super.key});

  @override
  State<SalesactivityScreen> createState() => _SalesactivityScreenState();
}

class _SalesactivityScreenState extends State<SalesactivityScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SalesController>(context, listen: false).fetchSalesList().then((_) {
        setState(() {});
      });
    });
  }

  void _showAddDataDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController salesRepController = TextEditingController();
    final TextEditingController timeController = TextEditingController();
    final TextEditingController callNotesController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Add Sales Data"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Name"),
              ),
              TextField(
                controller: salesRepController,
                decoration: const InputDecoration(labelText: "Sales Rep"),
              ),
              TextField(
                controller: timeController,
                decoration: const InputDecoration(labelText: "Time"),
              ),
              TextField(
                controller: callNotesController,
                decoration: const InputDecoration(labelText: "Call Notes"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                Get.snackbar("Note", "This feature is in maintenance.");
                await Provider.of<SalesController>(context, listen: false).fetchSalesList();
                setState(() {});
                Navigator.pop(context);
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text("Add Data"),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: TColors.primary,
        onPressed: () => _showAddDataDialog(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Consumer<SalesController>(
        builder: (context, salesController, child) {
          if (salesController.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (salesController.salesList.isEmpty) {
            return const Center(child: Text("No Sales Data Available"));
          }

          final filteredSales = salesController.salesList
              .where((sale) => sale.doctorName.toLowerCase().contains(_searchQuery.toLowerCase()))
              .toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: TTexts.searchDoctor,
                    border: OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.search,color: TColors.primary,),
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
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredSales.length,
                  itemBuilder: (context, index) {
                    final sale = filteredSales[index];

                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.person, color: TColors.primary, size: 28),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    sale.doctorName ?? "Unknown Doctor",
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.business, color: TColors.primary, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "Sales Rep: ${sale.salesRep ?? "N/A"}",
                                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.comment, color: TColors.primary, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "Call Notes: ${sale.callNotes ?? "No notes"}",
                                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.person_outline, color: TColors.primary, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "User: ${sale.userName ?? "Unknown"}",
                                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today, color: TColors.primary, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "Date: ${sale.dateTime ?? "N/A"}",
                                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );


                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
