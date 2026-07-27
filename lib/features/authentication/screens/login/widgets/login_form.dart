import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';
import 'package:medicle_sales_rbsh/utils/constants/text_strings.dart';
import '../../../controllers/AuthController.dart';

class LoginForm extends StatelessWidget {
  final bool dark;
  final AuthController authController;

  const LoginForm({super.key, required this.dark, required this.authController});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    // 1. Add a ValueNotifier to track the hidden state
    final ValueNotifier<bool> hidePassword = ValueNotifier<bool>(true);


    Future<String> _getDeviceId() async {
      final deviceInfo = DeviceInfoPlugin();

      if (Platform.isAndroid) {
        final android = await deviceInfo.androidInfo;
        return android.id; // or android.serial if available
      }

      if (Platform.isIOS) {
        final ios = await deviceInfo.iosInfo;
        return ios.identifierForVendor ?? "";
      }

      return "";
    }

    return Form(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: TSizes.spaceBtwSections),
        child: Column(
          children: [
            /// Email
            TextFormField(
              controller: emailController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Iconsax.direct_right),
                labelText: TTexts.userEmail,
              ),
            ),

            const SizedBox(height: TSizes.spaceBtwItems),

            /// Password
            // 2. Wrap TextFormField with ValueListenableBuilder
            ValueListenableBuilder(
              valueListenable: hidePassword,
              builder: (context, value, child) {
                return TextFormField(
                  controller: passwordController,
                  obscureText: value, // Use the notifier value here
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Iconsax.password_check),
                    labelText: TTexts.password,
                    suffixIcon: IconButton(
                      // 3. Change icon based on state
                      icon: Icon(value ? Iconsax.eye_slash : Iconsax.eye),
                      // 4. Toggle the value on click
                      onPressed: () => hidePassword.value = !hidePassword.value,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: TSizes.spaceBtwSections),

            /// Sign In Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async{
                  String email = emailController.text.trim();
                  String password = passwordController.text.trim();
                  final deviceId = await _getDeviceId();
                  authController.login(email, password, deviceId);
                },
                child: const Text(TTexts.logIn),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
