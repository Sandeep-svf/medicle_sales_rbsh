import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../product/model/ProductModel.dart';
import '../../../utils/constants/colors.dart';
import '../models/order_models.dart';
import '../repositories/order_repository.dart';
import '../widgets/order_widgets.dart';
import '../widgets/order_line_editor.dart';
import '../widgets/order_product_picker.dart';

class OrderAttachment {
  const OrderAttachment(this.bytes, this.name, this.mime);
  final Uint8List bytes;
  final String name, mime;
}

class OrderCreateScreen extends StatefulWidget {
  const OrderCreateScreen(
      {required this.repository,
      required this.products,
      this.refreshProducts,
      this.pickAttachment,
      super.key});
  final OrderRepository repository;
  final List<Product> products;
  final Future<List<Product>> Function()? refreshProducts;
  final Future<OrderAttachment?> Function()? pickAttachment;
  @override
  State<OrderCreateScreen> createState() => _OrderCreateScreenState();
}

class _OrderCreateScreenState extends State<OrderCreateScreen> {
  final _form = GlobalKey<FormState>();
  final _scroll = ScrollController();
  final _name = TextEditingController();
  final _clinic = TextEditingController();
  final _phone = TextEditingController();
  final _area = TextEditingController();
  final _office = TextEditingController();
  final _address = TextEditingController();
  final _stockist = TextEditingController();
  final _po = TextEditingController();
  final _credit = TextEditingController();
  final _notes = TextEditingController();
  final _lines = <OrderItemDraft>[];
  late List<Product> _products = widget.products;
  String _customerType = 'Doctor',
      _priority = 'Normal',
      _terms = 'To be agreed';
  DateTime _date = DateTime.now();
  DateTime? _delivery;
  OrderAttachment? _attachment;
  int _step = 0;
  bool _saving = false, _picking = false, _refreshing = false, _saved = false;
  String? _error;
  bool get _dirty =>
      _lines.isNotEmpty ||
      _attachment != null ||
      _name.text.isNotEmpty ||
      [
        _clinic,
        _phone,
        _area,
        _office,
        _address,
        _stockist,
        _po,
        _credit,
        _notes
      ].any((c) => c.text.isNotEmpty);

  @override
  void dispose() {
    for (final c in [
      _name,
      _clinic,
      _phone,
      _area,
      _office,
      _address,
      _stockist,
      _po,
      _credit,
      _notes
    ]) {
      c.dispose();
    }
    _scroll.dispose();
    super.dispose();
  }

