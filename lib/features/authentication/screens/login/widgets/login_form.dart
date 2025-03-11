import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:medicle_sales_rbsh/features/dashboard/screen/dashboard.dart';


import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/constants/text_strings.dart';



class LoginForm extends StatelessWidget {
  const LoginForm({
    super.key,
    required this.dark,
  });

  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Form(
      // Form only contain single child...
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: TSizes.spaceBtwSections,
        ),
        child: Column(
          children: [
            ///Email
            TextFormField(
              decoration: InputDecoration(
                // bcoz use icon in text field
                prefixIcon: Icon(Iconsax.direct_right),
                labelText: TTexts.userEmail,
              ),
            ),

            const SizedBox(height: TSizes.spaceBtwItems,),

            ///password
            TextFormField(
              decoration: InputDecoration(
                // bcoz use icon in text field
                  prefixIcon: Icon(Iconsax.password_check),
                  labelText: TTexts.password,
                  suffixIcon: Icon(Iconsax.eye_slash)),
            ),

            const SizedBox(
              height: TSizes.spaceBtwInputFields / 2,
            ),


            const SizedBox(
              height: TSizes.spaceBtwSections,
            ),

            ///SignIn button
            SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                onPressed: () => Get.to( DashboardScreen()),
                    child: const Text(TTexts.logIn))),
          ],
        ),
      ),
    );
  }
}