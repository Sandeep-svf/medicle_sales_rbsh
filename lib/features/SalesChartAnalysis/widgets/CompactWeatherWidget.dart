import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../services/WeatherService.dart';

// =============================================================================
// 1. THE COMPACT WEATHER WIDGET
// =============================================================================
class CompactWeatherWidget extends StatefulWidget {
  const CompactWeatherWidget({super.key});

  @override
  State<CompactWeatherWidget> createState() => _CompactWeatherWidgetState();
}

class _CompactWeatherWidgetState extends State<CompactWeatherWidget> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.05).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: WeatherService().getDailyWeather(),
      builder: (context, snapshot) {
        // 🟢 PREVENT CRASH: Check if data exists
        if (!snapshot.hasData || snapshot.data == null) return const SizedBox();

        final data = snapshot.data!;

        // 🟢 PREVENT CRASH: Check if 'current' block exists
        if (data['current'] == null) return const SizedBox();

        final current = data['current'];
        final temp = current['temperature_2m']?.round() ?? 0;
        final code = current['weather_code'] ?? 0;

        // 🟢 PREVENT CRASH: Safely extract High/Low.
        // If daily data is missing (e.g. cached old data), use 0.
        int max = 0;
        int min = 0;
        if (data['daily'] != null &&
            data['daily']['temperature_2m_max'] != null &&
            (data['daily']['temperature_2m_max'] as List).isNotEmpty) {
          max = data['daily']['temperature_2m_max'][0].round();
          min = data['daily']['temperature_2m_min'][0].round();
        }

        return GestureDetector(
          onTap: () {
            HapticFeedback.mediumImpact();
            _showUltraPremiumSheet(context, data);
          },
          child: Container(
            constraints: const BoxConstraints(maxWidth: 160),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_WeatherIconMapper.getIcon(code), color: Colors.amber, size: 22),
                const SizedBox(width: 8),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("$temp°C", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, height: 1.0)),
                      const SizedBox(height: 2),
                      ScaleTransition(
                        scale: _pulseAnim,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("H:$max° L:$min°", style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 9)),
                            const SizedBox(width: 2),
                            const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 8)
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showUltraPremiumSheet(BuildContext context, Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _PremiumWeatherSheet(data: data),
    );
  }
}

// =============================================================================
// 2. THE POPUP SHEET (Full Forecast) - UPDATED
// =============================================================================
class _PremiumWeatherSheet extends StatefulWidget {
  final Map<String, dynamic> data;
  const _PremiumWeatherSheet({required this.data});

  @override
  State<_PremiumWeatherSheet> createState() => _PremiumWeatherSheetState();
}

class _PremiumWeatherSheetState extends State<_PremiumWeatherSheet> with TickerProviderStateMixin {
  late List<WeatherHour> _hourlyData;
  late WeatherHour _selectedHour;
  final ScrollController _scrollController = ScrollController();
  late AnimationController _floatController;
  late Animation<Offset> _floatAnim;

