import 'package:flutter/material.dart';
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
      Provider.of<SalesController>(context, listen: false).fetchSalesList();
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
                // Call your API to add data
                await Provider.of<SalesController>(context, listen: false).addSalesData(
                  nameController.text,
                  salesRepController.text,
                  timeController.text,
                  callNotesController.text,
                );

                // Refresh the list after adding new data
                await Provider.of<SalesController>(context, listen: false).fetchSalesList();

                Navigator.pop(context);
              },
              child: const Text("Add Data"),
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
        onPressed: () => _showAddDataDialog(context),
        child: const Icon(Icons.add),
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
              .where((sale) => sale.name.toLowerCase().contains(_searchQuery.toLowerCase()))
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
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredSales.length,
                  itemBuilder: (context, index) {
                    final sale = filteredSales[index];

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        title: Text(
                          sale.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Sales Rep: ${sale.salesRepresentative}"),
                            Text("Time: ${sale.time}"),
                            Text("Call Notes: ${sale.callNotes}"),
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
