import 'package:flutter/material.dart';
import '../../../../../utils/constants/colors.dart';

typedef MapBeatBrowserEntry = ({
  String id,
  String name,
  Color color,
  List<String> areas
});

/// A bounded, collapsible legend keeps the map available while browsing beats.
class MapBeatBrowser extends StatefulWidget {
  const MapBeatBrowser(
      {super.key,
      required this.beats,
      required this.onView,
      this.busy = false});
  final List<MapBeatBrowserEntry> beats;
  final ValueChanged<String> onView;
  final bool busy;
  @override
  State<MapBeatBrowser> createState() => _MapBeatBrowserState();
}

class _MapBeatBrowserState extends State<MapBeatBrowser> {
  Future<void> _browse() async {
    final id = await Navigator.of(context).push<String>(MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) => Scaffold(
        backgroundColor: TColors.white,
        appBar: AppBar(
            backgroundColor: TColors.white,
            title: Text('Your beats (${widget.beats.length})')),
        body: widget.beats.isEmpty
            ? const Center(
                child: Text(
                    'No beats yet. Select areas to create your first beat.'))
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: widget.beats.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, index) {
                  final beat = widget.beats[index];
                  return Card(
                      color: TColors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                CircleAvatar(
                                    backgroundColor: beat.color, radius: 10),
                                const SizedBox(width: 12),
                                Expanded(
                                    child: Text(beat.name,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 18))),
                                Text('${beat.areas.length} areas'),
                              ]),
                              const SizedBox(height: 12),
                              if (beat.areas.isEmpty)
                                const Text(
                                    'No linked areas returned for this beat.'),
                              for (final area in beat.areas)
                                Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(children: [
                                      Icon(Icons.location_on_outlined,
                                          size: 18, color: beat.color),
                                      const SizedBox(width: 8),
                                      Expanded(child: Text(area)),
                                    ])),
                              Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton.icon(
                                    onPressed: widget.busy
                                        ? null
                                        : () => Navigator.pop(context, beat.id),
                                    icon: const Icon(Icons.my_location),
                                    label: const Text('Show beat on map'),
                                  )),
                            ]),
                      ));
                },
              ),
      ),
    ));
    if (id != null && mounted) widget.onView(id);
  }

  @override
  Widget build(BuildContext context) =>
      Column(mainAxisSize: MainAxisSize.min, children: [
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: _browse,
          child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(children: [
                const Icon(Icons.route_outlined,
                    size: 20, color: TColors.primary),
                const SizedBox(width: 8),
                Expanded(
                    child: Text('Your beats (${widget.beats.length})',
                        style: const TextStyle(fontWeight: FontWeight.w700))),
                const Text('Browse', style: TextStyle(color: TColors.primary)),
                const Icon(Icons.open_in_full, size: 18),
              ])),
        ),
        if (widget.beats.isNotEmpty)
          SizedBox(
              height: 34,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: widget.beats.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, index) {
                  final beat = widget.beats[index];
                  return ActionChip(
                      avatar:
                          CircleAvatar(backgroundColor: beat.color, radius: 6),
                      label: Text(beat.name),
                      onPressed: _browse);
                },
              )),
      ]);
}
