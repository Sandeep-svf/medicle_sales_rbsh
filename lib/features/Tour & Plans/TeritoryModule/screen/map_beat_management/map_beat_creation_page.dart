import 'package:flutter/material.dart';
import '../../../../../utils/constants/colors.dart';
import '../../model/area_model.dart';

class MapBeatCreationPage extends StatefulWidget {
  const MapBeatCreationPage(
      {super.key,
      required this.areas,
      required this.initialName,
      required this.initialColor,
      required this.editing,
      required this.onSave,
      this.onDraftChanged});
  final List<AreaModel> areas;
  final String initialName;
  final String initialColor;
  final bool editing;
  final Future<bool> Function(String name, String color) onSave;
  final void Function(String name, String color)? onDraftChanged;

  @override
  State<MapBeatCreationPage> createState() => _MapBeatCreationPageState();
}

class _MapBeatCreationPageState extends State<MapBeatCreationPage> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _name;
  late String _color;
  bool _busy = false;
  String? _error;

  String _hex(Color color) =>
      '#${(color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.initialName);
    _color = widget.initialColor;
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy || !_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final saved = await widget.onSave(_name.text.trim(), _color);
      if (!mounted) return;
      if (saved) {
        Navigator.pop(context);
        return;
      }
      setState(() => _error =
          'Unable to save. Your selected areas are retained; please retry.');
    } catch (_) {
      if (mounted) setState(() => _error = 'Unable to save. Please retry.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
        canPop: !_busy,
        child: Scaffold(
          backgroundColor: TColors.primaryBackground,
          appBar: AppBar(
              title: Text(widget.editing ? 'Edit beat' : 'Create beat'),
              automaticallyImplyLeading: !_busy),
          body: Center(
              child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 960),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                        key: _form,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Review your territory',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall),
                              const SizedBox(height: 8),
                              Text(
                                  '${widget.areas.map((a) => a.pincode).toSet().length} pincodes · ${widget.areas.length} registered areas'),
                              const SizedBox(height: 20),
                              Card(
                                  child: Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            TextFormField(
                                                controller: _name,
                                                enabled: !_busy,
                                                maxLength: 100,
                                                onChanged: (value) => widget
                                                    .onDraftChanged
                                                    ?.call(value, _color),
                                                decoration: const InputDecoration(
                                                    labelText: 'Beat name',
                                                    hintText:
                                                        'e.g. Darbhanga morning beat',
                                                    border:
                                                        OutlineInputBorder()),
                                                validator: (value) =>
                                                    value == null ||
                                                            value.trim().isEmpty
                                                        ? 'Enter a beat name.'
                                                        : null),
                                            const SizedBox(height: 16),
                                            const Text('Choose a beat color',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.w700)),
                                            const SizedBox(height: 8),
                                            const Text(
                                                '15 distinct options. Shared areas can belong to multiple beats.'),
                                            const SizedBox(height: 12),
                                            Wrap(
                                                spacing: 8,
                                                runSpacing: 8,
                                                children: [
                                                  for (final entry in TColors
                                                      .mapBeatPalette.entries)
                                                    ChoiceChip(
                                                        label: Text(entry.key),
                                                        avatar: CircleAvatar(
                                                            radius: 9,
                                                            backgroundColor:
                                                                entry.value),
                                                        selected: _color
                                                                .toUpperCase() ==
                                                            _hex(entry.value),
                                                        selectedColor: entry
                                                            .value
                                                            .withValues(
                                                                alpha: .2),
                                                        onSelected: _busy
                                                            ? null
                                                            : (_) {
                                                                setState(() =>
                                                                    _color = _hex(
                                                                        entry
                                                                            .value));
                                                                widget
                                                                    .onDraftChanged
                                                                    ?.call(
                                                                        _name
                                                                            .text,
                                                                        _color);
                                                              })
                                                ]),
                                            if (!TColors.mapBeatPalette.values
                                                .any((color) =>
                                                    _hex(color) ==
                                                    _color.toUpperCase()))
                                              Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 12),
                                                  child: Text(
                                                      'Existing beat color $_color will be retained unless you choose a new color.')),
                                          ]))),
                              const SizedBox(height: 16),
                              Card(
                                  child: Column(children: [
                                const ListTile(
                                    leading: Icon(Icons.checklist),
                                    title: Text('Selected areas')),
                                for (final area in widget.areas)
                                  ListTile(
                                    leading: const Icon(
                                        Icons.location_on_outlined,
                                        color: TColors.primary),
                                    title: Text(area.postOffice),
                                    subtitle: Text('Pincode ${area.pincode}'),
                                  ),
                              ])),
                              if (_error != null)
                                Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Text(_error!,
                                        style: const TextStyle(
                                            color: TColors.error))),
                            ])),
                  ))),
          bottomNavigationBar: SafeArea(
              child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(children: [
                    Expanded(
                        child: OutlinedButton(
                            onPressed:
                                _busy ? null : () => Navigator.pop(context),
                            child: const Text('Back to selection'))),
                    const SizedBox(width: 12),
                    Expanded(
                        child: FilledButton.icon(
                            onPressed: _busy ? null : _submit,
                            icon: _busy
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2))
                                : const Icon(Icons.check),
                            label: Text(_busy
                                ? 'Saving…'
                                : widget.editing
                                    ? 'Save changes'
                                    : 'Create beat'))),
                  ]))),
        ),
      );
}
