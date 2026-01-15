import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../utils/check_internet/network_monitor.dart';
import '../../../utils/local_storage/auth_manager.dart';
import '../../authentication/models/UserModel.dart';
import '../../dashboard/widgets/LiveClockWidget.dart';
import '../../ticket/controller/TicketController.dart';
import '../controller/DashboardController.dart';
import '../model/SalesChartDashboardModel.dart';
import 'package:get/get.dart';

class SalesChartHomeScreen extends StatelessWidget {




  @override
  Widget build(BuildContext context) {
    // Access the controller via GetX
    final DashboardController dashboardController = Get.find();
    Get.put(TicketController());
    return Obx(() {
      if (dashboardController.isLoading.value) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: Center(child: CircularProgressIndicator()),
        );
      }

      final dashboardData = dashboardController.dashboardData.value;

      if (dashboardData == null) {
        return const Scaffold(
          backgroundColor: Colors.white,
          body: Center(child: Text("No data available")),
        );
      }

      final user = dashboardData?.data?.user;
      final period = dashboardData?.data?.period;
      final visits = dashboardData?.data?.visits;
      final expenses = dashboardData?.data?.expenses;
      final targets = dashboardData?.data?.targets;
      final summary = dashboardData?.data?.summary;


      return Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              // User Info
              FutureBuilder<UserModel?>(
                future: AuthManager().getUserData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data?.user == null) {
                    return const Text("No user data found");
                  }

                  final user = snapshot.data!.user!; // safe to use now

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.05),
                      border: Border.all(color: Colors.red, width: 1),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left: Welcome + Name + Email
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "👋 ${ user.name ?? "No Name"} ",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.red.shade800,
                              ),
                            ),

                            const SizedBox(height: 4),
                           /* Text(
                              user.email ?? "No Email",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),*/
                          ],
                        ),

                        // Right: Date + Time
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const LiveClockWidget(),
                            const SizedBox(height: 10),
                            networkStatusRow(),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 15),
              // Visits Summary
              Row(
                children: [
                  _animatedProgressCard(
                      "Doctor Visits",
                      visits?.doctor?.confirmed ?? 0,
                      visits?.doctor?.total ?? 0
                  ),
                  _animatedProgressCard(
                      "Chemist Visits",
                      visits?.chemist?.confirmed ?? 0,
                      visits?.chemist?.total ?? 0
                  ),
                  _animatedProgressCard(
                      "Stockist Visits",
                      visits?.stockist?.confirmed ?? 0,
                      visits?.stockist?.total ?? 0
                  ),
                ],
              ),
              SizedBox(height: 24),
              _monthlyTargetSummary(targets ?? Targets()), // Add a fallback value
              SizedBox(height: 24),
              _todayAppointmentsSummary(visits ?? Visits()), // Add a fallback value
              SizedBox(height: 24),
              _sectionTitle("Expense Summary"),
              _todaySummary(expenses ?? Expenses()), // Add a fallback value
            ],
          ),
        ),
      );
    });
  }

  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _animatedProgressCard(String title, int done, int total) {
    // Ensure no division by zero occurs
    double progress = total > 0 ? done / total : 0.0;  // Safe division check

    return Expanded(
      child: Card(
        margin: EdgeInsets.all(6),
        elevation: 2,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              CircularProgressIndicator(
                value: progress,  // Safe progress value
                color: Colors.red,
                strokeWidth: 6,
                backgroundColor: Colors.red.withOpacity(0.2),
              ),
              SizedBox(height: 8),
              Text('$done / $total'),
              Text('${total - done} Remaining'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _todaySummary(Expenses expenses) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statusCircle("Pending", expenses.pending ?? 0, Colors.orange),
              _statusCircle("Approved", expenses.approved ?? 0, Colors.green),
              _statusCircle("Rejected", expenses.rejected ?? 0, Colors.red),
            ],
          ),
          SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _monthlyTargetSummary(Targets targets) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Monthly Sales Targets", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statusCircle("Target", targets.monthlyTarget ?? 0, Colors.deepPurple),
              _statusCircle("Achieved", targets.achieved ?? 0, Colors.green),
              _statusCircle("Left", targets.remaining ?? 0, Colors.orange),
            ],
          ),
          SizedBox(height: 12),
          Divider(thickness: 1),
          _summaryItem("Target Amount", "₹ ${targets.monthlyTarget}"),
          SizedBox(height: 8),
          _summaryItem("Achieved Amount", "₹ ${targets.achieved}"),
          SizedBox(height: 8),
          _summaryItem("Remaining", "₹ ${targets.remaining}"),
        ],
      ),
    );
  }

  Widget _statusCircle(String label, int count, Color color) {
    // Convert the count to a string
    String countText = count.toString();

    // Calculate the text width based on the count's string length
    double textWidth = countText.length * 20.0; // Adjust the multiplier to scale the circle size
    double circleRadius = textWidth > 50 ? textWidth / 2 : 26.0; // Minimum radius of 26, adjust as needed

    return Column(
      children: [
        CircleAvatar(
          radius: circleRadius, // Dynamically adjust the circle size
          backgroundColor: color.withOpacity(0.2),
          child: Text(
            countText,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _summaryItem(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(fontSize: 13)),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _todayAppointmentsSummary(Visits visits) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Today's Scheduled Appointments", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _appointmentIconCircle("Doctors", visits.doctor?.total ?? 0, Colors.blueAccent),
              _appointmentIconCircle("Chemists", visits.chemist?.total ?? 0, Colors.indigo),
              _appointmentIconCircle("Stockists", visits.stockist?.total ?? 0, Colors.teal),
            ],
          ),
          const SizedBox(height: 12),
          Divider(thickness: 1),
          _summaryItem("Total Scheduled Today", "${visits.total ?? 0}"),
        ],
      ),
    );
  }

  Widget _appointmentIconCircle(String label, int count, Color color) {
    return Column(
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: color.withOpacity(0.2),
          child: Icon(Icons.calendar_today, color: color),
        ),
        const SizedBox(height: 6),
        Text("$count $label", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget networkStatusRow() {
    final monitor = NetworkMonitor();

    return ValueListenableBuilder<bool>(
      valueListenable: monitor.isOnline,
      builder: (context, isOnline, _) {
        return Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isOnline ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              isOnline ? 'Online' : 'Offline',
              style: TextStyle(
                fontSize: 12,
                color: isOnline ? Colors.green : Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      },
    );
  }

}




/*class SalesChartHomeScreen extends StatefulWidget {
  @override
  _SalesChartHomeScreenState createState() => _SalesChartHomeScreenState();
}

class _SalesChartHomeScreenState extends State<SalesChartHomeScreen> {
  late DashboardController _dashboardController;
  AuthManager authManager = AuthManager();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Access the controller and user data via Provider
    _dashboardController = Provider.of<DashboardController>(context);

    // Check if the data is still loading
    if (_dashboardController.isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // If data has been fetched, use it
    final dashboardData = _dashboardController.dashboardData?.data;

    if (dashboardData == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: Text("No data available")),
      );
    }

    final user = dashboardData.user!;
    final period = dashboardData.period!;
    final visits = dashboardData.visits!;
    final sales = dashboardData.sales!;
    final expenses = dashboardData.expenses!;
    final targets = dashboardData.targets!;
    final summary = dashboardData.summary!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // User Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.red, width: 1),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FutureBuilder<UserModel?>(
                    future: authManager.getUserData(), // your function
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data?.user == null) {
                        return const Text("No user data found");
                      }

                      final user = snapshot.data!.user!; // safe to use now

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.red, width: 1),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                          // Left: Welcome + Name + Email
                          Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "👋 Welcome",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.red.shade800,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              user.name, // ✅ from SharedPreferences
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user.email, // ✅ from SharedPreferences
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),

                        // Right: Date + Time
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                            Text(
                            DateFormat('dd MMM yyyy').format(DateTime.now()),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),

                      ],
                      ),
                      ],
                      ),
                      );
                    },
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        DateFormat('dd MMM yyyy').format(DateTime.now()),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 15),
            // Visits Summary
            Row(
              children: [
                _animatedProgressCard("Doctor Visits", visits.doctor!.confirmed ?? 0, visits.doctor!.total ?? 0),
                _animatedProgressCard("Chemist Visits", visits.chemist!.confirmed ?? 0, visits.chemist!.total ?? 0),
                _animatedProgressCard("Stockist Visits", visits.stockist!.confirmed ?? 0, visits.stockist!.total ?? 0),
              ],
            ),
            SizedBox(height: 24),
            _monthlyTargetSummary(targets),
            SizedBox(height: 24),
            _todayAppointmentsSummary(visits), // Pass the visits data to the widget
            SizedBox(height: 24),
            _sectionTitle("Expense Summary"),
            _todaySummary(expenses),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _animatedProgressCard(String title, int done, int total) {
    return Expanded(
      child: Card(
        margin: EdgeInsets.all(6),
        elevation: 2,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              CircularProgressIndicator(
                value: done / total,
                color: Colors.red,
                strokeWidth: 6,
                backgroundColor: Colors.red.withOpacity(0.2),
              ),
              SizedBox(height: 8),
              Text('$done / $total'),
              Text('${total - done} Remaining'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _todaySummary(Expenses expenses) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statusCircle("Pending", expenses.pending ?? 0, Colors.orange),
              _statusCircle("Approved", expenses.approved ?? 0, Colors.green),
              _statusCircle("Rejected", expenses.rejected ?? 0, Colors.red),
            ],
          ),
          SizedBox(height: 12),
          Divider(thickness: 1),
          _summaryItem("Total Expenses", "₹ ${(expenses.total ?? 0) * 500}"),
        ],
      ),
    );
  }

  Widget _monthlyTargetSummary(Targets targets) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Monthly Sales Targets", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statusCircle("Target", targets.monthlyTarget ?? 0, Colors.deepPurple),
              _statusCircle("Achieved", targets.achieved ?? 0, Colors.green),
              _statusCircle("Left", targets.remaining ?? 0, Colors.orange),
            ],
          ),
          SizedBox(height: 12),
          Divider(thickness: 1),
          _summaryItem("Target Amount", "₹ ${targets.monthlyTarget}"),
          SizedBox(height: 8),
          _summaryItem("Achieved Amount", "₹ ${targets.achieved}"),
          SizedBox(height: 8),
          _summaryItem("Remaining", "₹ ${targets.remaining}"),
        ],
      ),
    );
  }

  Widget _statusCircle(String label, int count, Color color) {
    return Column(
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: color.withOpacity(0.2),
          child: Text(
            count.toString(),
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
          ),
        ),
        SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _summaryItem(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(fontSize: 13)),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  // Today Appointments Summary widget to show the appointment counts
  Widget _todayAppointmentsSummary(Visits visits) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Today's Scheduled Appointments", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _appointmentIconCircle("Doctors", visits.doctor?.total ?? 0, Colors.blueAccent),
              _appointmentIconCircle("Chemists", visits.chemist?.total ?? 0, Colors.indigo),
              _appointmentIconCircle("Stockists", visits.stockist?.total ?? 0, Colors.teal),
            ],
          ),
          const SizedBox(height: 12),
          Divider(thickness: 1),
          _summaryItem("Total Scheduled Today", "${visits.total ?? 0}"),
        ],
      ),
    );
  }

  // Icon circle for each appointment category (Doctors, Chemists, Stockists)
  Widget _appointmentIconCircle(String label, int count, Color color) {
    return Column(
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: color.withOpacity(0.2),
          child: Icon(Icons.calendar_today, color: color),
        ),
        const SizedBox(height: 6),
        Text("$count $label", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }
}*/






/*class SalesChartHomeScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<SalesChartHomeScreen> with TickerProviderStateMixin {
  final Color primaryColor = Color(0xFFC71D52);

  late AnimationController doctorController;
  late AnimationController chemistController;
  late AnimationController stockistController;

  late Animation<double> doctorAnimation;
  late Animation<double> chemistAnimation;
  late Animation<double> stockistAnimation;

  int doctorDone = 4, doctorTotal = 7;
  int chemistDone = 5, chemistTotal = 8;
  int stockistDone = 2, stockistTotal = 5;

  int pending = 3, approved = 6, rejected = 1;
  late final userData;

  AuthManager authManager = AuthManager();

  @override
  void initState() {
    super.initState();

  //  fetchUserRole();

    doctorController = AnimationController(vsync: this, duration: Duration(seconds: 1));
    chemistController = AnimationController(vsync: this, duration: Duration(seconds: 1));
    stockistController = AnimationController(vsync: this, duration: Duration(seconds: 1));

    doctorAnimation = Tween<double>(begin: 0, end: doctorDone / doctorTotal).animate(doctorController);
    chemistAnimation = Tween<double>(begin: 0, end: chemistDone / chemistTotal).animate(chemistController);
    stockistAnimation = Tween<double>(begin: 0, end: stockistDone / stockistTotal).animate(stockistController);

    Timer(Duration(milliseconds: 300), () {
      doctorController.forward();
      chemistController.forward();
      stockistController.forward();
    });



  }

  Future<void> fetchUserRole() async {
    AuthManager authManager = AuthManager();


    final user = await authManager.getUserData();
    setState(() {
      userData = user;
    });

    print("user data $userData");
    print("user data ${userData..user!.name}");
  }

  @override
  void dispose() {
    doctorController.dispose();
    chemistController.dispose();
    stockistController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            FutureBuilder<UserModel?>(
              future: authManager.getUserData(), // your function
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data?.user == null) {
                  return const Text("No user data found");
                }

                final user = snapshot.data!.user!; // safe to use now

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.red, width: 1),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left: Welcome + Name + Email
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "👋 Welcome",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade800,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            user.name, // ✅ from SharedPreferences
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.email, // ✅ from SharedPreferences
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),

                      // Right: Date + Time
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            DateFormat('dd MMM yyyy').format(DateTime.now()),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          *//* Text(
                DateFormat('hh:mm a').format(DateTime.now()),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.red.shade600,
                ),
              ),*//*
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
            SizedBox(height: 15),

        //_sectionTitle("Today's Appointments"),
            Row(
              children: [
                _animatedProgressCard("Doctor Visits", doctorDone, doctorTotal, doctorAnimation),
                _animatedProgressCard("Chemist Visits", chemistDone, chemistTotal, chemistAnimation),
                _animatedProgressCard("Stockist Visits", stockistDone, stockistTotal, stockistAnimation),
              ],
            ),
            SizedBox(height: 24),
            _monthlyTargetSummary(),
            SizedBox(height: 24),
            _todayAppointmentsSummary(),
            SizedBox(height: 24),
            const SizedBox(height: 24),
            _sectionTitle("Expense Summary of July"),
            _todaySummary(),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _animatedProgressCard(String title, int done, int total, Animation<double> animation) {
    return Expanded(
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          return Card(
            margin: EdgeInsets.all(6),
            elevation: 2,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  CircularProgressIndicator(
                    value: animation.value,
                    color: primaryColor,
                    strokeWidth: 6,
                    backgroundColor: primaryColor.withOpacity(0.2),
                  ),
                  SizedBox(height: 8),
                  Text('$done / $total'),
                  Text('${total - done} Remaining'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _todaySummary() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: primaryColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statusCircle("Pending", pending, Colors.orange),
              _statusCircle("Approved", approved, Colors.green),
              _statusCircle("Rejected", rejected, Colors.red),
            ],
          ),
          SizedBox(height: 12),
          Divider(thickness: 1),
          _summaryItem("Total Expenses of July T.A.", "₹ ${(pending + approved + rejected) * 500}"),
          SizedBox(height: 8),
          _summaryItem("Total Expenses of July D.A.", "₹ ${pending * 500}"),
        ],
      ),
    );
  }

  Widget _todayAppointmentsSummary() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: primaryColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Today's Scheduled Appointments", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _appointmentIconCircle("Doctors", doctorTotal, Colors.blueAccent),
              _appointmentIconCircle("Chemists", chemistTotal, Colors.indigo),
              _appointmentIconCircle("Stockists", stockistTotal, Colors.teal),
            ],
          ),
          const SizedBox(height: 12),
          Divider(thickness: 1),
          _summaryItem("Total Scheduled Today", "${doctorTotal + chemistTotal + stockistTotal}"),
        ],
      ),
    );
  }

  Widget _monthlyTargetSummary() {
    final int target = 89870;
    final int achieved = 65000;
    final int remaining = target - achieved;
    final String assignedBy = "Gluckcare";

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: primaryColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Monthely Sales Targets", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statusCircle("Target", target ~/ 1000, Colors.deepPurple),
              _statusCircle("Achieved", achieved ~/ 1000, Colors.green),
              _statusCircle("Left", remaining ~/ 1000, Colors.orange),
            ],
          ),
          const SizedBox(height: 12),
          Divider(thickness: 1),
          _summaryItem("Target Amount", "₹ $target"),
          const SizedBox(height: 8),
          _summaryItem("Achieved Amount", "₹ $achieved"),
          const SizedBox(height: 8),
          _summaryItem("Remaining", "₹ $remaining"),
          const SizedBox(height: 8),
          _summaryItem("Assigned By", assignedBy),
        ],
      ),
    );
  }



  Widget _appointmentIconCircle(String label, int count, Color color) {
    return Column(
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: color.withOpacity(0.2),
          child: Icon(Icons.calendar_today, color: color),
        ),
        const SizedBox(height: 6),
        Text("$count $label", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }


  Widget _statusCircle(String label, int count, Color color) {
    return Column(
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: color.withOpacity(0.2),
          child: Text(
            count.toString(),
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
          ),
        ),
        SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _summaryItem(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(fontSize: 13)),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}*/
