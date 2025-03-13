import 'package:flutter/material.dart';
import 'package:medicle_sales_rbsh/features/authentication/screens/login/widgets/login_form.dart';
import 'package:medicle_sales_rbsh/features/authentication/screens/login/widgets/login_header.dart';
import '../../../../common/styles/spacying_styling.dart';
import '../../../../utils/helpers/helper_functions.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
            child: Padding(
          padding: TSpaceingStyle.paddingWithAppBarHeight,
          child: Column(
            children: [
              /// Logo, title and subTitle
              LoginHeader(dark: dark),

              /// Form
              LoginForm(dark: dark),

            ],
          ),
        )),
      ),
    );
  }
}








