import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import '../../../../utils/constants/colors.dart';

class Home20Reveal extends StatelessWidget {
  const Home20Reveal({super.key, required this.child, this.index = 0});
  final Widget child;
  final int index;
  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 650),
      curve: Interval((index % 4) * 0.1, 1, curve: Curves.easeOutCubic),
      child: child,
      builder: (_, value, child) => Opacity(
          opacity: value,
          child: Transform.translate(
              offset: Offset(0, 24 * (1 - value)),
              child: Transform.scale(
                  scale: 0.97 + 0.03 * value,
                  alignment: Alignment.topCenter,
                  child: child))),
    );
  }
}

class Home20Header extends StatelessWidget {
  const Home20Header(
      {super.key,
      required this.title,
      required this.subtitle,
      required this.controls});
  final String title, subtitle;
  final Widget controls;
  @override
  Widget build(BuildContext context) =>
      LayoutBuilder(builder: (_, constraints) {
        final greeting = Home20Reveal(
            child: Row(children: [
          const Icon(Icons.waving_hand_rounded,
              color: TColors.secondary, size: 32),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: constraints.maxWidth >= 650 ? 24 : 20,
                        fontWeight: FontWeight.w700,
                        color: TColors.textPrimary)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: const TextStyle(color: TColors.textSecondary)),
              ])),
        ]));
        final actions = Home20Reveal(index: 1, child: controls);
        if (constraints.maxWidth >= 700) {
          return Row(children: [
            Expanded(child: greeting),
            const SizedBox(width: 20),
            actions
          ]);
        }
        return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              greeting,
              const SizedBox(height: 12),
              Align(alignment: Alignment.centerRight, child: actions),
            ]);
      });
}

class Home20Clock extends StatefulWidget {
  const Home20Clock({super.key, this.compact = false});
  final bool compact;
  @override
  State<Home20Clock> createState() => _Home20ClockState();
}

class _Home20ClockState extends State<Home20Clock> {
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.symmetric(
            horizontal: widget.compact ? 6 : 12,
            vertical: widget.compact ? 4 : 8),
        child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!widget.compact) ...[
                const Icon(Icons.access_time_rounded,
                    size: 18, color: TColors.primary),
                const SizedBox(width: 8),
              ],
              if (widget.compact) ...[
                Text(DateFormat('dd MMM yyyy').format(DateTime.now()),
                    key: const ValueKey('home20-header-date'),
                    style: const TextStyle(fontSize: 10, color: TColors.white)),
                const SizedBox(width: 8),
              ],
              Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(DateFormat('hh:mm a').format(DateTime.now()),
                        key: const ValueKey('home20-clock'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 13,
                            color: widget.compact
                                ? TColors.white
                                : TColors.textPrimary,
                            fontWeight: FontWeight.w600)),
                    if (!widget.compact)
                      Text(DateFormat('dd MMM yyyy').format(DateTime.now()),
                          style: const TextStyle(
                              fontSize: 10, color: TColors.textSecondary)),
                  ]),
            ]),
      );
}

class Home20BannerSlider extends StatefulWidget {
  const Home20BannerSlider({super.key});
  @override
  State<Home20BannerSlider> createState() => _Home20BannerSliderState();
}

