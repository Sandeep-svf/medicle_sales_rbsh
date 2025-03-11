import 'package:flutter/material.dart';

import '../../utils/constants/sizes.dart';

class TSpaceingStyle{
  static const EdgeInsetsGeometry paddingWithAppBarHeight = EdgeInsets.only(
    left: TSizes.defaultSpace,
    right: TSizes.defaultSpace,
    top: TSizes.appBarHeight,
    bottom: TSizes.defaultSpace,
  );
}