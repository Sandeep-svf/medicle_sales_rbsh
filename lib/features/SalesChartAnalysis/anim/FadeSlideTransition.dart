// Ensure these imports match your project structure
import 'package:flutter/material.dart';

import '../../../utils/check_internet/network_monitor.dart';
import '../../../utils/local_storage/auth_manager.dart';
import '../../authentication/models/UserModel.dart';
import '../../ticket/controller/TicketController.dart';
import '../controller/DashboardController.dart';
import '../model/SalesChartDashboardModel.dart';

// --- Reusable Animation Wrapper ---
class FadeSlideTransition extends StatelessWidget {
  final Widget child;
  final int delay;

  const FadeSlideTransition({Key? key, required this.child, this.delay = 0}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + delay),
      curve: Curves.easeOutQuart,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}