class _Home20BannerSliderState extends State<Home20BannerSlider>
    with WidgetsBindingObserver {
  final _pages = PageController();
  Timer? _timer;
  int _current = 0;
  bool _reducedMotion = false;
  bool _active = true;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reducedMotion = MediaQuery.disableAnimationsOf(context);
    _start();
  }

  void _start() {
    _timer?.cancel();
    if (!_active || _reducedMotion) return;
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted && _pages.hasClients) _go((_current + 1) % 3);
    });
  }

  void _go(int page) {
    if (_reducedMotion) {
      _pages.jumpToPage(page);
    } else {
      _pages.animateToPage(page,
          duration: const Duration(milliseconds: 420),
          curve: Curves.easeInOutCubic);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _active = state == AppLifecycleState.resumed;
    _start();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pages.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
      height: 300,
      child: Stack(children: [
        Listener(
          onPointerDown: (_) => _timer?.cancel(),
          onPointerUp: (_) => _start(),
          onPointerCancel: (_) => _start(),
          child: PageView.builder(
              controller: _pages,
              itemCount: 3,
              onPageChanged: (page) => setState(() => _current = page),
              itemBuilder: (_, page) => Home20Banner(slide: page)),
        ),
        Positioned(
            left: 16,
            right: 16,
            bottom: 10,
            child: Row(children: [
              for (var i = 0; i < 3; i++)
                Semantics(
                    label: 'Banner ${i + 1} of 3',
                    selected: _current == i,
                    button: true,
                    child: InkWell(
                        onTap: () {
                          _go(i);
                          _start();
                        },
                        child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 10),
                            child: AnimatedContainer(
                                duration: const Duration(milliseconds: 240),
                                width: _current == i ? 24 : 7,
                                height: 7,
                                decoration: BoxDecoration(
                                    color: _current == i
                                        ? TColors.primary
                                        : TColors.borderPrimary,
                                    borderRadius:
                                        BorderRadius.circular(20)))))),
              const Spacer(),
              IconButton(
                  tooltip: 'Previous banner',
                  onPressed: () {
                    _go((_current + 2) % 3);
                    _start();
                  },
                  icon: const Icon(Icons.chevron_left, color: TColors.primary)),
              IconButton(
                  tooltip: 'Next banner',
                  onPressed: () {
                    _go((_current + 1) % 3);
                    _start();
                  },
                  icon:
                      const Icon(Icons.chevron_right, color: TColors.primary)),
            ])),
      ]));
}

class Home20Grid extends StatelessWidget {
  const Home20Grid(
      {super.key, required this.columns, required this.children, this.gap = 8});
  final int columns;
  final List<Widget> children;
  final double gap;
  @override
  Widget build(BuildContext context) => _AlignedHomeRows(
        columns: columns,
        gap: gap,
        children: [
          for (var i = 0; i < children.length; i++)
            Home20Reveal(index: i, child: children[i])
        ],
      );
}

class _AlignedHomeRows extends MultiChildRenderObjectWidget {
  const _AlignedHomeRows(
      {required this.columns, required this.gap, required super.children});
  final int columns;
  final double gap;
  @override
  RenderObject createRenderObject(BuildContext context) =>
      _HomeRowsLayout(columns, gap);
  @override
  void updateRenderObject(
      BuildContext context, covariant _HomeRowsLayout renderObject) {
    renderObject.update(columns, gap);
  }
}

class _HomeRowParentData extends ContainerBoxParentData<RenderBox> {}

class _HomeRowsLayout extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox,
            ContainerBoxParentData<RenderBox>>,
        RenderBoxContainerDefaultsMixin<RenderBox,
            ContainerBoxParentData<RenderBox>> {
  _HomeRowsLayout(this.columns, this.gap);
  int columns;
  double gap;
  void update(int newColumns, double newGap) {
    if (columns == newColumns && gap == newGap) return;
    columns = newColumns;
    gap = newGap;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! ContainerBoxParentData<RenderBox>) {
      child.parentData = _HomeRowParentData();
    }
  }

  @override
  void performLayout() {
    final items = getChildrenAsList();
    final width = constraints.maxWidth;
    final cellWidth = (width - gap * (columns - 1)) / columns;
    var y = 0.0;
    for (var start = 0; start < items.length; start += columns) {
      final count = math.min(columns, items.length - start);
      final widths = <double>[];
      var height = 0.0;
      for (var index = 0; index < count; index++) {
        final childWidth =
            index == count - 1 ? width - index * (cellWidth + gap) : cellWidth;
        widths.add(childWidth);
        final child = items[start + index];
        child.layout(BoxConstraints.tightFor(width: childWidth),
            parentUsesSize: true);
        height = math.max(height, child.size.height);
      }
      for (var index = 0; index < count; index++) {
        final child = items[start + index];
        child.layout(
            BoxConstraints.tightFor(width: widths[index], height: height),
            parentUsesSize: true);
        (child.parentData! as ContainerBoxParentData<RenderBox>).offset =
            Offset(index * (cellWidth + gap), y);
      }
      y += height + gap;
    }
    size = constraints.constrain(Size(width, items.isEmpty ? 0 : y - gap));
  }

  @override
  void paint(PaintingContext context, Offset offset) =>
      defaultPaint(context, offset);
  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);
}

