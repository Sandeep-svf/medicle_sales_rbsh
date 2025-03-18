import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomPageTransition extends CustomTransition {
  @override
  Widget buildTransition(
      BuildContext context,
      Curve? curve,
      Alignment? alignment,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
      ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1.0, 0.0), // Start from right
        end: Offset.zero, // Move to center
      ).animate(animation),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(-1.0, 0.0), // Move left when popping
        ).animate(secondaryAnimation),
        child: child,
      ),
    );
  }
}
