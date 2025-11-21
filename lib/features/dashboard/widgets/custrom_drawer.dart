import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medicle_sales_rbsh/features/MarketingMaterials/Screens/MarketingMaterials.dart';
import 'package:medicle_sales_rbsh/features/SalesChartAnalysis/Screen/salesChartHome.dart';
import 'package:medicle_sales_rbsh/features/StatelevelUser/CheckLocationOfAllUser/Screen/UserListScreen.dart';
import 'package:medicle_sales_rbsh/features/addClinic/screen/ClinicList.dart';

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
import 'package:shared_preferences/shared_preferences.dart';
import '../../../utils/local_storage/auth_manager.dart';
import '../../Blog/screen/blog.dart';
import '../../Inbox/Screen/InboxScreen.dart';

import '../../InvoiceTrackerShipment/screen/InvoiceScreen.dart';
import '../../PtsPtrCalculator/PtsPtrCalculator.dart';
import '../../SalesChartAnalysis/Screen/salesChartHome2.dart';
import '../../addStokist/screen/StokistList.dart';
import '../../authentication/models/UserModel.dart';
import '../../authentication/screens/login/login.dart';
import '../../marketing/screen/MarketingScreen.dart';
import '../../marketing/screen/marketing.dart';
import '../../ticket/screen/ticketscreen.dart';
import '../../visit/Doctor/screens/ScheduleVisit.dart';







class CustomDrawer extends StatefulWidget {
  final Function(Widget, String) onMenuSelected;
  final String currentScreen; // Added this parameter to track selected item
  final String userRole;  // Accept userRole as a parameter


  const CustomDrawer({required this.onMenuSelected, required this.currentScreen,  required this.userRole,Key? key})
      : super(key: key);

  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
 // late String? userRole;  // Store the user role variable

  /*@override
  void initState() {
    super.initState();
    print("[DEBUG] init is calling...");
    fetchUserRole();  // Fetch the role in initState
  }*/