  @override
  void initState() {
    super.initState();
    _hourlyData = WeatherService().getRichHourlyForecast(widget.data);

    if (_hourlyData.isEmpty) {
      _hourlyData = [WeatherHour(time: "N/A", rawTime: DateTime.now(), temp: 0, code: 0, feelsLike: 0, rainChance: 0, windSpeed: 0, humidity: 0)];
    }

    final nowStr = DateFormat('h a').format(DateTime.now());
    int initialIndex = _hourlyData.indexWhere((h) => h.time == nowStr);
    if (initialIndex == -1) initialIndex = 0;
    _selectedHour = _hourlyData[initialIndex];

    _floatController = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
    _floatAnim = Tween<Offset>(begin: const Offset(0, 0.05), end: const Offset(0, -0.05)).animate(
        CurvedAnimation(parent: _floatController, curve: Curves.easeInOut)
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToIndex(initialIndex);
    });
  }

  @override
  void dispose() {
    _floatController.dispose();
    _scrollController.dispose(); // Don't forget to dispose scroll controller
    super.dispose();
  }

  // 🟢 NEW: Calculation to center the selected item
  void _scrollToIndex(int index) {
    if (!_scrollController.hasClients) return;

    // item width (70) + separator (12) = 82.0
    const double itemWidth = 82.0;
    final double screenWidth = MediaQuery.of(context).size.width;

    // Calculate offset to center the item
    // (index * itemWidth) gives position of item
    // - (screenWidth / 2) moves that position to left edge
    // + (40) accounts for half of the item itself (roughly) + padding compensation
    double offset = (index * itemWidth) - (screenWidth / 2) + 40;

    // animateTo automatically clamps if offset is out of bounds
    _scrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutQuart
    );
  }

  void _onHourSelected(WeatherHour hour) {
    if (_selectedHour == hour) return;
    setState(() => _selectedHour = hour);
    HapticFeedback.selectionClick();

    // 🟢 NEW: Trigger scroll when tapped
    final index = _hourlyData.indexOf(hour);
    if (index != -1) _scrollToIndex(index);
  }

  @override
  Widget build(BuildContext context) {
    final bool isNight = _selectedHour.rawTime.hour > 18 || _selectedHour.rawTime.hour < 6;
    final List<Color> bgColors = isNight
        ? [const Color(0xFF0F2027), const Color(0xFF203A43), const Color(0xFF2C5364)]
        : [Colors.white, const Color(0xFFE0EAFC)];
    final Color textColor = isNight ? Colors.white : const Color(0xFF1E1E2C);
    final Color accentColor = const Color(0xFFC71D52);

    return Container(
      height: 620,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: bgColors, begin: Alignment.topCenter, end: Alignment.bottomCenter),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 50, spreadRadius: 5)],
      ),
      child: Column(
        children: [
          // Handle
          Center(child: Container(margin: const EdgeInsets.only(top: 12), width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(2)))),

          // 🟢 FIXED: Wrapped HeroDisplay in Expanded to ensure it takes space,
          // but the overflow fix happens inside _HeroDisplay
          Expanded(
            child: _HeroDisplay(hour: _selectedHour, textColor: textColor, isNight: isNight, floatAnim: _floatAnim),
          ),

          // Timeline
          SizedBox(
            height: 140,
            child: ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: _hourlyData.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final hour = _hourlyData[index];
                return _AnimatedTimelineItem(
                  index: index,
                  hour: hour,
                  isSelected: hour == _selectedHour,
                  onTap: () => _onHourSelected(hour),
                  accentColor: accentColor,
                  isNight: isNight,
                );
              },
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// =============================================================================
// 3. HELPER CLASSES - UPDATED
// =============================================================================

class _HeroDisplay extends StatelessWidget {
  final WeatherHour hour;
  final Color textColor;
  final bool isNight;
  final Animation<Offset> floatAnim;

  const _HeroDisplay({required this.hour, required this.textColor, required this.isNight, required this.floatAnim});

  @override
  Widget build(BuildContext context) {
    // 🟢 FIXED: Replaced Column+Spacer with SingleChildScrollView
    // This allows the content to scroll if the screen is too short (preventing bottom overflow),
    // while LayoutBuilder ensures it fills height if space IS available.
    return LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly, // 🟢 Distributes space intelligently
                  children: [
                    // Top Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Forecast", style: TextStyle(color: textColor.withOpacity(0.6), fontSize: 14, fontWeight: FontWeight.w600)),
                            Text(DateFormat('EEEE, d MMMM').format(hour.rawTime), style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: CircleAvatar(backgroundColor: textColor.withOpacity(0.05), radius: 20, child: Icon(Icons.close, color: textColor, size: 20)),
                        )
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Middle Animated Content
                    SlideTransition(
                      position: floatAnim,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: ScaleTransition(scale: anim, child: child)),
                        child: Column(
                          key: ValueKey(hour.time),
                          children: [
                            Container(
                              width: 100, height: 100,
                              decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: (isNight ? Colors.blue : Colors.orange).withOpacity(0.3), blurRadius: 60, spreadRadius: 10)]),
                              child: Icon(_WeatherIconMapper.getIcon(hour.code), size: 80, color: isNight ? Colors.white : Colors.amber),
                            ),
                            const SizedBox(height: 4),
                            // 🟢 FIXED: Wrapped in FittedBox to prevent font overflow on small widths
                            FittedBox(child: Text("${hour.temp}°", style: TextStyle(fontSize: 76, fontWeight: FontWeight.w900, color: textColor, height: 1.0))),
                            Text(_WeatherIconMapper.getDescription(hour.code), style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: textColor.withOpacity(0.7))),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Bottom Detail Row (Wind/Humidity)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: textColor.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: textColor.withOpacity(0.05)),
                      ),
                      // 🟢 FIXED: Use IntrinsicHeight to ensure all items align,
                      // and use Wrap or standard Row. Row is fine here if items are Flexible.
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _DetailItem(icon: Icons.water_drop, label: "${hour.rainChance}%", sub: "Rain", color: Colors.blueAccent),
                          _DetailItem(icon: Icons.air, label: "${hour.windSpeed.toInt()} km/h", sub: "Wind", color: Colors.teal),
                          _DetailItem(icon: Icons.thermostat, label: "${hour.feelsLike}°", sub: "Feels", color: Colors.orange),
                          _DetailItem(icon: Icons.opacity, label: "${hour.humidity}%", sub: "Humid", color: Colors.purple),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
    );
  }
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sub;
  final Color color;
  const _DetailItem({required this.icon, required this.label, required this.sub, required this.color});

  @override
  Widget build(BuildContext context) {
    // 🟢 FIXED: Wrapped in Flexible to prevent horizontal overflow in the Row
    return Flexible(
      child: Column(
        mainAxisSize: MainAxisSize.min, // 🟢 Important: shrinks column to fit content
        children: [
          Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 20)
          ),
          const SizedBox(height: 8),
          // 🟢 FIXED: FittedBox prevents text wrapping that causes bottom overflow
          FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))
          ),
          FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(sub, style: const TextStyle(fontSize: 10, color: Colors.grey))
          ),
        ],
      ),
    );
  }
}

