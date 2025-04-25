import 'package:flutter/material.dart';
import 'package:medicle_sales_rbsh/features/visitDoctor/screens/visitDoctor.dart';

import '../../../utils/constants/colors.dart';


class ScheduleVisit extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<ScheduleVisit> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); // 3 tabs
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TabBar(
          controller: _tabController,
          indicatorColor: TColors.primary,
          labelColor: TColors.primary,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: "Doctor"),
            Tab(text: "Chemist"),
            Tab(text: "Stockist"),
          ],
        ),

      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          VisitDoctorScreen(),
          VisitDoctorScreen(),
          VisitDoctorScreen(),
        ],
      ),
    );
  }
}
