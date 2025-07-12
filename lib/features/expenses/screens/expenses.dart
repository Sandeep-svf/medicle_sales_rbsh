import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:medicle_sales_rbsh/features/expenses/screens/TravelExpenseScreen.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:printing/printing.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/local_storage/auth_manager.dart';
import '../controllers/addExpenseController.dart';
import '../controllers/expenseController.dart';
import '../models/NewExpenseModel.dart';
import '../models/expanseModel.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  bool _isLoadingExpenses = true;
  bool _isGeneratingPdf = false;

  final TextEditingController _searchController = TextEditingController();
  DateTime _normalize(DateTime d) => DateTime(d.year, d.month, d.day);
  String _searchQuery = "";
  String? base64Image;
  late ExpenseController _expenseController;
  final AuthManager authManager = AuthManager();
  final AddExpenseController addExpenseController = AddExpenseController();

  final List<String> categories = ['travel'];
  String? selectedCategory;
  String? userId;
  List<ExpenseModel> _allExpenses = [];


  DateTime? fromDate;
  DateTime? toDate;

  @override
  void initState() {
    super.initState();
    _expenseController = ExpenseController();
    _initialize();

  }

  void _initialize() async {
    setState(() {
      _isLoadingExpenses = true;
    });
    AuthManager authManager = AuthManager();
    userId = await authManager.getUserId();
    final data = await _expenseController.fetchExpenses();
    setState(() {
      _allExpenses = data;
      _isLoadingExpenses = false;
    });
  }


  void _pickDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        fromDate = picked.start;
        toDate = picked.end;
      });
    }
  }

  void _applyQuickFilter(Duration duration) {
    setState(() {
      toDate = DateTime.now();
      fromDate = toDate!.subtract(duration);
    });
  }

  List<ExpenseModel> _filterExpenses(List<ExpenseModel> expenses) {
    return expenses.where((e) {
      final matchesSearch = e.description.toLowerCase().contains(_searchQuery.toLowerCase());

      if (fromDate == null || toDate == null) return matchesSearch;

      final entryDate = _normalize(e.date);
      final from = _normalize(fromDate!);
      final to = _normalize(toDate!);

      final withinRange = (entryDate.isAtSameMomentAs(from) || entryDate.isAfter(from)) &&
          (entryDate.isAtSameMomentAs(to) || entryDate.isBefore(to));

      return matchesSearch && withinRange;
    }).toList();
  }

  Future<void> _generatePdf(List<ExpenseModel> expenses) async {
    setState(() => _isGeneratingPdf = true);
    final pdf = pw.Document();

    // 💰 Calculate total fare
    double totalAmount = expenses.fold(0.0, (sum, item) => sum + item.amount);
    String userId = expenses.isNotEmpty ? expenses.first.user : 'Unknown';

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Text("Expense Statement", style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          // ✅ Show user ID above the date
          pw.Text("User ID: $userId", style: pw.TextStyle(fontSize: 12)),
          pw.SizedBox(height: 5),
          pw.Text(
            "Date: ${DateFormat('dd MMM yyyy').format(DateTime.now())}",
            style: pw.TextStyle(fontSize: 12),
          ),
          pw.SizedBox(height: 10),

          pw.Table.fromTextArray(
            headers: ['Date', 'Category', 'Amount', 'Description', 'From / To', 'Distance (km)', 'Status'],
            cellAlignment: pw.Alignment.centerLeft,
            cellStyle: const pw.TextStyle(fontSize: 10),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            columnWidths: {
              0: const pw.FixedColumnWidth(60),
              1: const pw.FixedColumnWidth(50),
              2: const pw.FixedColumnWidth(55),
              3: const pw.FixedColumnWidth(120),
              4: const pw.FixedColumnWidth(110),
              5: const pw.FixedColumnWidth(60),
              6: const pw.FixedColumnWidth(50),
            },
            data: expenses.map((e) {
              String route = '';
              String distance = '';

              if (e.category == 'travel' && e.travelDetails != null && e.travelDetails.isNotEmpty) {
                route = e.travelDetails.map((t) => "${t.from} --> ${t.to}").join(", ");
                distance = e.travelDetails.map((t) => t.km.toString()).join(" + ");
              } else if (e.category == 'daily') {
                route = (e.dailyAllowanceType == 'headoffice')
                    ? 'Headquarter'
                    : (e.dailyAllowanceType == 'outside' ? 'Other Headquarter' : '-');
                distance = '-';
              }

              return [
                DateFormat('dd MMM').format(e.date),
                e.category,
                e.amount.toStringAsFixed(2),
                e.description.length > 30 ? '${e.description.substring(0, 28)}…' : e.description,
                route.length > 40 ? '${route.substring(0, 38)}…' : route,
                distance,
                e.status,
              ];
            }).toList(),
          ),

          pw.SizedBox(height: 20),

          //  Total fare line
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Text(
                "Total Fare: INR ${totalAmount.toStringAsFixed(2)}",
                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
    if (mounted) {
      setState(() => _isGeneratingPdf = false);
    }
  }




  /*Future<void> _generatePdf(List<ExpenseModel> expenses) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Text("Expense Statement", style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.Table.fromTextArray(
            headers: ['Date', 'Category', 'Amount', 'Description', 'Status'],
            data: expenses.map((e) => [
              DateFormat('dd MMM yyyy').format(e.date),
              e.category,
              '₹${e.amount.toStringAsFixed(2)}',
              e.description,
              e.status,
            ]).toList(),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }*/

  void _showAddExpenseDialog() {
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();
    final fromController = TextEditingController();
    final toController = TextEditingController();
    final distanceController = TextEditingController();
    File? imageFile;

    final formKey = GlobalKey<FormState>();
    String tripType = 'One Way';
    const farePerKm = 2.4;
    int distanceKm = 0;
    String? selectedDAType;
    String fareDisplayText = '';

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, void Function(void Function()) setModalState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text("Add Expense"),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DropdownButtonFormField<String>(
                          value: selectedCategory,
                          decoration: const InputDecoration(labelText: "Category", border: OutlineInputBorder()),
                          items: ['Travel Allowance', 'Daily Allowance']
                              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                              .toList(),
                          onChanged: (val) => setModalState(() => selectedCategory = val),
                          validator: (val) => val == null ? 'Please select a category' : null,
                        ),
                        const SizedBox(height: 12),

                        if (selectedCategory == 'Travel Allowance') ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Trip Type: "),
                              DropdownButton<String>(
                                value: tripType,
                                items: ['One Way', 'Round Trip']
                                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                                    .toList(),
                                onChanged: (val) => setModalState(() {
                                  tripType = val!;
                                  fareDisplayText = '';
                                  amountController.clear();
                                }),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: fromController,
                            decoration: const InputDecoration(labelText: 'From Location', border: OutlineInputBorder()),
                            validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: toController,
                            decoration: const InputDecoration(labelText: 'To Location', border: OutlineInputBorder()),
                            validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: distanceController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            decoration: const InputDecoration(labelText: 'Distance (km)', border: OutlineInputBorder()),
                            validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () {
                              if (distanceController.text.isEmpty) return;
                              distanceKm = int.tryParse(distanceController.text) ?? 0;
                              final multiplier = (tripType == 'Round Trip') ? 2 : 1;
                              final amount = distanceKm * farePerKm * multiplier;
                              setModalState(() {
                                amountController.text = amount.toStringAsFixed(2);
                                descriptionController.text =
                                'Travel from ${fromController.text} to ${toController.text} ($tripType)';
                                fareDisplayText = "Fare: ₹${amount.toStringAsFixed(2)} for $distanceKm km ($tripType)";
                              });
                            },
                            child: const Text("Calculate Fare"),
                          ),
                          if (fareDisplayText.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(fareDisplayText, style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                          const SizedBox(height: 12),

                          GestureDetector(
                            onTap: () async {
                              await _requestPermission(Permission.camera);
                              final picker = ImagePicker();
                              final picked = await picker.pickImage(source: ImageSource.camera);
                              if (picked != null) setModalState(() => imageFile = File(picked.path));
                            },
                            child: imageFile == null
                                ? const Icon(Icons.add_a_photo, size: 40)
                                : Image.file(imageFile!, width: 100),
                          ),
                          const SizedBox(height: 12),
                        ] else if (selectedCategory == 'Daily Allowance') ...[
                          DropdownButtonFormField<String>(
                            decoration: const InputDecoration(labelText: "Select DA Location", border: OutlineInputBorder()),
                            value: selectedDAType,
                            items: ['Other Headquarter', 'Headquarter']
                                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                                .toList(),
                            onChanged: (val) => setModalState(() {
                              selectedDAType = val!;
                              if (val == 'X Headquarter') {
                                amountController.text = '175.00';
                                descriptionController.text = 'DA for X Headquarter';
                              } else {
                                amountController.text = '150.00';
                                descriptionController.text = 'DA for Headquarter';
                              }
                            }),
                            validator: (val) => val == null ? 'Required' : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: amountController,
                            readOnly: true,
                            decoration: const InputDecoration(labelText: "Amount", border: OutlineInputBorder()),
                            validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState?.validate() ?? false) {
                      addExpenseController.addExpense(
                        category: selectedCategory!,
                        amount: double.parse(amountController.text),
                        description: descriptionController.text,
                        bill: null,
                        context: context,
                      ).then((_) async {
                        await _expenseController.fetchExpenses();
                        setState(() {});
                        Navigator.pop(context);
                      });
                    }
                  },
                  child: const Text("Submit"),
                )
              ],
            );
          },
        );
      },
    );
  }


  Future<void> _requestPermission(Permission permission) async {
    final status = await permission.request();
    if (status != PermissionStatus.granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Permission Required: $permission")),
      );
    }
  }

  void _showEditDialog(ExpenseModel expense) {
    final TextEditingController amountController =
    TextEditingController(text: expense.amount.toString());
    final TextEditingController descriptionController =
    TextEditingController(text: expense.description);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Expense'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              debugPrint("Update Expense ID: ${expense.id}");
              debugPrint("New Amount: ${amountController.text}");
              debugPrint("New Description: ${descriptionController.text}");
              Navigator.pop(context);
            },
            child: const Text("Update"),
          )
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final refreshed = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddAllowanceScreen()),
          );

          if (refreshed == true) {
            _initialize(); // This will re-fetch and refresh the list
          }
        },
        backgroundColor: TColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: "Search Expenses",
                border: OutlineInputBorder(),
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickDateRange(context),
                        icon: const Icon(Icons.date_range),
                        label: Text(
                          fromDate == null || toDate == null
                              ? "Select Date Range"
                              : "${DateFormat('dd MMM').format(fromDate!)} - ${DateFormat('dd MMM yyyy').format(toDate!)}",
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final data = await _expenseController.fetchExpenses();
                        final filtered = _filterExpenses(data);
                        await _generatePdf(filtered);
                      },
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text("Download PDF"),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text("Last 7 Days"),
                      selected: false,
                      onSelected: (_) => _applyQuickFilter(const Duration(days: 7)),
                    ),
                    ChoiceChip(
                      label: const Text("Last 1 Month"),
                      selected: false,
                      onSelected: (_) => _applyQuickFilter(const Duration(days: 30)),
                    ),
                    ChoiceChip(
                      label: const Text("Last 6 Months"),
                      selected: false,
                      onSelected: (_) => _applyQuickFilter(const Duration(days: 180)),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: _isLoadingExpenses
                ? const Center(child: CircularProgressIndicator())
                : _filterExpenses(_allExpenses).isEmpty
                ? const Center(child: Text("No expenses available"))
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filterExpenses(_allExpenses).length,
              itemBuilder: (_, i) {
                final e = _filterExpenses(_allExpenses)[i];
                final color = e.status == 'approved'
                    ? Colors.green
                    : e.status == 'pending'
                    ? Colors.orange
                    : Colors.red;

                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Header Row with Amount, Status, Edit
                        Row(
                          children: [
                            Text(
                              "₹${e.amount}",
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Text(
                                e.status.capitalizeFirst ?? '',
                                style: TextStyle(color: color, fontWeight: FontWeight.w500),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blueAccent),
                              tooltip: "Edit Expense",
                                onPressed: () async {
                                  if (e.editCount >= 1) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Expense is already edited. You cannot edit it more than once."),
                                        backgroundColor: Colors.orange,
                                      ),
                                    );
                                    return;
                                  }
                                  final Map<String, dynamic> existingData = {
                                    'userId': userId,
                                    'category': e.category,
                                    'description': e.description,
                                    'bill': '',
                                    if (e.category == 'travel' && e.travelDetails != null)
                                      'travelDetails': e.travelDetails.map((t) => {
                                        'from': t.from,
                                        'to': t.to,
                                        'km': t.km,
                                      }).toList(),
                                    if (e.category == 'daily')
                                      'dailyAllowanceType': e.dailyAllowanceType,
                                  };

                                  final shouldRefresh = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => AddAllowanceScreen(
                                        isEditMode: true,
                                        expenseId: e.id,
                                        existingData: existingData,
                                      ),
                                    ),
                                  );

                                  if (shouldRefresh == true) {
                                    _initialize(); // Refresh the list after editing
                                  }
                                }

                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        /// Description
                        Text(
                          e.description,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),

                        const SizedBox(height: 8),

                        /// Date row
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                            const SizedBox(width: 6),
                            Text(
                              DateFormat('dd MMM yyyy').format(e.date),
                              style: const TextStyle(fontSize: 13, color: Colors.grey),
                            ),
                          ],
                        ),

                        /// Travel Breakdown
                        if (e.travelDetails != null && e.travelDetails.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          const Divider(thickness: 1),
                          const Text("Travel Details", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          const SizedBox(height: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: e.travelDetails.map((trip) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text("• ${trip.from} → ${trip.to}  |  ${trip.km} km"),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Rate/km: ₹${e.ratePerKm}", style: const TextStyle(fontSize: 13)),
                              Text("Total Distance: ${e.totalDistanceKm} km", style: const TextStyle(fontSize: 13)),
                            ],
                          ),
                        ]
                      ],
                    ),
                  ),
                );
              },
            ),
          )

        ],
      ),
    );
  }
}
