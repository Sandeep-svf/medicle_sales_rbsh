import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utils/constants/colors.dart';
import '../controller/add_investment_controller.dart';

import '../enum.dart';
import '../wigets/create_request/add_request_header.dart';
import '../wigets/create_request/approval_routing.dart';
import '../wigets/create_request/cash_form.dart';
import '../wigets/create_request/compliance_card.dart';
import '../wigets/create_request/doctor_section.dart';
import '../wigets/create_request/investment_mode_selector.dart';
import '../wigets/create_request/item_gift_form.dart';
import '../wigets/create_request/neft_form.dart';
import '../wigets/create_request/submit_buttons.dart';
import '../wigets/create_request/upi_form.dart';

class AddInvestmentScreen extends StatelessWidget {
  AddInvestmentScreen({super.key});

  final controller = Get.put(AddInvestmentController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          "New Investment Request",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
      ),

      body: SafeArea(
        child: Form(
          key: controller.formKey,

          child: LayoutBuilder(
            builder: (context, constraints) {

              final tabletLandscape =
                  constraints.maxWidth > 1100;

              final tabletPortrait =
                  constraints.maxWidth > 700 &&
                      constraints.maxWidth <= 1100;

              ///========================
              /// LANDSCAPE TABLET
              ///========================

              if (tabletLandscape) {
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Expanded(
                        flex: 7,
                        child: SingleChildScrollView(
                          child: _leftPanel(),
                        ),
                      ),

                      const SizedBox(width: 20),

                      SizedBox(
                        width: 380,
                        child: SingleChildScrollView(
                          child: _rightPanel(),
                        ),
                      ),

                    ],
                  ),
                );
              }

              ///========================
              /// PORTRAIT + MOBILE
              ///========================

              return SingleChildScrollView(

                padding: const EdgeInsets.all(16),

                child: Column(

                  children: [

                    _leftPanel(),

                    const SizedBox(height: 20),

                    _rightPanel(),

                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _leftPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        const AddRequestHeader(),

        const SizedBox(height: 20),

        const DoctorSection(),

        const SizedBox(height: 20),

        const InvestmentModeSelector(),

        const SizedBox(height: 20),

        /// Dynamic Form
        Obx(() {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeInOut,
            switchOutCurve: Curves.easeInOut,

            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(.08, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },

            child: _buildForm(),
          );
        }),

        const SizedBox(height: 20),

      ],
    );
  }

  Widget _buildForm() {
    switch (controller.selectedMode.value) {

      case InvestmentMode.cash:
        return const CashForm(
          key: ValueKey("cash_form"),
        );

      case InvestmentMode.neft:
        return const NeftForm(
          key: ValueKey("neft_form"),
        );

      case InvestmentMode.upi:
        return const UpiForm(
          key: ValueKey("upi_form"),
        );

      case InvestmentMode.gift:
        return const GiftForm(
          key: ValueKey("gift_form"),
        );
    }
  }

  Widget _rightPanel() {

    return const Column(

      children: [

        ComplianceCard(),

        SizedBox(height:20),

        ApprovalRoutingCard(),

        SizedBox(height:20),

        SubmitButtons(),

      ],

    );

  }

}