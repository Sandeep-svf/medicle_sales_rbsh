import 'package:flutter/material.dart';

class ZoomInOutDialog extends StatefulWidget {
  final Widget child;

  const ZoomInOutDialog({Key? key, required this.child}) : super(key: key);

  @override
  _ZoomInOutDialogState createState() => _ZoomInOutDialogState();
}

class _ZoomInOutDialogState extends State<ZoomInOutDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400), // Adjust speed
    );

    _scaleAnimation = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutBack),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: widget.child,
    );
  }
}
