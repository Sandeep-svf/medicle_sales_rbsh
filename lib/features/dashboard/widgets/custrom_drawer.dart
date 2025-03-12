import 'package:flutter/material.dart';
import 'package:medicle_sales_rbsh/features/SalesChartAnalysis/Screen/salesChartHome.dart';
import 'package:medicle_sales_rbsh/features/addDoctor/screens/addDoctor.dart';
import 'package:medicle_sales_rbsh/features/addProduct/screens/addProduct.dart';
import 'package:medicle_sales_rbsh/features/expenses/screens/expenses.dart';
import 'package:medicle_sales_rbsh/features/order/screens/order.dart';
import 'package:medicle_sales_rbsh/features/report/screens/report.dart';
import 'package:medicle_sales_rbsh/features/salesActivity/screens/salesActivity.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import 'package:medicle_sales_rbsh/utils/constants/text_strings.dart';
import 'package:medicle_sales_rbsh/utils/helpers/helper_functions.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

import '../../visitDoctor/screens/visitDoctor.dart';

class CustomDrawer extends StatelessWidget {
  final Function(Widget) onMenuSelected;

  const CustomDrawer({required this.onMenuSelected});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          _buildHeader(context), // User Header
          _buildDrawerItem(
            icon: Icons.home,
            text: TTexts.dashboard,
            onTap: () => onMenuSelected(SalesChartHomeScreen()),
          ),
          const Divider(height: 1, color: Colors.grey),
          _buildDrawerItem(
            icon: Icons.person,
            text: TTexts.addDoctor,
            onTap: () => onMenuSelected(AddDoctorScreen()),
          ),
          const Divider(height: 1, color: Colors.grey),
          _buildDrawerItem(
            icon: Icons.money,
            text: TTexts.salesActivity,
            onTap: () => onMenuSelected(SalesactivityScreen()),
          ),
          const Divider(height: 1, color: Colors.grey),

          _buildDrawerItem(
            icon: Icons.place,
            text: TTexts.doctorVisit,
            onTap: () => onMenuSelected(VisitDoctorScreen()),
          ),
          const Divider(height: 1, color: Colors.grey),

          _buildDrawerItem(
            icon: Icons.add,
            text: TTexts.addProduct,
            onTap: () => onMenuSelected(AddproductScreen()),
          ),
          const Divider(height: 1, color: Colors.grey),

          _buildDrawerItem(
            icon: Icons.reorder,
            text: TTexts.order,
            onTap: () => onMenuSelected(OrderScreen()),
          ),
          const Divider(height: 1, color: Colors.grey),

          _buildDrawerItem(
            icon: Icons.expand,
            text: TTexts.expenses,
            onTap: () => onMenuSelected(ExpensesScreen()),
          ),
          const Divider(height: 1, color: Colors.grey),

          _buildDrawerItem(
            icon: Icons.report,
            text: TTexts.report,
            onTap: () => onMenuSelected(ReportScreen()),
          ),
          const Divider(height: 1, color: Colors.grey),

          _buildDrawerItem(
            icon: Icons.settings,
            text: TTexts.settings,
            onTap: () => onMenuSelected(SalesChartHomeScreen()),
          ),

          const Divider(height: 1, color: Colors.grey),

          _buildDrawerItem(
              icon: Icons.logout,
              text: TTexts.logout,
              onTap: () {
                QuickAlert.show(
                  context: context,
                  type: QuickAlertType.confirm,
                  text: TTexts.doYouWantToLogout,
                  confirmBtnText: TTexts.yes,
                  cancelBtnText: TTexts.no,
                  confirmBtnColor: TColors.primary,
                );
              }),
        ],
      ),
    );
  }

  /// User Header Section
  Widget _buildHeader(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    return Container(
      color: dark ? Colors.black : Colors.grey[300], //  Gray Background
      padding: EdgeInsets.symmetric(vertical: 50, horizontal: 16),
      width: double.infinity, //  Take full width
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 50, //  Circular Avatar
            backgroundColor: Colors.blue, //  Background color instead of image
            child: Text(
              "A", //  First letter of name
              style: TextStyle(
                  fontSize: 60,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
          SizedBox(width: 16), //  Space between avatar and text
          Column(
            crossAxisAlignment: CrossAxisAlignment.start, //  Align text to left
            children: [
              Text("Aarav Maurya",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text("aarav@rbsh.com", style: TextStyle(fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }

  /// **Drawer Item Template**
  Widget _buildDrawerItem(
      {required IconData icon,
      required String text,
      required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(text, style: const TextStyle(fontSize: 16)),
      onTap: onTap,
    );
  }
}