class Home20Card extends StatelessWidget {
  const Home20Card(
      {super.key,
      required this.title,
      required this.icon,
      required this.child,
      this.sample = false,
      this.action,
      this.onAction});
  final String title;
  final IconData icon;
  final Widget child;
  final bool sample;
  final String? action;
  final VoidCallback? onAction;
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: TColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: TColors.borderSecondary),
          boxShadow: [
            BoxShadow(
                color: TColors.textPrimary.withValues(alpha: 0.025),
                blurRadius: 12,
                offset: const Offset(0, 4))
          ]),
      child: LayoutBuilder(
          builder: (context, constraints) =>
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                SizedBox(
                    height: 32,
                    child: Row(children: [
                      Icon(icon, color: TColors.primary, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                          child: Text(title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  color: TColors.textPrimary))),
                      if (action != null)
                        TextButton(
                            onPressed: onAction,
                            style: TextButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 6),
                                minimumSize: const Size(0, 32)),
                            child: Text(action!,
                                style: const TextStyle(
                                    fontSize: 11, color: TColors.info))),
                    ])),
                const SizedBox(height: 6),
                if (constraints.hasBoundedHeight)
                  Expanded(child: child)
                else
                  child,
              ])));
}

class Home20SampleBadge extends StatelessWidget {
  const Home20SampleBadge({super.key});
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
          color: TColors.warningBg, borderRadius: BorderRadius.circular(5)),
      child: const Text('SAMPLE PREVIEW',
          style: TextStyle(
              color: TColors.warning,
              fontSize: 9,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5)));
}

class Home20Metric extends StatelessWidget {
  const Home20Metric(
      {super.key,
      required this.title,
      required this.value,
      required this.subtitle,
      required this.icon,
      required this.color,
      required this.sample});
  final String title, value, subtitle;
  final IconData icon;
  final Color color;
  final bool sample;
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: TColors.white,
          border: Border.all(color: TColors.borderSecondary),
          borderRadius: BorderRadius.circular(14)),
      child: Row(children: [
        Container(
            width: 56,
            height: 62,
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.09),
                borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, size: 32, color: color)),
        const SizedBox(width: 14),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: const TextStyle(fontSize: 12, color: TColors.textPrimary)),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 24,
                  color: TColors.textPrimary)),
          Text(subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: color, fontSize: 12)),
        ])),
      ]));
}

class Home20ListRow extends StatelessWidget {
  const Home20ListRow(
      {super.key,
      required this.title,
      required this.subtitle,
      required this.icon,
      this.trailing});
  final String title, subtitle;
  final IconData icon;
  final String? trailing;
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(children: [
        Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
                color: TColors.cardPinkLight,
                borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: TColors.primary, size: 20)),
        const SizedBox(width: 10),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: TColors.textPrimary)),
          const SizedBox(height: 3),
          Text(subtitle,
              style:
                  const TextStyle(fontSize: 11, color: TColors.textSecondary)),
        ])),
        if (trailing != null)
          Padding(
              padding: const EdgeInsets.only(left: 6),
              child: Text(trailing!,
                  style: const TextStyle(
                      fontSize: 11,
                      color: TColors.info,
                      fontWeight: FontWeight.w600))),
      ]));
}

