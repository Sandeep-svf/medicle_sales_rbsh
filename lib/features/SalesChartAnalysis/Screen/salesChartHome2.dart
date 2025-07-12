import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SalesChartHomeScreen extends StatefulWidget {
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

  @override
  void initState() {
    super.initState();

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
}
