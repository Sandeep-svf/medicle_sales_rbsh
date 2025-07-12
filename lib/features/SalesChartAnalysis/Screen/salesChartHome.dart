import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SalesChartHomeScreen2 extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<SalesChartHomeScreen2> with TickerProviderStateMixin {
  final Color primaryColor = Color(0xFFC71D52);

  late AnimationController callController;
  late AnimationController salesController;
  late AnimationController otherController;

  late Animation<double> callAnimation;
  late Animation<double> salesAnimation;
  late Animation<double> otherAnimation;

  @override
  void initState() {
    super.initState();

    callController = AnimationController(vsync: this, duration: Duration(seconds: 1));
    salesController = AnimationController(vsync: this, duration: Duration(seconds: 1));
    otherController = AnimationController(vsync: this, duration: Duration(seconds: 1));

    callAnimation = Tween<double>(begin: 0, end: 6 / 10).animate(callController);
    salesAnimation = Tween<double>(begin: 0, end: 3 / 5).animate(salesController);
    otherAnimation = Tween<double>(begin: 0, end: 5 / 8).animate(otherController);

    Timer(Duration(milliseconds: 300), () {
      callController.forward();
      salesController.forward();
      otherController.forward();
    });
  }

  @override
  void dispose() {
    callController.dispose();
    salesController.dispose();
    otherController.dispose();
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
            _sectionTitle("Daily Target Progress"),
            Row(
              children: [
                _animatedProgressCard("Call Visits", 6, 10, callAnimation),
                _animatedProgressCard("Product Sales", 3, 5, salesAnimation),
                _animatedProgressCard("Other Tasks", 5, 8, otherAnimation),
              ],  
            ),
            SizedBox(height: 24),
            _sectionTitle("Weekly Sales Trend"),
            _weeklyBarChart(),
            SizedBox(height: 24),
            _sectionTitle("Monthly Summary"),
            _monthlySummary(),
            SizedBox(height: 24),
            _sectionTitle("User Activity"),
            _userActivityChart(),
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

  Widget _weeklyBarChart() {
    final sales = [1000, 1250, 1700, 1200, 1100, 1050, 1800];

    return SizedBox(
      height: 260,
      child: BarChart(
        BarChartData(
          maxY: 2200,
          barGroups: List.generate(
            sales.length,
                (i) => BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: sales[i].toDouble(),
                  width: 18,
                  borderRadius: BorderRadius.circular(4),
                  color: primaryColor,
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: 2200,
                    color: Colors.grey.shade200,
                  ),
                )
              ],
              // 🔴 REMOVE THIS 👇 (No tooltip by default)
              // showingTooltipIndicators: [0],
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                reservedSize: 40,
                showTitles: true,
                getTitlesWidget: (value, _) =>
                    Text(value.toInt().toString(), style: TextStyle(fontSize: 10)),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                reservedSize: 32,
                showTitles: true,
                getTitlesWidget: (value, _) {
                  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                  return Text(days[value.toInt()], style: TextStyle(fontSize: 10));
                },
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              tooltipMargin: 8,

              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${rod.toY.toInt()}',
                  TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ),
          gridData: FlGridData(show: true),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }



  Widget _monthlySummary() {
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
          _summaryItem("Total Sales This Month", "₹ 52,500"),
          SizedBox(height: 8),
          _summaryItem("Pending Expense", "₹ 8,000"),
          SizedBox(height: 8),
          _summaryItem("Total Visits This Week", "24"),
        ],
      ),
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

  Widget _userActivityChart() {
    final activity = [0.5, 1.8, 3.2, 2.7, 5.5, 4.2, 6.3];

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: 8,
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(
                activity.length,
                    (i) => FlSpot(i.toDouble(), activity[i]),
              ),
              isCurved: true,
              barWidth: 2,
              color: primaryColor,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(show: false),
            )
          ],
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                reservedSize: 32,
                showTitles: true,
                getTitlesWidget: (value, _) =>
                    Text(value.toInt().toString(), style: TextStyle(fontSize: 10)),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                reservedSize: 28,
                showTitles: true,
                getTitlesWidget: (value, _) {
                  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                  return Text(days[value.toInt()], style: TextStyle(fontSize: 10));
                },
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(show: true),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }
}
