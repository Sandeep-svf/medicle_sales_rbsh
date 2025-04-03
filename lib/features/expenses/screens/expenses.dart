import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:medicle_sales_rbsh/features/expenses/controllers/addExpenseController.dart';
import 'package:medicle_sales_rbsh/features/expenses/models/expanseModel.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/local_storage/auth_manager.dart';
import '../controllers/expenseController.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  late ExpenseController _expenseController;
  AuthManager authManager = AuthManager();
  AddExpenseController addExpenseController = AddExpenseController();

  // Declare a variable to store selected value from the dropdown
  String? selectedCategory ;

  // List of categories for the dropdown
  final List<String> categories = ['travel', 'meals', 'vehicle', 'other'];

  @override
  void initState() {
    super.initState();
    _expenseController = ExpenseController();
    _expenseController.fetchExpenses(); // Call fetchExpenses with userId
  }

  void _showAddExpenseDialog() {
    TextEditingController amountController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    final TextEditingController billController = TextEditingController();
    File? imageFile;

    final _formKey =
        GlobalKey<FormState>(); // Create a form key to validate the form

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Add Expense"),
          content: Form(
            key: _formKey, // Attach the form key to validate the form
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Amount field with validation
                TextFormField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: "Amount",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                // Description field with validation
                // Dropdown for category selection
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: "Category",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    // Validate that a category is selected
                    if (value == null || value == 'Please select') {
                      return 'Please select a category';
                    }
                    return null;
                  },
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedCategory = newValue;
                      descriptionController.text = newValue!; // Set the selected category to the descriptionController
                    });
                  },
                  items: categories.map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),

                // Description field
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 12),

                // Image Picker (optional)
                GestureDetector(
                  onTap: () async {
                    // Check for camera and photos permissions
                    await _requestPermission(Permission.camera);
                    await _requestPermission(Permission.photos);
                    await _requestPermission(Permission.storage);

                    if (await Permission.camera.isGranted &&
                        await Permission.photos.isGranted) {
                      _showImagePickerDialog(context, (pickedFile) {
                        if (pickedFile != null) {
                          setState(() {
                            imageFile = File(pickedFile.path);
                          });
                        }
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                "Permission Denied: Please allow camera and gallery permissions.")),
                      );
                    }
                  },
                  child: imageFile == null
                      ? const Icon(Icons.add_a_photo)
                      : Image.file(imageFile!, width: 100, height: 100),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                // Validate the form
                if (_formKey.currentState?.validate() ?? false) {


        // Call addExpense method when form is valid
        addExpenseController.addExpense(
          category: selectedCategory,
          amount: double.parse(amountController.text),
          description: descriptionController.text,
          bill: billController.text.isEmpty ? null : billController.text,
          context: context,
        );
                  Navigator.pop(context);
                } else {
                  /*ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text("Please fill out all required fields.")),
                  );*/
                }
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text("Submit"),
              ),
            ),
          ],
        );
      },
    );
  }

// Request permission for Camera and Photos
  Future<void> _requestPermission(Permission permission) async {
    final status = await permission.request();
    if (status != PermissionStatus.granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                "Permission Required: You need to allow permission to proceed.")),
      );
    }
  }

// Show Image Picker Dialog (Camera or Gallery)
  void _showImagePickerDialog(
      BuildContext context, Function(PickedFile?) onImagePicked) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Pick an Image"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text("Take a photo"),
                onTap: () async {
                  final picker = ImagePicker();
                  final pickedFile =
                      await picker.pickImage(source: ImageSource.camera);
                  onImagePicked(pickedFile as PickedFile?);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text("Pick from gallery"),
                onTap: () async {
                  final picker = ImagePicker();
                  final pickedFile =
                      await picker.pickImage(source: ImageSource.gallery);
                  onImagePicked(pickedFile as PickedFile?);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /* void _showAddExpenseDialog() {
    TextEditingController amountController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();

    final _formKey = GlobalKey<FormState>(); // Create a form key to validate the form

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Add Expense"),
          content: Form(
            key: _formKey, // Attach the form key to validate the form
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Amount field with validation
                TextFormField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: "Amount",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                // Description field with validation
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: "Description",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),




              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                // Validate the form
                if (_formKey.currentState?.validate() ?? false) {
                  // If the form is valid, you can process the data
                  // Here, we're just closing the dialog for now.
                  Navigator.pop(context);
                } else {
                  // Show a Snackbar if the form is invalid
                  Get.snackbar("Error", "Please fill out all fields.");
                }
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text("Submit"),
              ),
            ),
          ],
        );
      },
    );
  }*/

  @override
  Widget build(BuildContext context) {
    final ExpenseController _expenseController = ExpenseController();

    return Scaffold(
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
            child: FutureBuilder<List<Expense>>(
              future: _expenseController.fetchExpenses(), // Fetch data here
              builder: (BuildContext context,
                  AsyncSnapshot<List<Expense>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                      child: Text("No recent expenses available"));
                } else {
                  List<Expense> filteredExpenses = snapshot.data!
                      .where((expense) => expense.description
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase()))
                      .toList();

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredExpenses.length,
                    itemBuilder: (context, index) {
                      final expense = filteredExpenses[index];
                      String statusText = expense.status == "approved"
                          ? "Approved"
                          : expense.status == "pending"
                              ? "Pending"
                              : "Unknown";
                      Color statusColor = expense.status == "approved"
                          ? Colors.green
                          : expense.status == "pending"
                              ? Colors.orange
                              : Colors.grey;

                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "₹${expense.amount}",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                expense.description,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    statusText,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: statusColor,
                                    ),
                                  ),
                                  Text(
                                    DateFormat('dd/MM/yyyy')
                                        .format(expense.date),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddExpenseDialog,
        backgroundColor: TColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
