import 'dart:math' as math;
import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../http/api_request_visibility.dart';

const _navy = Color(0xFF00384F);
const _teal = Color(0xFF1EC4B6);

class FieldOmniLoadingDialog {
  const FieldOmniLoadingDialog._();

  static void show(BuildContext context, {required String message}) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: FieldOmniLoader(message: message, showSurface: true),
        ),
      ),
    );
  }
}

/// Reusable FieldOmni loader for any screen or in-progress action.
class FieldOmniLoader extends StatefulWidget {
  const FieldOmniLoader({
    super.key,
    this.message = 'Loading...',
    this.showMessage = true,
    this.showSurface = false,
    this.suppressApiActivityLoader = true,
  }) : compactSize = null;

  /// The same artwork and moving orbit, sized for buttons and small controls.
  const FieldOmniLoader.compact({
    super.key,
    this.compactSize = 24,
    this.suppressApiActivityLoader = true,
  })  : message = 'Loading...',
        showMessage = false,
        showSurface = false;

  final String message;
  final bool showMessage;

  /// Adds a card behind the loader when it overlays busy screen content.
  final bool showSurface;

  /// Avoids stacking the global API indicator over this screen-level loader.
  final bool suppressApiActivityLoader;
  final double? compactSize;

  @override
  State<FieldOmniLoader> createState() => _FieldOmniLoaderState();
}

class _FieldOmniLoaderState extends State<FieldOmniLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animation;

  @override
  void initState() {
    super.initState();
    if (widget.suppressApiActivityLoader) {
      ApiRequestVisibility.suppress();
    }
    _animation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    );
  }

  @override
  void didUpdateWidget(covariant FieldOmniLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.suppressApiActivityLoader ==
        widget.suppressApiActivityLoader) {
      return;
    }
    if (widget.suppressApiActivityLoader) {
      ApiRequestVisibility.suppress();
    } else {
      ApiRequestVisibility.resume();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _animation.stop();
      _animation.value = 0.25;
    } else if (!_animation.isAnimating) {
      _animation.repeat();
    }
  }

  @override
  void dispose() {
    _animation.dispose();
    if (widget.suppressApiActivityLoader) {
      ApiRequestVisibility.resume();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.compactSize case final size?) {
      return Semantics(
        label: widget.message,
        child: SizedBox.square(
          dimension: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) => Transform.rotate(
                    angle: _animation.value * math.pi * 2,
                    child: child,
                  ),
                  child: CustomPaint(painter: _CompactOrbitPainter()),
                ),
              ),
              Container(
                width: size * 0.69,
                height: size * 0.69,
                padding: EdgeInsets.all(size * 0.06),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(size * 0.16),
                ),
                child: SvgPicture.asset(
                  'assets/app_icon/fieldomni_favicon.svg',
                  fit: BoxFit.contain,
                  excludeFromSemantics: true,
                ),
              ),
            ],
          ),
        ),
      );
    }
    final content = SizedBox(
      width: 300,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 264,
            width: 300,
            child: Stack(
              children: [
                Positioned.fill(
                  child: RepaintBoundary(
                    child: CustomPaint(
                      painter: _OrbitPainter(_animation),
                    ),
                  ),
                ),
                Positioned(
                  left: 91,
                  top: 65,
                  child: AnimatedBuilder(
                    animation: _animation,
                    child: const _BrandArtwork(),
                    builder: (context, child) => Transform.translate(
                      offset: Offset(
                        0,
                        math.sin(_animation.value * math.pi * 2) * 2.5,
                      ),
                      child: child,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (widget.showMessage) ...[
            Text(
              'FIELDOMNI',
              style: TextStyle(
                color: _navy.withValues(alpha: 0.55),
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 2.2,
              ),
            ),
            const SizedBox(height: 9),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                widget.message,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _navy,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  height: 1.45,
                ),
              ),
            ),
            const SizedBox(height: 18),
            RepaintBoundary(
              child: CustomPaint(
                size: const Size(42, 5),
                painter: _ActivityPainter(_animation),
              ),
            ),
          ],
        ],
      ),
    );

    return Semantics(
      label: widget.message,
      liveRegion: true,
      child: ExcludeSemantics(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: widget.showSurface
                  ? DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: _teal.withValues(alpha: 0.16),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _navy.withValues(alpha: 0.12),
                            blurRadius: 40,
                            offset: const Offset(0, 16),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 28),
                        child: content,
                      ),
                    )
                  : content,
            ),
          ),
        ),
      ),
    );
  }
}

class _CompactOrbitPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * 0.46;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      math.pi * 1.1,
      false,
      Paint()
        ..color = _teal
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.4, size.width * 0.08)
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(
      center + Offset(radius * 0.73, radius * 0.68),
      math.max(1, size.width * 0.055),
      Paint()..color = _navy,
    );
  }

  @override
  bool shouldRepaint(covariant _CompactOrbitPainter oldDelegate) => false;
}

class _BrandArtwork extends StatelessWidget {
  const _BrandArtwork();

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        width: 118,
        height: 118,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: _teal.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: _navy.withValues(alpha: 0.10),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        // Keep the SVG's complete square canvas and original fills. All
        // animation stays behind the artwork.
        child: SvgPicture.asset(
          'assets/app_icon/fieldomni_favicon.svg',
          width: 90,
          height: 90,
          fit: BoxFit.contain,
          excludeFromSemantics: true,
        ),
      ),
    );
  }
}