class Home20Ring extends StatelessWidget {
  const Home20Ring({super.key, required this.value, required this.label});
  final double value;
  final String label;
  @override
  Widget build(BuildContext context) => SizedBox(
      width: 100,
      height: 100,
      child: Stack(alignment: Alignment.center, children: [
        SizedBox.expand(
            child: CircularProgressIndicator(
                value: value.clamp(0, 1),
                strokeWidth: 10,
                color: TColors.success,
                backgroundColor: TColors.borderSecondary)),
        Column(mainAxisSize: MainAxisSize.min, children: [
          Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: TColors.textPrimary)),
          const Text('Confirmed',
              style: TextStyle(fontSize: 10, color: TColors.textSecondary))
        ]),
      ]));
}

class Home20Performance extends StatelessWidget {
  const Home20Performance({super.key});
  @override
  Widget build(BuildContext context) => SizedBox(
      height: 180,
      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        for (var i = 0; i < 6; i++)
          Expanded(
              child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                            [
                              '12.5K',
                              '18.2K',
                              '26.4K',
                              '22.1K',
                              '16.8K',
                              '8.9K'
                            ][i],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 10, color: TColors.textSecondary)),
                        const SizedBox(height: 6),
                        Container(
                            height: [53.0, 78.0, 110.0, 94.0, 71.0, 38.0][i],
                            decoration: BoxDecoration(
                                color: i == 5
                                    ? TColors.primary
                                    : TColors.primary.withValues(alpha: 0.15),
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(5)))),
                        const SizedBox(height: 8),
                        Text(['Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep'][i],
                            style: const TextStyle(
                                fontSize: 10, color: TColors.textSecondary)),
                      ]))),
      ]));
}

class Home20Banner extends StatelessWidget {
  const Home20Banner({super.key, this.slide = 0});
  final int slide;
  @override
  Widget build(BuildContext context) => ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
          height: 300,
          child: Stack(fit: StackFit.expand, children: [
            Image.asset('assets/images/home20_banner.png',
                fit: BoxFit.cover,
                errorBuilder: (_, error, stack) =>
                    const ColoredBox(color: TColors.cardPink)),
            DecoratedBox(
                decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
              TColors.cardPinkLight,
              TColors.cardPinkLight.withValues(alpha: 0.9),
              TColors.white.withValues(alpha: 0)
            ], stops: const [
              0,
              0.32,
              0.72
            ]))),
            Padding(
                padding: const EdgeInsets.fromLTRB(22, 22, 22, 48),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                          [
                            'Product spotlight',
                            'Portfolio focus',
                            'Field inspiration'
                          ][slide],
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: TColors.primary)),
                      const SizedBox(height: 8),
                      Text(
                          [
                            'Care that\nconnects.',
                            'Discover your\nportfolio.',
                            'Make every\nvisit count.'
                          ][slide],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 28,
                              height: 1.15,
                              fontWeight: FontWeight.w800,
                              color: TColors.textPrimary)),
                      const SizedBox(height: 10),
                      Text(
                          [
                            'Explore your portfolio.\nPlan your next conversation.',
                            'Find your next product focus.\nPrepare for meaningful conversations.',
                            'Review your plan.\nConnect with your territory.'
                          ][slide],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 12, color: TColors.textSecondary)),
                      const SizedBox(height: 12),
                      const Row(children: [
                        Icon(Icons.medication_outlined,
                            size: 18, color: TColors.primary),
                        SizedBox(width: 6),
                        Expanded(
                            child: Text('Pharmaceutical product showcase',
                                style: TextStyle(
                                    fontSize: 10, color: TColors.primary)))
                      ]),
                    ])),
          ])));
}

class Home20TerritoryPreview extends StatelessWidget {
  const Home20TerritoryPreview({super.key});
  @override
  Widget build(BuildContext context) => ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
          height: 350,
          child: Stack(children: [
            Positioned.fill(child: CustomPaint(painter: _TerritoryPainter())),
            const Positioned(
                left: 14,
                top: 18,
                child: _MapLabel('Samastipur City', '12 doctors · 8 chemists')),
            const Positioned(
                right: 14,
                top: 135,
                child: _MapLabel('Area X', '8 doctors · 6 chemists')),
            const Positioned(
                left: 32,
                bottom: 24,
                child:
                    _MapLabel('Samastipur Rural', '10 doctors · 7 chemists')),
            const Align(
                alignment: Alignment.center,
                child:
                    Icon(Icons.location_on, color: TColors.primary, size: 48)),
          ])));
}