class _AnimatedTimelineItem extends StatefulWidget {
  final int index;
  final WeatherHour hour;
  final bool isSelected;
  final VoidCallback onTap;
  final Color accentColor;
  final bool isNight;

  const _AnimatedTimelineItem({required this.index, required this.hour, required this.isSelected, required this.onTap, required this.accentColor, required this.isNight});

  @override
  State<_AnimatedTimelineItem> createState() => _AnimatedTimelineItemState();
}

class _AnimatedTimelineItemState extends State<_AnimatedTimelineItem> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    final double delay = (widget.index * 0.05).clamp(0.0, 0.5);
    Future.delayed(Duration(milliseconds: (delay * 1000).toInt()), () {
      if(mounted) _ctrl.forward();
    });
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color bgColor = widget.isSelected ? widget.accentColor : (widget.isNight ? Colors.white.withOpacity(0.1) : Colors.white);
    final Color fgColor = widget.isSelected ? Colors.white : (widget.isNight ? Colors.white70 : Colors.black54);

    return SlideTransition(
      position: _slideAnim,
      child: FadeTransition(
        opacity: _fadeAnim,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
            width: 70,
            margin: EdgeInsets.symmetric(vertical: widget.isSelected ? 0 : 10),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(40),
              border: widget.isSelected ? null : Border.all(color: Colors.grey.withOpacity(0.2)),
              boxShadow: widget.isSelected ? [BoxShadow(color: widget.accentColor.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 8))] : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(widget.hour.time, style: TextStyle(color: fgColor, fontSize: 10, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Icon(_WeatherIconMapper.getIcon(widget.hour.code), color: widget.isSelected ? Colors.white : Colors.amber, size: 24),
                const SizedBox(height: 8),
                Text("${widget.hour.temp}°", style: TextStyle(color: fgColor, fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}



class _WeatherIconMapper {
  static IconData getIcon(int code) {
    if (code < 3) return Icons.wb_sunny_rounded;
    if (code < 50) return Icons.cloud;
    if (code < 80) return Icons.umbrella;
    return Icons.thunderstorm;
  }
  static String getDescription(int code) {
    if (code == 0) return "Clear Sky";
    if (code < 3) return "Partly Cloudy";
    if (code < 50) return "Overcast";
    if (code < 60) return "Drizzling";
    if (code < 80) return "Heavy Rain";
    return "Thunderstorm";
  }
}