class _OrbitTrack {
  factory _OrbitTrack({
    required double width,
    required double height,
    required double tilt,
    required double phase,
    required double speed,
  }) {
    final path = Path()
      ..addOval(
        Rect.fromCenter(
          center: Offset.zero,
          width: width,
          height: height,
        ),
      );
    return _OrbitTrack._(
      path: path,
      metric: path.computeMetrics().first,
      tilt: tilt,
      phase: phase,
      speed: speed,
    );
  }

  const _OrbitTrack._({
    required this.path,
    required this.metric,
    required this.tilt,
    required this.phase,
    required this.speed,
  });

  final double tilt;
  final double phase;
  final double speed;
  final Path path;
  final PathMetric metric;
}

class _OrbitPainter extends CustomPainter {
  _OrbitPainter(this.animation) : super(repaint: animation);

  final Animation<double> animation;

  static const _center = Offset(150, 124);
  static final _tracks = [
    _OrbitTrack(
      width: 242,
      height: 174,
      tilt: -0.38,
      phase: 0,
      speed: 0.65,
    ),
    _OrbitTrack(
      width: 196,
      height: 138,
      tilt: 0.46,
      phase: 0.37,
      speed: 0.82,
    ),
    _OrbitTrack(
      width: 150,
      height: 104,
      tilt: -0.2,
      phase: 0.7,
      speed: 1,
    ),
  ];
  static final _haloPaint = Paint()
    ..shader = RadialGradient(
      colors: [
        _teal.withValues(alpha: 0.13),
        _teal.withValues(alpha: 0.04),
        _teal.withValues(alpha: 0),
      ],
      stops: const [0, 0.55, 1],
    ).createShader(Rect.fromCircle(center: _center, radius: 126));

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 300, size.height / 264);
    canvas.drawCircle(_center, 126, _haloPaint);
    for (var index = 0; index < _tracks.length; index++) {
      _paintTrack(canvas, _tracks[index], index);
    }
    _paintAccents(canvas);
    canvas.restore();
  }

  void _paintTrack(Canvas canvas, _OrbitTrack track, int index) {
    canvas.save();
    canvas.translate(_center.dx, _center.dy);
    canvas.rotate(track.tilt);

    canvas.drawPath(
      track.path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1
        ..color = _navy.withValues(alpha: 0.075),
    );

    final progress = (animation.value * track.speed + track.phase) % 1;
    final distance = progress * track.metric.length;
    final tailLength = track.metric.length * 0.065;
    final tailStart = distance - tailLength;
    final tailPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.6
      ..color = _teal.withValues(
        alpha: 0.3 + 0.3 * math.sin(progress * math.pi * 2),
      );
    if (tailStart < 0) {
      canvas.drawPath(
        track.metric.extractPath(0, distance),
        tailPaint,
      );
      canvas.drawPath(
        track.metric
            .extractPath(track.metric.length + tailStart, track.metric.length),
        tailPaint,
      );
    } else {
      canvas.drawPath(
        track.metric.extractPath(tailStart, distance),
        tailPaint,
      );
    }

    final position = track.metric.getTangentForOffset(distance)!.position;
    final pulse = (1 + math.sin(progress * math.pi * 2)) / 2;
    canvas.drawCircle(
      position,
      7 + pulse * 3,
      Paint()..color = _teal.withValues(alpha: 0.09 + pulse * 0.07),
    );
    canvas.drawCircle(
      position,
      2.4 + pulse * 0.8,
      Paint()..color = _teal.withValues(alpha: 0.8 + pulse * 0.2),
    );
    if (index == 0) {
      final glintDistance =
          (distance + track.metric.length * 0.45) % track.metric.length;
      final glint = track.metric.getTangentForOffset(glintDistance)!.position;
      canvas.drawCircle(
        glint,
        1.5,
        Paint()..color = _teal.withValues(alpha: 0.45),
      );
    }
    canvas.restore();
  }

  void _paintAccents(Canvas canvas) {
    const positions = [
      Offset(50, 63),
      Offset(257, 66),
      Offset(53, 194),
      Offset(255, 192),
    ];
    for (var index = 0; index < positions.length; index++) {
      final pulse =
          (1 + math.sin((animation.value + index / 4) * math.pi * 2)) / 2;
      final paint = Paint()
        ..color = _teal.withValues(alpha: 0.18 + pulse * 0.2)
        ..strokeWidth = 1.4
        ..strokeCap = StrokeCap.round;
      if (index.isEven) {
        final point = positions[index];
        canvas.drawLine(
          point - const Offset(3, 0),
          point + const Offset(3, 0),
          paint,
        );
        canvas.drawLine(
          point - const Offset(0, 3),
          point + const Offset(0, 3),
          paint,
        );
      } else {
        canvas.drawCircle(positions[index], 1.5 + pulse, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _OrbitPainter oldDelegate) =>
      oldDelegate.animation != animation;
}

class _ActivityPainter extends CustomPainter {
  _ActivityPainter(this.animation) : super(repaint: animation);

  final Animation<double> animation;

  @override
  void paint(Canvas canvas, Size size) {
    var x = 0.0;
    for (var index = 0; index < 3; index++) {
      final pulse =
          (1 + math.sin((animation.value * 2 - index / 3) * math.pi * 2)) / 2;
      final width = 5 + pulse * 10;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, 0, width, size.height),
          Radius.circular(size.height / 2),
        ),
        Paint()
          ..color = Color.lerp(_teal.withValues(alpha: 0.22), _teal, pulse)!,
      );
      x += width + 6;
    }
  }

  @override
  bool shouldRepaint(covariant _ActivityPainter oldDelegate) =>
      oldDelegate.animation != animation;
}