  Future<bool> _leave() async {
    if (_saving) return false;
    if (!_dirty || _saved) return true;
    return await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
                  title: const Text('Discard this order?'),
                  content: const Text(
                      'This order has not been saved. Continue editing to keep your changes.'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Keep editing')),
                    FilledButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Discard'))
                  ],
                )) ??
        false;
  }

  Future<void> _pick({bool camera = false}) async {
    if (_picking) return;
    setState(() {
      _picking = true;
      _error = null;
    });
    try {
      OrderAttachment? picked;
      if (!camera && widget.pickAttachment != null) {
        picked = await widget.pickAttachment!();
      } else if (camera) {
        final image = await ImagePicker().pickImage(
            source: ImageSource.camera, imageQuality: 85, maxWidth: 2200);
        if (image != null)
          picked = OrderAttachment(
              await image.readAsBytes(), image.name, 'image/jpeg');
      } else {
        final result = await FilePicker.platform.pickFiles(
            type: FileType.custom,
            allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
            withData: false);
        if (result != null) {
          final file = result.files.single;
          if (file.size > 20 * 1024 * 1024)
            throw const FormatException('Choose a file smaller than 20 MB.');
          final extension = (file.extension ?? '').toLowerCase();
          final mime = {
            'pdf': 'application/pdf',
            'jpg': 'image/jpeg',
            'jpeg': 'image/jpeg',
            'png': 'image/png'
          }[extension];
          final bytes = file.bytes ??
              (file.path == null ? null : await File(file.path!).readAsBytes());
          if (mime == null || bytes == null)
            throw const FormatException(
                'Choose a readable PDF, JPG or PNG file.');
          picked = OrderAttachment(bytes, file.name, mime);
        }
      }
      if (picked != null &&
          (picked.bytes.isEmpty || picked.bytes.length > 20 * 1024 * 1024))
        throw const FormatException(
            'Attach a non-empty PDF or image up to 20 MB.');
      if (mounted && picked != null) setState(() => _attachment = picked);
    } catch (error) {
      if (mounted)
        setState(() => _error = error is FormatException
            ? error.message
            : 'Could not open the attachment. Please try again.');
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  Future<void> _addProducts() async {
    final selected = await showModalBottomSheet<List<Product>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => OrderProductPicker(
          products: _products,
          selectedIds: _lines.map((e) => e.productId).toSet()),
    );
    if (!mounted || selected == null) return;
    setState(() {
      for (final p in selected) {
        if (_lines.every((e) => e.productId != p.id))
          _lines.add(OrderItemDraft(
              productId: p.id,
              productName: p.name,
              salt: p.salt,
              dosage: p.dosage,
              quantity: 1));
      }
      _error = null;
    });
  }

  Future<void> _refreshCatalogue() async {
    if (_refreshing || widget.refreshProducts == null) return;
    setState(() => _refreshing = true);
    try {
      final result = await widget.refreshProducts!();
      if (mounted) setState(() => _products = result);
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  Future<void> _chooseDate(bool delivery) async {
    final today = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: delivery ? (_delivery ?? _date) : _date,
      firstDate: delivery
          ? DateTime(_date.year, _date.month, _date.day)
          : today.subtract(const Duration(days: 365)),
      lastDate: delivery ? today.add(const Duration(days: 365)) : today,
      builder: (context, child) =>
          Theme(data: orderTheme(context), child: child!),
    );
    if (picked != null && mounted)
      setState(() {
        if (delivery) {
          _delivery = picked;
        } else {
          _date = picked;
          if (_delivery?.isBefore(picked) == true) _delivery = null;
        }
      });
  }

  void _go(int step) {
    FocusScope.of(context).unfocus();
    if (step > _step && !_form.currentState!.validate()) return;
    if (step > 1 && _lines.isEmpty) {
      setState(() => _error = 'Add at least one product before reviewing.');
      return;
    }
    if (step > 1) {
      for (final line in _lines) {
        final error = line.validate();
        if (error != null) {
          setState(() => _error = '${line.productName}: $error');
          return;
        }
      }
    }
    setState(() {
      _step = step;
      _error = null;
    });
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  Future<void> _save() async {
    if (_saving || _picking) return;
    if (_attachment == null) {
      setState(
          () => _error = 'Attach a PDF or image of the order before saving.');
      return;
    }
    final draft = OrderDraft(
      doctorName: _name.text.trim(),
      clinicName: _clinic.text.trim(),
      contactPhone: _phone.text.trim(),
      customerType: _customerType,
      area: _area.text.trim(),
      headOffice: _office.text.trim(),
      deliveryAddress: _address.text.trim(),
      stockistName: _stockist.text.trim(),
      purchaseOrderReference: _po.text.trim(),
      priority: _priority,
      paymentTerms: _terms,
      creditDays: _terms == 'Credit' ? int.tryParse(_credit.text) : null,
      requestedDeliveryDate: _delivery,
      orderDate: _date,
      notes: _notes.text.trim(),
      items: List.of(_lines),
      attachmentBytes: _attachment!.bytes,
      attachmentName: _attachment!.name,
      attachmentMime: _attachment!.mime,
    );
    final error = draft.validate();
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.repository.create(draft);
      if (mounted) {
        _saved = true;
        Navigator.pop(context, true);
      }
    } catch (_) {
      if (mounted)
        setState(() => _error =
            'The order could not be saved. Your entries are still here; please try again.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Theme(
      data: orderTheme(context),
      child: Builder(
          builder: (context) => WillPopScope(
                onWillPop: _leave,
                child: Scaffold(
                  appBar: AppBar(
                    title: const Text('New order',
                        style: TextStyle(fontWeight: FontWeight.w800)),
                    backgroundColor: Colors.white,
                    surfaceTintColor: Colors.white,
                    bottom: PreferredSize(
                        preferredSize: const Size.fromHeight(62),
                        child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                            child: Row(
                                children: List.generate(
                                    3,
                                    (i) => Expanded(
                                            child: InkWell(
                                          onTap: _saving || i >= _step
                                              ? null
                                              : () => _go(i),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: AnimatedContainer(
                                              duration: const Duration(
                                                  milliseconds: 220),
                                              margin: EdgeInsets.only(
                                                  right: i < 2 ? 8 : 0),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 12,
                                                      horizontal: 8),
                                              decoration: BoxDecoration(
                                                  color: i == _step
                                                      ? TColors.primary
                                                      : TColors.primary_shade50,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12)),
                                              child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                        i < _step
                                                            ? Icons.check_circle
                                                            : [
                                                                Icons
                                                                    .person_outline,
                                                                Icons
                                                                    .medication_outlined,
                                                                Icons
                                                                    .fact_check_outlined
                                                              ][i],
                                                        size: 17,
                                                        color: i == _step
                                                            ? Colors.white
                                                            : TColors.primary),
                                                    const SizedBox(width: 5),
                                                    Flexible(
                                                        child: Text(
                                                            [
                                                              'Customer',
                                                              'Products',
                                                              'Review'
                                                            ][i],
                                                            style: TextStyle(
                                                                color: i ==
                                                                        _step
                                                                    ? Colors
                                                                        .white
                                                                    : TColors
                                                                        .primary,
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700)))
                                                  ])),
                                        )))))),
                  ),
                  bottomNavigationBar: SafeArea(
                      child: Container(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                          decoration: const BoxDecoration(
                              color: Colors.white,
                              border: Border(
                                  top: BorderSide(
                                      color: TColors.borderSecondary))),
                          child: Row(children: [
                            if (_step > 0) ...[
                              OutlinedButton(
                                  onPressed:
                                      _saving ? null : () => _go(_step - 1),
                                  child: const Text('Back')),
                              const SizedBox(width: 12)
                            ],
                            Expanded(
                                child: FilledButton.icon(
                                    key: const Key('order-next'),
                                    onPressed: _saving || _picking
                                        ? null
                                        : () => _step < 2
                                            ? _go(_step + 1)
                                            : _save(),
                                    icon: _saving
                                        ? const SizedBox.square(
                                            dimension: 18,
                                            child: CircularProgressIndicator(
                                                strokeWidth: 2))
                                        : Icon(_step == 2
                                            ? Icons.save_outlined
                                            : Icons.arrow_forward_rounded),
                                    label: Text(_saving
                                        ? 'Saving order…'
                                        : [
                                            'Choose products',
                                            'Review order',
                                            'Save order'
                                          ][_step]))),
                          ]))),
                  body: AbsorbPointer(
                      absorbing: _saving,
                      child: Form(
                          key: _form,
                          child: ListView(
                              controller: _scroll,
                              padding: const EdgeInsets.all(20),
                              children: [
                                Center(
                                    child: ConstrainedBox(
                                        constraints: const BoxConstraints(
                                            maxWidth: 1120),
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              if (_error != null)
                                                Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            bottom: 16),
                                                    child: Container(
                                                        width: double.infinity,
                                                        padding:
                                                            const EdgeInsets.all(
                                                                14),
                                                        decoration: BoxDecoration(
                                                            color:
                                                                TColors.errorBg,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12)),
                                                        child: Text(_error!,
                                                            style: const TextStyle(
                                                                color: TColors
                                                                    .error)))),
                                              TweenAnimationBuilder<double>(
                                                  key: ValueKey(_step),
                                                  tween:
                                                      Tween(begin: 0, end: 1),
                                                  duration: MediaQuery
                                                          .disableAnimationsOf(
                                                              context)
                                                      ? Duration.zero
                                                      : const Duration(
                                                          milliseconds: 280),
                                                  builder: (context, value,
                                                          child) =>
                                                      Opacity(
                                                          opacity: value,
                                                          child: Transform.translate(
                                                              offset: Offset(
                                                                  0,
                                                                  10 *
                                                                      (1 -
                                                                          value)),
                                                              child: child)),
                                                  child: switch (_step) {
                                                    0 => _customer(),
                                                    1 => _productsStep(),
                                                    _ => _review()
                                                  }),
                                            ]))),
                              ]))),
                ),
              )));

  Widget _customer() => Column(children: [
        OrderSection(
            title: 'Who is this order for?',
            subtitle: 'Customer and delivery information',
            icon: Icons.person_outline,
            child: OrderFields(children: [
              DropdownButtonFormField<String>(
                  value: _customerType,
                  decoration: const InputDecoration(labelText: 'Customer type'),
                  items: orderCustomerTypes
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setState(() => _customerType = v!)),
              _field(_name, 'Customer name *',
                  required: true, key: const Key('order-customer-name')),
              _field(
                  _clinic,
                  _customerType == 'Doctor'
                      ? 'Clinic / hospital name'
                      : 'Business / clinic name'),
              TextFormField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  maxLength: 16,
                  decoration: const InputDecoration(
                      labelText: 'Contact phone', counterText: ''),
                  validator: (v) => v != null &&
                          v.isNotEmpty &&
                          !RegExp(r'^\+?[0-9 ()-]{7,16}$').hasMatch(v)
                      ? 'Enter a valid contact number'
                      : null),
              _field(_area, 'Area / town'),
              _field(_office, 'Head office'),
              _field(_address, 'Delivery address', maxLines: 2),
              _field(_stockist, 'Supplying stockist / distributor'),
            ])),
        const SizedBox(height: 18),
        OrderSection(
            title: 'Order preferences',
            subtitle: 'Plan delivery and payment terms',
            icon: Icons.local_shipping_outlined,
            child: OrderFields(children: [
              _dateField('Order date', _date, () => _chooseDate(false)),
              _dateField(
                  'Requested delivery', _delivery, () => _chooseDate(true)),
              _field(_po, 'Customer PO / reference (optional)'),
              DropdownButtonFormField<String>(
                  value: _priority,
                  decoration: const InputDecoration(labelText: 'Priority'),
                  items: ['Normal', 'Urgent']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setState(() => _priority = v!)),
              DropdownButtonFormField<String>(
                  value: _terms,
                  decoration: const InputDecoration(labelText: 'Payment terms'),
                  items: orderPaymentTerms
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setState(() => _terms = v!)),
              if (_terms == 'Credit')
                TextFormField(
                    controller: _credit,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration:
                        const InputDecoration(labelText: 'Credit days *'),
                    validator: (v) {
                      final n = int.tryParse(v ?? '') ?? 0;
                      return n < 1 || n > 365 ? 'Enter 1–365 days' : null;
                    }),
            ])),
      ]);

  Widget _productsStep() => LayoutBuilder(builder: (context, constraints) {
        final content =
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          OrderSection(
              title: 'Build your order',
              subtitle: '${_products.length} products in your catalogue',
              icon: Icons.medication_outlined,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Wrap(spacing: 12, runSpacing: 8, children: [
                      FilledButton.icon(
                          onPressed: _addProducts,
                          icon: const Icon(Icons.add),
                          label: const Text('Add products')),
                      if (widget.refreshProducts != null)
                        TextButton.icon(
                            onPressed: _refreshing ? null : _refreshCatalogue,
                            icon: const Icon(Icons.refresh),
                            label: Text(_refreshing
                                ? 'Refreshing…'
                                : 'Refresh catalogue'))
                    ]),
                    if (_lines.isEmpty)
                      const Padding(
                          padding: EdgeInsets.only(top: 18),
                          child: Text(
                              'Select products, enter quantities and choose how each product is packed.',
                              style: TextStyle(
                                  color: TColors.textSecondary, height: 1.5))),
                  ])),
          const SizedBox(height: 18),
          ..._lines.map((line) => OrderLineEditor(
              key: ValueKey(line.productId),
              item: line,
              onChanged: (updated) => setState(() => _lines[_lines
                  .indexWhere((e) => e.productId == line.productId)] = updated),
              onRemove: () => setState(() =>
                  _lines.removeWhere((e) => e.productId == line.productId)))),
        ]);
        final summary = OrderSummary(
            items: _lines.where((e) => e.validate() == null).toList());
        return constraints.maxWidth >= 900
            ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: content),
                const SizedBox(width: 20),
                SizedBox(width: 300, child: summary)
              ])
            : Column(children: [content, summary]);
      });

  Widget _review() => Column(children: [
        OrderSection(
            title: _name.text,
            subtitle: '$_customerType · $_priority priority',
            icon: Icons.task_alt,
            trailing:
                TextButton(onPressed: () => _go(0), child: const Text('Edit')),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (_clinic.text.isNotEmpty) Text(_clinic.text),
              if (_address.text.isNotEmpty)
                Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(_address.text,
                        style: const TextStyle(color: TColors.textSecondary))),
              const SizedBox(height: 12),
              Wrap(spacing: 8, runSpacing: 8, children: [
                OrderTag(orderDateLabel(_date), icon: Icons.event),
                OrderTag(_terms == 'Credit'
                    ? '${_credit.text} days credit'
                    : _terms),
                if (_delivery != null)
                  OrderTag('Delivery ${orderDateLabel(_delivery!)}'),
                if (_po.text.isNotEmpty) OrderTag('PO ${_po.text}')
              ]),
            ])),
        const SizedBox(height: 18),
        OrderSummary(items: _lines, showLines: true),
        const SizedBox(height: 18),
        OrderSection(
            title: 'Attach order proof',
            subtitle: 'Required · PDF, JPG or PNG · up to 20 MB',
            icon: Icons.attach_file,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (_attachment != null) ...[
                Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: TColors.successBg,
                        borderRadius: BorderRadius.circular(12)),
                    child: Row(children: [
                      Icon(
                          _attachment!.mime == 'application/pdf'
                              ? Icons.picture_as_pdf_outlined
                              : Icons.image_outlined,
                          color: TColors.success),
                      const SizedBox(width: 10),
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Text(_attachment!.name,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700)),
                            Text(
                                '${(_attachment!.bytes.length / 1024).toStringAsFixed(0)} KB · stored with your order',
                                style: const TextStyle(fontSize: 11))
                          ])),
                      IconButton(
                          tooltip: 'Remove attachment',
                          onPressed: () => setState(() => _attachment = null),
                          icon: const Icon(Icons.close)),
                    ])),
                if (_attachment!.mime.startsWith('image/'))
                  Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(_attachment!.bytes,
                              height: 130,
                              cacheHeight: 260,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Text('Image attached')))),
                const SizedBox(height: 12),
              ],
              if (_picking) const LinearProgressIndicator(),
              Wrap(spacing: 12, runSpacing: 8, children: [
                OutlinedButton.icon(
                    onPressed: _picking ? null : () => _pick(),
                    icon: const Icon(Icons.upload_file_outlined),
                    label: Text(
                        _attachment == null ? 'Choose file' : 'Replace file')),
                OutlinedButton.icon(
                    onPressed: _picking ? null : () => _pick(camera: true),
                    icon: const Icon(Icons.photo_camera_outlined),
                    label: const Text('Take photo'))
              ]),
              const SizedBox(height: 16),
              _field(_notes, 'Order remarks / delivery instructions',
                  maxLines: 3),
              const SizedBox(height: 16),
              const Text(
                  'The order and attachment are saved on this device first. Keep the app open when uploading. They are removed locally only after the server confirms receipt.',
                  style: TextStyle(
                      fontSize: 12, color: TColors.textSecondary, height: 1.5)),
            ])),
      ]);

  Widget _field(TextEditingController c, String label,
          {bool required = false, int maxLines = 1, Key? key}) =>
      TextFormField(
          key: key,
          controller: c,
          maxLines: maxLines,
          textCapitalization: TextCapitalization.sentences,
          maxLength: maxLines > 1 ? 1000 : 160,
          decoration: InputDecoration(labelText: label, counterText: ''),
          validator: required
              ? (v) => v == null || v.trim().isEmpty
                  ? 'Enter the customer name'
                  : null
              : null);
  Widget _dateField(String label, DateTime? date, VoidCallback onTap) =>
      InkWell(
          onTap: onTap,
          child: InputDecorator(
              decoration: InputDecoration(
                  labelText: label,
                  suffixIcon:
                      const Icon(Icons.calendar_today_outlined, size: 18)),
              child: Text(date == null ? 'Not specified' : orderDateLabel(date),
                  style: const TextStyle(fontSize: 14))));
}
