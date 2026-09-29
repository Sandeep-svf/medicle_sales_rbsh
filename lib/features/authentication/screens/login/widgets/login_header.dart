import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../utils/constants/image_strings.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/constants/text_strings.dart';
import '../../../../../utils/http/http_client.dart';
import '../../../controllers/AuthController.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({
    super.key,
    required this.dark,
  });

  final bool dark;

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      // because align all in the left in header
      children: [
        /*Image(
          image: AssetImage(
              dark ? TImages.lightAppLogo : TImages.darkAppLogo),
          height: 150,
        ),*/

        Obx(() {
          final company = authController.user.value?.company;
          final companyLogoUrl = company == null
              ? null
              : THttpHelper.companyLogoUrl;
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                dark ? TImages.lightAppLogoSmall : TImages.darkAppLogoSmall,
                height: TSizes.v150,
              ),
              if (companyLogoUrl != null) ...[
                const SizedBox(width: TSizes.md),
                Image.network(
                  companyLogoUrl,
                  height: TSizes.v100,
                  width: TSizes.v150,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ],
            ],
          );
        } ),
        Text(
          "",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(
          height: TSizes.sm,
        ),
        Text(
          "",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
