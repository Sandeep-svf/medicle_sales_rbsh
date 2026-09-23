import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';

class LiveClockWidget extends StatefulWidget {
  const LiveClockWidget({super.key});

  @override
  State<LiveClockWidget> createState() => _LiveClockWidgetState();
}

class _LiveClockWidgetState extends State<LiveClockWidget> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.access_time,
          size: TSizes.v16,
          color: TColors.white70,
        ),
        const SizedBox(width: TSizes.v6),
        Text(
          DateFormat('EEEE, MMMM dd, yyyy · hh:mm:ss a').format(DateTime.now()),
          style: const TextStyle(
            fontSize: TSizes.v14,
            color: TColors.white,
          ),
        ),
      ],
    );
  }
}
