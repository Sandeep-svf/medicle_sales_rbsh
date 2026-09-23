import 'package:flutter/material.dart';
import 'package:medicle_sales_rbsh/features/visit/Chemist/screens/visitChemist.dart';
import 'package:medicle_sales_rbsh/features/visit/Doctor/screens/visitDoctor.dart';
import 'package:medicle_sales_rbsh/features/visit/Stockist/screens/visitStockist.dart';

import '../../../../utils/check_internet/checkInternetConnection.dart';
import '../../../../utils/constants/colors.dart';
import 'package:medicle_sales_rbsh/utils/constants/text_strings.dart';

class ScheduleVisit extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<ScheduleVisit>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    fetchUserData();
    _tabController = TabController(length: 3, vsync: this); // 3 tabs
  }

  void fetchUserData() async {
    bool online = await checkInternetConnection(context);
    if (!online) return; // Stop API if no internet
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
          indicatorColor: TColors.white,
          labelColor: TColors.white,
          unselectedLabelColor: TColors.materialGrey400,
          tabs: const [
            Tab(text: TTexts.addDoctor),
            Tab(text: TTexts.clinic),
            Tab(text: TTexts.uiTextStockist),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          VisitDoctorScreen(),
          VisitChemistScreen(),
          VisitStockistScreen(),
        ],
      ),
    );
  }
}
