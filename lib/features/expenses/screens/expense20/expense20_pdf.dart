import '../../../../utils/constants/sizes.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:medicle_sales_rbsh/utils/constants/colors.dart';

import '../../models/NewExpenseModel.dart';
import 'expense20_widgets.dart';

/// Exports saved expenses only. Never recalculates fare or DCR deductions.
class Expense20Pdf {
  static Future<Uint8List> build({
    required List<ExpenseModel> expenses,
    required String scope,
    required String userName,
    DateTime? generatedAt,
  }) async {
    final regular = await rootBundle.load('assets/fonts/Poppins-Regular.ttf');
    final bold = await rootBundle.load('assets/fonts/Poppins-Bold.ttf');
    final document = pw.Document(
        title: 'Expense 2.0 - Expense statement',
        author: userName,
        theme: pw.ThemeData.withFont(
            base: pw.Font.ttf(regular), bold: pw.Font.ttf(bold)));
    final accent = PdfColor.fromInt(TColors.primary.toARGB32());
    final ink = PdfColor.fromInt(TColors.textPrimary.toARGB32());
    final muted = PdfColor.fromInt(TColors.textSecondary.toARGB32());
    final border = PdfColor.fromInt(TColors.borderSecondary.toARGB32());
    final background = PdfColor.fromInt(TColors.light.toARGB32());
    final white = PdfColor.fromInt(TColors.white.toARGB32());
    final records = List<ExpenseModel>.of(expenses)
      ..sort((a, b) => b.date.compareTo(a.date));
    final generated = generatedAt ?? DateTime.now();
    double amount(ExpenseModel expense) {
      final value = double.tryParse(expense.amount) ?? 0;
      return value.isFinite ? value : 0;
    }

    double total(Iterable<ExpenseModel> data) =>
        data.fold(0.0, (sum, expense) => sum + amount(expense));
    String date(String value) {
      final parsed = DateTime.tryParse(value);
      return parsed == null ? value : DateFormat('dd MMM yyyy').format(parsed);
    }

    pw.Widget text(String value, {bool bold = false, PdfColor? color}) =>
        pw.Text(value,
            style: pw.TextStyle(
                fontSize: TSizes.v8,
                color: color ?? ink,
                fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal));
    pw.Widget cell(pw.Widget child) =>
        pw.Padding(padding: const pw.EdgeInsets.all(TSizes.v7), child: child);
    pw.Widget badge(ExpenseModel expense) => text(
        expense.status.isEmpty ? 'Pending' : expense.status,
        bold: true,
        color:
            PdfColor.fromInt(expense20StatusColor(expense.status).toARGB32()));
    String daType(ExpenseModel expense) => switch (expense.dailyAllowanceType) {
          'headoffice' => 'Headquarter DA',
          'ex-headquarters' => 'X Station DA',
          'outside' => 'Out of Station DA',
          _ => expense.dailyAllowanceType ?? 'Daily allowance',
        };
    String summary(ExpenseModel expense) => switch (expense.category) {
          'travel' => expense.travelDetails.isEmpty
              ? '${expense.totalDistanceKm} km'
              : '${expense.travelDetails.first.from} to '
                  '${expense.travelDetails.first.to}'
                  '${expense.travelDetails.length > 1 ? ' (+${expense.travelDetails.length - 1} legs)' : ''}',
          'daily' => daType(expense),
          _ => 'Other expense',
        };
    // A bounded row can always fit on a page, even for very long remarks.
    Iterable<String> chunks(String value) sync* {
      var start = 0;
      while (start < value.length) {
        var end = (start + 300).clamp(0, value.length);
        var newline = start - 1;
        for (var line = 0; line < 8; line++) {
          newline = value.indexOf('\n', newline + 1);
          if (newline < 0 || newline >= end) break;
          if (line == 7) end = newline + 1;
        }
        if (end < value.length) {
          final space = value.lastIndexOf(' ', end - 1);
          if (space > start) end = space + 1;
        }
        yield value.substring(start, end);
        start = end;
      }
    }

    pw.Table details(ExpenseModel expense, int index) {
      final rows = <pw.TableRow>[
        pw.TableRow(
            repeat: true,
            decoration: pw.BoxDecoration(color: background),
            children: [
              cell(text('#${index + 1} - ${expense20Type(expense.category)}',
                  bold: true, color: accent)),
              cell(text(
                  '${date(expense.date)} | '
                  '${expense20Money(amount(expense))} | ${expense.status}',
                  bold: true)),
            ])
      ];
      void detail(String label, String? value) {
        if (value == null || value.trim().isEmpty) return;
        var first = true;
        for (final chunk in chunks(value)) {
          rows.add(pw.TableRow(children: [
            cell(text(first ? label : '$label (cont.)', color: muted)),
            cell(text(chunk)),
          ]));
          first = false;
        }
      }

      detail('Claim reference', expense.id);
      if (expense.endDate != null) detail('End date', date(expense.endDate!));
      if (expense.category == 'travel') {
        for (var leg = 0; leg < expense.travelDetails.length; leg++) {
          final route = expense.travelDetails[leg];
          detail('Travel leg ${leg + 1}',
              '${route.from} to ${route.to} | ${route.km} km');
        }
        detail('Distance / rate',
            '${expense.totalDistanceKm} km | INR ${expense.ratePerKm} per km');
      }
      if (expense.dailyAllowanceType != null) {
        detail('DA type', daType(expense));
      }
      detail('Remarks / DCR deduction', expense.description);
      detail('Bill reference', expense.bill);
      detail('Payment status', expense.paymentStatus);
      detail('Payment date', expense.paymentDate);
      detail('Payment period', expense.paymentMonthYear);
      detail('Transaction ID', expense.transactionId);
      detail('Payment note', expense.paymentNote);
      return pw.Table(
          columnWidths: const {
            0: pw.FixedColumnWidth(125),
            1: pw.FlexColumnWidth(),
          },
          border: pw.TableBorder.all(color: border, width: TSizes.v0_4),
          children: rows);
    }

    document.addPage(pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(TSizes.v30),
        maxPages: records.length * 10 +
            records.fold<int>(
                0, (sum, e) => sum + (e.description.length / 300).ceil()) +
            20,
        header: (_) => pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('EXPENSE STATEMENT',
                      style: pw.TextStyle(
                          fontSize: TSizes.v19,
                          fontWeight: pw.FontWeight.bold,
                          color: accent)),
                  text('Expense 2.0 | $userName', color: muted),
                  pw.Divider(color: border),
                  pw.SizedBox(height: TSizes.v8),
                ]),
        footer: (context) => pw.Column(children: [
              pw.SizedBox(height: TSizes.v8),
              pw.Divider(color: border),
              pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    text('Saved expense amounts | INR', color: muted),
                    text('Page ${context.pageNumber} of ${context.pagesCount}',
                        color: muted),
                  ])
            ]),
        build: (_) => [
              text('Scope: $scope', bold: true),
              pw.SizedBox(height: TSizes.v4),
              text(
                  'Generated: ${DateFormat('dd MMM yyyy, HH:mm').format(generated)}'
                  ' | ${records.length} expenses',
                  color: muted),
              pw.SizedBox(height: TSizes.v16),
              pw.Row(children: [
                for (final status in [
                  'total',
                  'approved',
                  'pending',
                  'rejected'
                ])
                  pw.Expanded(
                      child: pw.Container(
                          margin: const pw.EdgeInsets.only(right: TSizes.v6),
                          padding: const pw.EdgeInsets.all(TSizes.v9),
                          decoration: pw.BoxDecoration(
                              color: background,
                              borderRadius:
                                  pw.BorderRadius.circular(TSizes.v6)),
                          child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                text(status.toUpperCase(), color: muted),
                                pw.SizedBox(height: TSizes.v5),
                                text(
                                    expense20Money(total(status == 'total'
                                        ? records
                                        : records.where((e) =>
                                            e.status.toLowerCase() == status))),
                                    bold: true,
                                    color: status == 'total'
                                        ? accent
                                        : PdfColor.fromInt(
                                            expense20StatusColor(status)
                                                .toARGB32())),
                              ]))),
              ]),
              pw.SizedBox(height: TSizes.v18),
              pw.Table(
                  columnWidths: const {
                    0: pw.FixedColumnWidth(24),
                    1: pw.FixedColumnWidth(66),
                    2: pw.FixedColumnWidth(38),
                    3: pw.FlexColumnWidth(),
                    4: pw.FixedColumnWidth(78),
                    5: pw.FixedColumnWidth(63),
                  },
                  border: pw.TableBorder.all(color: border, width: TSizes.v0_4),
                  children: [
                    pw.TableRow(
                        repeat: true,
                        decoration: pw.BoxDecoration(color: accent),
                        children: [
                          '#',
                          'Date',
                          'Type',
                          'Details',
                          'Amount (INR)',
                          'Status'
                        ]
                            .map((title) =>
                                cell(text(title, bold: true, color: white)))
                            .toList()),
                    for (var i = 0; i < records.length; i++)
                      pw.TableRow(children: [
                        cell(text('${i + 1}')),
                        cell(text(date(records[i].date))),
                        cell(text(expense20Type(records[i].category))),
                        cell(text(summary(records[i]).length > 120
                            ? '${summary(records[i]).substring(0, 117)}...'
                            : summary(records[i]))),
                        cell(text(expense20Money(amount(records[i])),
                            bold: true)),
                        cell(badge(records[i])),
                      ]),
                  ]),
              pw.SizedBox(height: TSizes.v18),
              text('CLAIM DETAILS & REMARKS', bold: true, color: accent),
              pw.SizedBox(height: TSizes.v8),
              for (var i = 0; i < records.length; i++) ...[
                details(records[i], i),
                pw.SizedBox(height: TSizes.v12),
              ],
            ]));
    return document.save();
  }
}
