import 'package:flutter/material.dart';
import '../../product/model/ProductModel.dart';
import '../../../utils/constants/colors.dart';
import 'order_widgets.dart';

class OrderProductPicker extends StatefulWidget {
  const OrderProductPicker(
      {super.key, required this.products, required this.selectedIds});
  final List<Product> products;
  final Set<String> selectedIds;
  @override
  State<OrderProductPicker> createState() => _OrderProductPickerState();
}

class _OrderProductPickerState extends State<OrderProductPicker> {
  final _selected = <String>{};
  String _query = '';
  @override
  Widget build(BuildContext context) {
    final products = {
      for (final product in widget.products)
        if (product.id.isNotEmpty) product.id: product
    }.values.where((p) {
      final searchable =
          '${p.name} ${p.salt ?? ''} ${p.dosage ?? ''} ${p.description ?? ''}'
              .toLowerCase();
      return _query
          .trim()
          .toLowerCase()
          .split(RegExp(r'\s+'))
          .every(searchable.contains);
    }).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    return Theme(
        data: orderTheme(context),
        child: SafeArea(
            child: Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
          child: SizedBox(
              height: MediaQuery.sizeOf(context).height * .85,
              child: Column(children: [
                Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 8, 12),
                    child: Row(children: [
                      const Expanded(
                          child: Text('Product catalogue',
                              style: TextStyle(
                                  fontSize: 21, fontWeight: FontWeight.w800))),
                      IconButton(
                          tooltip: 'Close catalogue',
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close)),
                    ])),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                        autofocus: false,
                        onChanged: (text) => setState(() => _query = text),
                        decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.search),
                            hintText: 'Search name, salt or strength'))),
                Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    child: Row(children: [
                      Expanded(
                          child: Text('${products.length} available products',
                              style: const TextStyle(
                                  fontSize: 12, color: TColors.textSecondary))),
                      const OrderTag('Choose multiple', icon: Icons.checklist)
                    ])),
                Expanded(
                    child: products.isEmpty
                        ? const Center(
                            child: Padding(
                                padding: EdgeInsets.all(24),
                                child: Text(
                                    'No products found. Refresh the catalogue while connected, or try a different search.',
                                    textAlign: TextAlign.center)))
                        : ListView.builder(
                            itemCount: products.length,
                            itemBuilder: (context, index) {
                              final product = products[index];
                              final alreadyAdded =
                                  widget.selectedIds.contains(product.id);
                              return CheckboxListTile(
                                value: alreadyAdded ||
                                    _selected.contains(product.id),
                                onChanged: alreadyAdded
                                    ? null
                                    : (value) => setState(() {
                                          if (value == true) {
                                            _selected.add(product.id);
                                          } else {
                                            _selected.remove(product.id);
                                          }
                                        }),
                                controlAffinity:
                                    ListTileControlAffinity.trailing,
                                secondary: const CircleAvatar(
                                    backgroundColor: TColors.primary_shade50,
                                    child: Icon(Icons.medication_outlined,
                                        color: TColors.primary)),
                                title: Text(product.name,
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700)),
                                subtitle: Text(
                                    alreadyAdded
                                        ? 'Already in this order'
                                        : [product.salt, product.dosage]
                                            .whereType<String>()
                                            .where((e) => e.isNotEmpty)
                                            .join(' · '),
                                    style: const TextStyle(fontSize: 12)),
                              );
                            })),
                Padding(
                    padding: const EdgeInsets.all(20),
                    child: SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _selected.isEmpty
                              ? null
                              : () => Navigator.pop(
                                  context,
                                  {
                                    for (final p in widget.products)
                                      if (_selected.contains(p.id)) p.id: p
                                  }.values.toList()),
                          icon: const Icon(Icons.add_shopping_cart),
                          label: Text(
                              'Add ${_selected.length} product${_selected.length == 1 ? '' : 's'}'),
                        ))),
              ])),
        )));
  }
}
