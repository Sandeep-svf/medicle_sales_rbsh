import 'package:flutter/material.dart';

import '../../../../../utils/constants/image_strings.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/constants/text_strings.dart';


class LoginHeader extends StatelessWidget {
  const LoginHeader({
    super.key,
    required this.dark,
  });

  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      // because align all in the left in header
      children: [
        /*Image(
          image: AssetImage(
              dark ? TImages.lightAppLogo : TImages.darkAppLogo),
          height: 150,
        ),*/

        Image(
          image: AssetImage(
              dark ? TImages.lightAppLogo : TImages.darkAppLogo),
          height: 150,
        ),
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