class _MapLabel extends StatelessWidget {
  const _MapLabel(this.title, this.subtitle);
  final String title, subtitle;
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: TColors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
                color: TColors.textPrimary.withValues(alpha: 0.06),
                blurRadius: 12)
          ]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: TColors.textPrimary)),
        const SizedBox(height: 3),
        Text(subtitle,
            style: const TextStyle(fontSize: 10, color: TColors.textSecondary))
      ]));
}

class _TerritoryPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = TColors.successBg);
    final road = Paint()
      ..color = TColors.white
      ..strokeWidth = 8;
    for (var i = 0; i < 10; i++) {
      canvas.drawLine(Offset(i * size.width / 8 - 40, 0),
          Offset(i * size.width / 8 + 80, size.height), road);
      canvas.drawLine(Offset(0, i * 55), Offset(size.width, i * 55 + 30), road);
    }
    final colors = [
      TColors.info,
      TColors.warning,
      TColors.primary,
      TColors.success
    ];
    for (var i = 0; i < 4; i++) {
      final x = (i % 2) * size.width / 2;
      final y = (i ~/ 2) * size.height / 2;
      final path = Path()
        ..moveTo(x + 12, y + 10)
        ..lineTo(x + size.width / 2 - 8, y + 28)
        ..lineTo(x + size.width / 2 - 20, y + size.height / 2 - 5)
        ..lineTo(x + 24, y + size.height / 2 - 18)
        ..close();
      canvas.drawPath(path, Paint()..color = colors[i].withValues(alpha: 0.16));
      canvas.drawPath(
          path,
          Paint()
            ..color = colors[i].withValues(alpha: 0.6)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5);
      for (var j = 0; j < 3; j++) {
        final dx = x + size.width / 4 + math.sin(j + i) * 50;
        final dy = y + 50 + j * 30;
        canvas.drawCircle(Offset(dx, dy), 7, Paint()..color = colors[i]);
        canvas.drawCircle(Offset(dx, dy), 3, Paint()..color = TColors.white);
      }
    }
  }

  @override
  bool shouldRepaint(_TerritoryPainter oldDelegate) => false;
}

class Home20AppBarGreeting extends StatelessWidget {
  const Home20AppBarGreeting({super.key, required this.user});
  final Map<String, dynamic> user;
  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 17
            ? 'Good afternoon'
            : 'Good evening';
    return LayoutBuilder(
        builder: (_, constraints) => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$greeting, ${user['name'] ?? 'Welcome'}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: constraints.maxWidth < 240 ? 12 : 16,
                        fontWeight: FontWeight.w700,
                        color: TColors.white)),
                const SizedBox(height: 2),
                Text(
                    '${user['role'] ?? 'Sales'}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 10, color: TColors.white)),
              ],
            ));
  }
}

class Home20ProfileButton extends StatelessWidget {
  const Home20ProfileButton({super.key, required this.user});
  final Map<String, dynamic> user;
  @override
  Widget build(BuildContext context) {
    final name = '${user['name'] ?? 'Welcome'}';
    final initials = name
        .split(' ')
        .where((s) => s.isNotEmpty)
        .take(2)
        .map((s) => s[0])
        .join();
    return IconButton(
      tooltip: 'User profile',
      onPressed: () => showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
                title: Text(name),
                content: Text(
                    '${user['role'] ?? 'Sales'}${user['department'] == null ? '' : '\n${user['department']}'}'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'))
                ],
              )),
      icon: CircleAvatar(
          radius: 16,
          backgroundColor: TColors.cardPink,
          child: Text(initials,
              style: const TextStyle(color: TColors.primary, fontSize: 12))),
    );
  }
}
