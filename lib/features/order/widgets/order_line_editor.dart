import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';
import '../models/order_models.dart';
import 'order_widgets.dart';
import 'package:medicle_sales_rbsh/utils/constants/text_strings.dart';
import 'package:medicle_sales_rbsh/utils/constants/sizes.dart';

class OrderLineEditor extends StatefulWidget {
  const OrderLineEditor(
      {super.key,
      required this.item,
      required this.onChanged,
      required this.onRemove});
  final OrderItemDraft item;
  final ValueChanged<OrderItemDraft> onChanged;
  final VoidCallback onRemove;
  @override
  State<OrderLineEditor> createState() => _OrderLineEditorState();
}

class _OrderLineEditorState extends State<OrderLineEditor> {
  late final _quantity = TextEditingController(text: '${widget.item.quantity}');
  late final _free = TextEditingController(text: '${widget.item.freeQuantity}');
  late final _pack = TextEditingController(text: widget.item.packDescription);
  late final _rate = TextEditingController(
      text: widget.item.unitRatePaise == null
          ? ''
          : (widget.item.unitRatePaise! / 100).toStringAsFixed(2));
  late final _discount = TextEditingController(
      text: (widget.item.discountBasisPoints / 100).toStringAsFixed(2));
  late final _tax = TextEditingController(
      text: (widget.item.taxBasisPoints / 100).toStringAsFixed(2));
  late String _unit = widget.item.unit;
  bool _showPrice = false;
  void _change() {
    widget.onChanged(OrderItemDraft(
      productId: widget.item.productId,
      productName: widget.item.productName,
      salt: widget.item.salt,
      dosage: widget.item.dosage,
      quantity: int.tryParse(_quantity.text) ?? 0,
      freeQuantity: int.tryParse(_free.text) ?? (_free.text.isEmpty ? 0 : -1),
      unit: _unit,
      packDescription: _pack.text.trim(),
      unitRatePaise:
          _rate.text.isEmpty ? null : parseOrderDecimal(_rate.text) ?? -1,
      discountBasisPoints: parseOrderDecimal(_discount.text) ??
          (_discount.text.isEmpty ? 0 : -1),
      taxBasisPoints:
          parseOrderDecimal(_tax.text) ?? (_tax.text.isEmpty ? 0 : -1),
    ));
  }

  @override
  void dispose() {
    for (final c in [_quantity, _free, _pack, _rate, _discount, _tax]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: TColors.white,
            border: Border.all(color: TColors.borderSecondary),
            borderRadius: BorderRadius.circular(16)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.medication_outlined, color: TColors.primary),
            const SizedBox(width: TSizes.v10),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(widget.item.productName,
                      style: const TextStyle(fontWeight: FontWeight.w800)),
                  Text(
                      [widget.item.salt, widget.item.dosage]
                          .whereType<String>()
                          .join(' · '),
                      style: const TextStyle(
                          fontSize: TSizes.v11, color: TColors.textSecondary))
                ])),
            IconButton(
                tooltip: 'Remove ${widget.item.productName}',
                onPressed: widget.onRemove,
                icon: const Icon(Icons.close, size: TSizes.v20)),
          ]),
          const SizedBox(height: TSizes.v16),
          OrderFields(children: [
            TextFormField(
              key: ValueKey('quantity-${widget.item.productId}'),
              controller: _quantity,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6)
              ],
              onChanged: (_) => _change(),
              validator: (v) =>
                  (int.tryParse(v ?? '') ?? 0) <= 0 ? 'Enter quantity' : null,
              decoration: InputDecoration(
                  labelText: TTexts.uiTextOrderQuantity,
                  prefixIcon: IconButton(
                      tooltip: TTexts.uiTextDecreaseQuantity,
                      onPressed: () {
                        final value = int.tryParse(_quantity.text) ?? 1;
                        if (value > 1) {
                          _quantity.text = '${value - 1}';
                          _change();
                        }
                      },
                      icon: const Icon(Icons.remove, size: TSizes.v18)),
                  suffixIcon: IconButton(
                      tooltip: TTexts.uiTextIncreaseQuantity,
                      onPressed: () {
                        final value = int.tryParse(_quantity.text) ?? 0;
                        if (value < 999999) {
                          _quantity.text = '${value + 1}';
                          _change();
                        }
                      },
                      icon: const Icon(Icons.add, size: TSizes.v18))),
            ),
            DropdownButtonFormField<String>(
                value: _unit,
                decoration:
                    const InputDecoration(labelText: TTexts.uiTextOrderingUnit),
                items: orderUnits
                    .map((unit) =>
                        DropdownMenuItem(value: unit, child: Text(unit)))
                    .toList(),
                onChanged: (unit) {
                  setState(() => _unit = unit!);
                  _change();
                }),
            TextFormField(
                controller: _free,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6)
                ],
                onChanged: (_) => _change(),
                decoration: const InputDecoration(
                    labelText: TTexts.uiTextFreeQuantity,
                    helperText: TTexts.uiTextAdditionalQuantitySameUnit)),
            TextFormField(
                controller: _pack,
                onChanged: (_) => _change(),
                maxLength: 80,
                decoration: const InputDecoration(
                    labelText: TTexts.uiTextPackDetailsOptional,
                    hintText: TTexts.uiTextEG10Strips10Tablets,
                    counterText: '')),
          ]),
          const SizedBox(height: TSizes.v8),
          TextButton.icon(
              onPressed: () => setState(() => _showPrice = !_showPrice),
              icon: Icon(_showPrice ? Icons.expand_less : Icons.expand_more),
              label: Text(_showPrice
                  ? 'Hide estimated pricing'
                  : 'Add estimated pricing (optional)')),
          AnimatedSize(
              duration: MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : const Duration(milliseconds: 220),
              alignment: Alignment.topCenter,
              child: _showPrice
                  ? Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: OrderFields(children: [
                        _priceField(_rate, 'Rate / ${_unit.toLowerCase()} (₹)',
                            percentage: false),
                        _priceField(_discount, 'Discount %'),
                        _priceField(_tax, 'Tax %'),
                      ]))
                  : const SizedBox(width: double.infinity)),
          if (widget.item.unitRatePaise != null &&
              widget.item.validate() == null) ...[
            const SizedBox(height: TSizes.v12),
            Align(
                alignment: Alignment.centerRight,
                child: OrderTag(
                    'Line estimate ${orderMoney(widget.item.totalPaise)}')),
          ],
        ]),
      );
  Widget _priceField(TextEditingController controller, String label,
          {bool percentage = true}) =>
      TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: (_) => _change(),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
          LengthLimitingTextInputFormatter(10)
        ],
        validator: (value) {
          if (value == null || value.isEmpty) return null;
          final parsed = parseOrderDecimal(value);
          return parsed == null || (percentage && parsed > 10000)
              ? 'Enter ${percentage ? '0–100' : 'a valid amount'} (up to 2 decimals)'
              : null;
        },
        decoration: InputDecoration(labelText: label),
      );
}