  // Function to fetch user role from SharedPreferences
 /* Future<void> fetchUserRole() async {
    AuthManager authManager = AuthManager();
    userRole = await authManager.getUserRole();
   // userRole = prefs.getString('roleKey');  // Replace with actual key for user role
    print("[DEBUG] User role fetched: $userRole");
    setState(() {});  // Update the UI after fetching the role
  }*/

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 450,
      child: Drawer(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView(
                children: [
                  _buildDrawerItem(
                    icon: Icons.home,
                    text: TTexts.dashboard,
                    onTap: () =>
                        widget.onMenuSelected(SalesChartHomeScreen(), TTexts.dashboard),
                    isSelected: widget.currentScreen == TTexts.dashboard,
                  ),

                  // Conditionally show the "User List" item if the role is "State Head"
                  if (widget.userRole == 'State Head')
                    _buildDrawerItem(
                      icon: Icons.home,
                      text: TTexts.userListScreen,
                      onTap: () =>
                          widget.onMenuSelected(UserListScreen(), TTexts.userListScreen),
                      isSelected: widget.currentScreen == TTexts.userListScreen,
                    ),

                  _buildDrawerItem(
                    icon: Icons.mail,
                    text: TTexts.inbox,
                    onTap: () =>
                        widget.onMenuSelected(InboxScreen(), TTexts.inbox),
                    isSelected: widget.currentScreen == TTexts.inbox,
                  ),

                  // Other drawer items
                  _buildDrawerItem(
                    icon: Icons.money,
                    text: TTexts.marketingMaterial,
                    onTap: () => widget.onMenuSelected(
                        MarketingmaterialsScreen(), TTexts.marketingMaterial),
                    isSelected: widget.currentScreen == TTexts.marketingMaterial,
                  ),
                  _buildDrawerItem(
                    icon: Icons.picture_as_pdf,
                    text: TTexts.filesAndPdfs,
                    onTap: () =>
                        widget.onMenuSelected(MarketingScreen(), TTexts.filesAndPdfs),
                    isSelected: widget.currentScreen == TTexts.filesAndPdfs,
                  ),
                  _buildDrawerItem(
                    icon: Icons.person,
                    text: TTexts.addDoctor,
                    onTap: () =>
                        widget.onMenuSelected(AddDoctorScreen(), TTexts.addDoctor),
                    isSelected: widget.currentScreen == TTexts.addDoctor,
                  ),
                  _buildDrawerItem(
                    icon: Icons.local_hospital,
                    text: TTexts.clinic,
                    onTap: () =>
                        widget.onMenuSelected(ClinicListScreen(), TTexts.clinic),
                    isSelected: widget.currentScreen == TTexts.clinic,
                  ),
                  _buildDrawerItem(
                    icon: Icons.local_hospital,
                    text: TTexts.stokist,
                    onTap: () =>
                        widget.onMenuSelected(StokistListScreen(), TTexts.stokist),
                    isSelected: widget.currentScreen == TTexts.stokist,
                  ),
                  _buildDrawerItem(
                    icon: Icons.calculate,
                    text: TTexts.ptsptrcalculator,
                    onTap: () =>
                        widget.onMenuSelected(PtrPtsCalculatorScreen(), TTexts.ptsptrcalculator),
                    isSelected: widget.currentScreen == TTexts.stokist,
                  ),
                  _buildDrawerItem(
                    icon: Icons.place,
                    text: TTexts.doctorVisit,
                    onTap: () =>
                        widget.onMenuSelected(ScheduleVisit(), TTexts.doctorVisit),
                    isSelected: widget.currentScreen == TTexts.doctorVisit,
                  ),
                  _buildDrawerItem(
                    icon: Icons.money,
                    text: TTexts.salesActivity,
                    onTap: () =>
                        widget.onMenuSelected(SalesactivityScreen(), TTexts.salesActivity),
                    isSelected: widget.currentScreen == TTexts.salesActivity,
                  ),
                  _buildDrawerItem(
                    icon: Icons.add,
                    text: TTexts.addProduct,
                    onTap: () =>
                        widget.onMenuSelected(AddproductScreen(), TTexts.addProduct),
                    isSelected: widget.currentScreen == TTexts.addProduct,
                  ),
                  _buildDrawerItem(
                    icon: Icons.reorder,
                    text: TTexts.order,
                    onTap: () => widget.onMenuSelected(OrderScreen(), TTexts.order),
                    isSelected: widget.currentScreen == TTexts.order,
                  ),
                  _buildDrawerItem(
                    icon: Icons.inventory,
                    text: TTexts.invoiceScreen,
                    onTap: () => widget.onMenuSelected(InvoiceScreen(), TTexts.invoiceScreen),
                    isSelected: widget.currentScreen == TTexts.invoiceScreen,
                  ),
                  // InvoiceScreen

                  _buildDrawerItem(
                    icon: Icons.expand,
                    text: TTexts.expenses,
                    onTap: () => widget.onMenuSelected(ExpensesScreen(), TTexts.expenses),
                    isSelected: widget.currentScreen == TTexts.expenses,
                  ),
                  _buildDrawerItem(
                    icon: Icons.post_add,
                    text: TTexts.blog,
                    onTap: () => widget.onMenuSelected(Blogscreen(), TTexts.blog),
                    isSelected: widget.currentScreen == TTexts.blog,
                  ),
                  _buildDrawerItem(
                    icon: Icons.support,
                    text: TTexts.support,
                    onTap: () => widget.onMenuSelected(TicketScreen(), TTexts.support),
                    isSelected: widget.currentScreen == TTexts.support,
                  ),
                  _buildDrawerItem(
                    icon: Icons.report,
                    text: TTexts.report,
                    onTap: () => widget.onMenuSelected(ReportScreen(), TTexts.report),
                    isSelected: widget.currentScreen == TTexts.report,
                  ),
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
                        onConfirmBtnTap: () async {
                          Get.back();
                          await AuthManager().logout();
                          Get.offAll(() => LoginScreen());
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// **User Header Section**
  Widget _buildHeader(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);

    return FutureBuilder<UserModel?>(
      future: AuthManager().getUserData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _loadingHeader(dark);
        } else if (snapshot.hasError || !snapshot.hasData) {
          return Text("Error loading user data");
        }

        final user = snapshot.data!;

        return Container(
          color: dark ? Colors.black : Colors.grey[300],
          padding: EdgeInsets.symmetric(vertical: 50, horizontal: 16),
          width: double.infinity,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: TColors.primary,
                child: Icon(Icons.person, size: 50, color: Colors.white),
              ),
              SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.user!.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(user.user!.email, style: TextStyle(fontSize: 14)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  /// **Loading Header Placeholder**
  Widget _loadingHeader(bool dark) {
    return Container(
      color: dark ? Colors.black : Colors.grey[300],
      padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 16),
      width: double.infinity,
      child: Row(
        children: [
          const CircleAvatar(radius: 50, backgroundColor: Colors.grey),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text("Loading...", style: TextStyle(fontSize: 18)),
              Text("Please wait", style: TextStyle(fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }

  /// **Drawer Item Template**
  Widget _buildDrawerItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    return ListTile(
      leading: Icon(icon, color: isSelected ? TColors.primary : Colors.grey),
      title: Text(text, style: TextStyle(fontSize: 16, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      tileColor: isSelected ? Colors.blue.withOpacity(0.1) : Colors.transparent,
      onTap: onTap,
    );
  }
}






/*class CustomDrawer extends StatelessWidget {
  final Function(Widget, String) onMenuSelected;
  final String currentScreen; //  Added this parameter to track selected item


  const CustomDrawer({required this.onMenuSelected, required this.currentScreen, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    //final Clinic clinic;
    return Drawer(
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: ListView(
              children: [
                _buildDrawerItem(
                  icon: Icons.home,
                  text: TTexts.dashboard,
                  onTap: () =>
                      onMenuSelected(SalesChartHomeScreen(), TTexts.dashboard),
                  isSelected: currentScreen == TTexts.dashboard,
                ),

                _buildDrawerItem(
                  icon: Icons.home,
                  text: TTexts.userListScreen,
                  onTap: () =>
                      onMenuSelected(UserListScreen(), TTexts.userListScreen),
                  isSelected: currentScreen == TTexts.userListScreen,
                ),




                _buildDrawerItem(
                  icon: Icons.mail,
                  text: TTexts.inbox,
                  onTap: () =>
                      onMenuSelected(InboxScreen(), TTexts.inbox),
                  isSelected: currentScreen == TTexts.inbox,
                ),
                _buildDrawerItem(
                  icon: Icons.money,
                  text: TTexts.marketingMaterial,
                  onTap: () => onMenuSelected(
                      MarketingmaterialsScreen(), TTexts.marketingMaterial),
                  isSelected: currentScreen == TTexts.marketingMaterial,
                ),
                _buildDrawerItem(
                  icon: Icons.picture_as_pdf,
                  text: TTexts.filesAndPdfs,
                  onTap: () =>
                      onMenuSelected(MarketingScreen(), TTexts.filesAndPdfs),
                  isSelected: currentScreen == TTexts.filesAndPdfs,
                ),



                _buildDrawerItem(
                  icon: Icons.person,
                  text: TTexts.addDoctor,
                  onTap: () =>
                      onMenuSelected(AddDoctorScreen(), TTexts.addDoctor),
                  isSelected: currentScreen == TTexts.addDoctor,
                ),




                _buildDrawerItem(
                  icon: Icons.local_hospital,
                  text: TTexts.clinic,
                  onTap: () =>
                      onMenuSelected(ClinicListScreen(), TTexts.clinic),
                  isSelected: currentScreen == TTexts.clinic,
                ),
                _buildDrawerItem(
                  icon: Icons.local_hospital,
                  text: TTexts.stokist,
                  onTap: () =>
                      onMenuSelected(StokistListScreen(), TTexts.stokist),
                  isSelected: currentScreen == TTexts.stokist,
                ),

                _buildDrawerItem(
                  icon: Icons.place,
                  text: TTexts.doctorVisit,
                  onTap: () =>
                      onMenuSelected(ScheduleVisit(), TTexts.doctorVisit),
                  isSelected: currentScreen == TTexts.doctorVisit,
                ),

                _buildDrawerItem(
                  icon: Icons.money,
                  text: TTexts.salesActivity,
                  onTap: () =>
                      onMenuSelected(SalesactivityScreen(), TTexts.salesActivity),
                  isSelected: currentScreen == TTexts.salesActivity,
                ),

                _buildDrawerItem(
                  icon: Icons.add,
                  text: TTexts.addProduct,
                  onTap: () =>
                      onMenuSelected(AddproductScreen(), TTexts.addProduct),
                  isSelected: currentScreen == TTexts.addProduct,
                ),
                _buildDrawerItem(
                  icon: Icons.reorder,
                  text: TTexts.order,
                  onTap: () => onMenuSelected(OrderScreen(), TTexts.order),
                  isSelected: currentScreen == TTexts.order,
                ),
                _buildDrawerItem(
                  icon: Icons.expand,
                  text: TTexts.expenses,
                  onTap: () => onMenuSelected(ExpensesScreen(), TTexts.expenses),
                  isSelected: currentScreen == TTexts.expenses,
                ),
                _buildDrawerItem(
                  icon: Icons.post_add,
                  text: TTexts.blog,
                  onTap: () => onMenuSelected(Blogscreen(), TTexts.blog),
                  isSelected: currentScreen == TTexts.blog,
                ),

                _buildDrawerItem(
                  icon: Icons.support,
                  text: TTexts.support,
                  onTap: () => onMenuSelected(TicketScreen(), TTexts.support),
                  isSelected: currentScreen == TTexts.support,
                ),

                _buildDrawerItem(
                  icon: Icons.report,
                  text: TTexts.report,
                  onTap: () => onMenuSelected(ReportScreen(), TTexts.report),
                  isSelected: currentScreen == TTexts.report,
                ),
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
                      onConfirmBtnTap: () async {
                        Get.back();
                        await AuthManager().logout();
                        Get.offAll(() => LoginScreen());
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// **User Header Section**
  Widget _buildHeader(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);

    return FutureBuilder<UserModel?>(
      future: AuthManager().getUserData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _loadingHeader(dark);
        } else if (snapshot.hasError || !snapshot.hasData) {
          return Text("Error loading user data");
        }

        final user = snapshot.data!;

        return Container(
          color: dark ? Colors.black : Colors.grey[300],
          padding: EdgeInsets.symmetric(vertical: 50, horizontal: 16),
          width: double.infinity,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: TColors.primary,
                child: Icon(Icons.person, size: 50, color: Colors.white),
              ),
              SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.user!.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(user.user!.email, style: TextStyle(fontSize: 14)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  /// **Loading Header Placeholder**
  Widget _loadingHeader(bool dark) {
    return Container(
      color: dark ? Colors.black : Colors.grey[300],
      padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 16),
      width: double.infinity,
      child: Row(
        children: [
          const CircleAvatar(radius: 50, backgroundColor: Colors.grey),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text("Loading...", style: TextStyle(fontSize: 18)),
              Text("Please wait", style: TextStyle(fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }

  /// **Drawer Item Template**
  Widget _buildDrawerItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    return ListTile(
      leading: Icon(icon, color: isSelected ? TColors.primary : Colors.grey),
      title: Text(text, style: TextStyle(fontSize: 16, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      tileColor: isSelected ? Colors.blue.withOpacity(0.1) : Colors.transparent,
      onTap: onTap,
    );
  }
}*/
