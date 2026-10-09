import 'dart:async';
import 'package:flutter/material.dart';

class MapAreaHold extends StatefulWidget {
  const MapAreaHold(
      {super.key,
      required this.child,
      required this.onHold,
      required this.onRelease});
  final Widget child;
  final ValueChanged<Offset> onHold;
  final VoidCallback onRelease;
  @override
  State<MapAreaHold> createState() => _MapAreaHoldState();
}

class _MapAreaHoldState extends State<MapAreaHold> {
  Timer? timer;
  final pointers = <int>{};
  Offset? origin;
  bool fired = false;
  void cancel() {
    timer?.cancel();
    timer = null;
  }

  @override
  void dispose() {
    cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (event) {
          pointers.add(event.pointer);
          cancel();
          if (pointers.length != 1) return;
          origin = event.localPosition;
          fired = false;
          timer = Timer(const Duration(milliseconds: 1500), () {
            fired = true;
            widget.onHold(origin!);
          });
        },
        onPointerMove: (event) {
          if (origin != null && (event.localPosition - origin!).distance > 12) {
            cancel();
          }
        },
        onPointerUp: (event) {
          pointers.remove(event.pointer);
          cancel();
          if (fired) {
            fired = false;
            widget.onRelease();
          }
        },
        onPointerCancel: (event) {
          pointers.remove(event.pointer);
          cancel();
          if (fired) {
            fired = false;
            widget.onRelease();
          }
        },
        child: widget.child,
      );
}
