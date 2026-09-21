import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../utils/constants/colors.dart';
import '../models/order_models.dart';

String orderMoney(int paise) =>
    NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2)
        .format(paise / 100);
String orderDateLabel(DateTime value) =>
    DateFormat('dd MMM yyyy').format(value.toLocal());

ThemeData orderTheme(BuildContext context) => Theme.of(context).copyWith(
      colorScheme: ColorScheme.fromSeed(
          seedColor: TColors.primary, brightness: Brightness.light),
      scaffoldBackgroundColor: const Color(0xFFF8F6F7),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFFAF8F9),
        labelStyle: const TextStyle(fontSize: 13, color: TColors.textSecondary),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: TColors.borderSecondary)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: TColors.borderSecondary)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: TColors.primary, width: 1.5)),
      ),
      filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
        backgroundColor: TColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
      )),
    );

class OrderSection extends StatelessWidget {
  const OrderSection(
      {super.key,
      required this.title,
      required this.icon,
      required this.child,
      this.subtitle,
      this.trailing});
  final String title;
  final String? subtitle;
  final IconData icon;
  final Widget child;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFEDE6E9))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: TColors.primary_shade50,
                    borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: TColors.primary, size: 20)),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w800)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 3),
                    Text(subtitle!,
                        style: const TextStyle(
                            fontSize: 12,
                            color: TColors.textSecondary,
                            height: 1.4))
                  ],
                ])),
            if (trailing != null) trailing!,
          ]),
          const SizedBox(height: 20),
          child,
        ]),
      );
}

class OrderTag extends StatelessWidget {
  const OrderTag(this.label,
      {super.key, this.color = TColors.primary, this.icon});
  final String label;
  final Color color;
  final IconData? icon;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
            color: color.withValues(alpha: .08),
            borderRadius: BorderRadius.circular(8)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 5)
          ],
          Flexible(
              child: Text(label,
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                      color: color))),
        ]),
      );
}

class OrderSummary extends StatelessWidget {
  const OrderSummary({super.key, required this.items, this.showLines = false});
  final List<OrderItemDraft> items;
  final bool showLines;
  @override
  Widget build(BuildContext context) {
    final total = OrderTotals(items);
    return OrderSection(
        title: 'Order summary',
        icon: Icons.receipt_long_outlined,
        subtitle: '${items.length} product lines',
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (items.isEmpty)
            const Text('Your selected products will appear here.',
                style: TextStyle(color: TColors.textSecondary)),
          if (showLines)
            ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.productName,
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                      Text(
                          '${item.paidQuantity} ordered + ${item.sampleQuantity} free · ${item.unit}${item.packDescription?.isNotEmpty == true ? ' · ${item.packDescription}' : ''}',
                          style: const TextStyle(
                              fontSize: 12, color: TColors.textSecondary)),
                    ]))),
          if (items.isNotEmpty) ...[
            Text(total.quantityLabel,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            const Divider(height: 28),
            _amount('Subtotal', total.subtotalPaise),
            _amount('Discount', -total.discountPaise),
            _amount('Tax estimate', total.taxPaise),
            const Divider(height: 24),
            Row(children: [
              const Expanded(
                  child: Text('Estimated total',
                      style: TextStyle(fontWeight: FontWeight.w800))),
              Flexible(
                  child: Text(orderMoney(total.totalPaise),
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: TColors.primary_shade700)))
            ]),
            const SizedBox(height: 10),
            Text(
                total.fullyPriced
                    ? 'Based on entered rates. Final pricing and availability are confirmed by your office.'
                    : '${total.unpricedLines} product line(s) have no rate. This estimate includes priced lines only.',
                style: const TextStyle(
                    fontSize: 11, height: 1.5, color: TColors.textSecondary)),
          ],
        ]));
  }

  Widget _amount(String label, int value) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        Expanded(
            child: Text(label,
                style: const TextStyle(
                    color: TColors.textSecondary, fontSize: 12))),
        Text(orderMoney(value),
            style: const TextStyle(fontWeight: FontWeight.w600))
      ]));
}

class OrderFields extends StatelessWidget {
  const OrderFields({super.key, required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) =>
      LayoutBuilder(builder: (context, constraints) {
        final columns = constraints.maxWidth >= 560 ? 2 : 1;
        return Wrap(
            spacing: 14,
            runSpacing: 16,
            children: children
                .map((child) => SizedBox(
                    width:
                        (constraints.maxWidth - (columns - 1) * 14) / columns,
                    child: child))
                .toList());
      });
}
