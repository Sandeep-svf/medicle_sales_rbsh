import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medicle_sales_rbsh/features/authentication/screens/login/widgets/login_form.dart';
import 'package:medicle_sales_rbsh/features/authentication/screens/login/widgets/login_header.dart';
import '../../../../common/styles/spacying_styling.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../controllers/AuthController.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    final AuthController authController = Get.put(AuthController());

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: TSpaceingStyle.paddingWithAppBarHeight,
            child: Column(
              children: [
                /// Logo, title, and subtitle
                LoginHeader(dark: dark),

                /// Form
                LoginForm(dark: dark, authController: authController),

                /// Loader (shows when logging in)
                Obx(() => authController.isLoading.value
                    ? const Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: CircularProgressIndicator(),
                )
                    : const SizedBox()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
