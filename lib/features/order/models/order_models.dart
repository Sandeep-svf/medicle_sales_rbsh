import 'dart:typed_data';

enum OrderSyncState { pending, syncing, failed }

const orderUnits = [
  'Units',
  'Strips',
  'Boxes',
  'Bottles',
  'Tubes',
  'Vials',
  'Packs'
];
const orderCustomerTypes = ['Doctor', 'Clinic', 'Pharmacy', 'Stockist'];
const orderPaymentTerms = [
  'To be agreed',
  'Cash on delivery',
  'Advance',
  'Credit'
];

class OrderItemDraft {
  const OrderItemDraft({
    required this.productId,
    required this.productName,
    this.salt,
    this.dosage,
    required this.quantity,
    this.unit = 'Units',
    this.freeSample = false,
    this.freeQuantity = 0,
    this.packDescription,
    this.unitRatePaise,
    this.discountBasisPoints = 0,
    this.taxBasisPoints = 0,
  });

  final String productId;
  final String productName;
  final String? salt;
  final String? dosage;
  final int quantity;
  final String unit;
  // Retained for orders saved by version 1, where an entire line was free.
  final bool freeSample;
  final int freeQuantity;
  final String? packDescription;
  final int? unitRatePaise;
  final int discountBasisPoints;
  final int taxBasisPoints;

  int get paidQuantity => freeSample ? 0 : quantity;
  int get sampleQuantity => freeQuantity + (freeSample ? quantity : 0);
  int get dispatchQuantity => quantity + freeQuantity;
  bool get hasPrice => paidQuantity == 0 || unitRatePaise != null;
  int get grossPaise => paidQuantity * (unitRatePaise ?? 0);
  int get discountPaise => (grossPaise * discountBasisPoints + 5000) ~/ 10000;
  int get taxablePaise => grossPaise - discountPaise;
  int get taxPaise => (taxablePaise * taxBasisPoints + 5000) ~/ 10000;
  int get totalPaise => taxablePaise + taxPaise;

  String? validate() {
    if (productId.trim().isEmpty || productName.trim().isEmpty)
      return 'Choose a valid product.';
    if (quantity < 1 || quantity > 999999)
      return 'Order quantity must be between 1 and 999,999.';
    if (freeQuantity < 0 || freeQuantity > 999999)
      return 'Free quantity must be between 0 and 999,999.';
    if (!orderUnits.contains(unit)) return 'Choose a valid ordering unit.';
    if (unitRatePaise != null &&
        (unitRatePaise! < 0 || unitRatePaise! > 999999999))
      return 'Enter a valid unit rate.';
    if (discountBasisPoints < 0 ||
        discountBasisPoints > 10000 ||
        taxBasisPoints < 0 ||
        taxBasisPoints > 10000)
      return 'Discount and tax must be between 0 and 100%.';
    return null;
  }

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'productName': productName,
        'salt': salt,
        'dosage': dosage,
        'quantity': quantity,
        'unit': unit,
        'freeSample': freeSample,
        'freeQuantity': freeQuantity,
        'packDescription': packDescription,
        'unitRatePaise': unitRatePaise,
        'discountBasisPoints': discountBasisPoints,
        'taxBasisPoints': taxBasisPoints,
      };
}

class OrderDraft {
  const OrderDraft({
    required this.doctorName,
    this.doctorId,
    this.clinicName,
    this.specialization,
    this.area,
    this.headOffice,
    this.deliveryAddress,
    this.notes,
    required this.orderDate,
    required this.items,
    required this.attachmentBytes,
    required this.attachmentName,
    required this.attachmentMime,
    this.customerType = 'Doctor',
    this.contactPhone,
    this.stockistName,
    this.purchaseOrderReference,
    this.requestedDeliveryDate,
    this.priority = 'Normal',
    this.paymentTerms = 'To be agreed',
    this.creditDays,
  });
  final String doctorName;
  final String? doctorId,
      clinicName,
      specialization,
      area,
      headOffice,
      deliveryAddress,
      notes;
  final DateTime orderDate;
  final List<OrderItemDraft> items;
  final Uint8List attachmentBytes;
  final String attachmentName, attachmentMime;
  final String customerType;
  final String? contactPhone, stockistName, purchaseOrderReference;
  final DateTime? requestedDeliveryDate;
  final String priority, paymentTerms;
  final int? creditDays;

  String? validate() {
    if (doctorName.trim().isEmpty) return 'Enter the customer name.';
    if (!orderCustomerTypes.contains(customerType))
      return 'Choose a customer type.';
    if (items.isEmpty) return 'Add at least one product.';
    if (items.map((e) => e.productId).toSet().length != items.length)
      return 'Combine duplicate products into one line.';
    for (final item in items) {
      final error = item.validate();
      if (error != null) return error;
    }
    if (attachmentBytes.isEmpty || attachmentBytes.length > 20 * 1024 * 1024)
      return 'Attach a PDF or image up to 20 MB.';
    if (!['application/pdf', 'image/jpeg', 'image/png']
        .contains(attachmentMime)) return 'Use a PDF, JPG or PNG attachment.';
    if (requestedDeliveryDate != null &&
        DateTime(requestedDeliveryDate!.year, requestedDeliveryDate!.month,
                requestedDeliveryDate!.day)
            .isBefore(DateTime(orderDate.year, orderDate.month, orderDate.day)))
      return 'Delivery date cannot be before the order date.';
    if (!['Normal', 'Urgent'].contains(priority) ||
        !orderPaymentTerms.contains(paymentTerms))
      return 'Choose valid order terms.';
    if (paymentTerms == 'Credit' &&
        (creditDays == null || creditDays! < 1 || creditDays! > 365))
      return 'Enter credit days between 1 and 365.';
    return null;
  }
}

class LocalOrderItem extends OrderItemDraft {
  const LocalOrderItem(
      {required super.productId,
      required super.productName,
      super.salt,
      super.dosage,
      required super.quantity,
      required super.unit,
      required super.freeSample,
      super.freeQuantity,
      super.packDescription,
      super.unitRatePaise,
      super.discountBasisPoints,
      super.taxBasisPoints});
}

class OrderTotals {
  OrderTotals(Iterable<OrderItemDraft> items)
      : items = List.unmodifiable(items);
  final List<OrderItemDraft> items;
  bool get fullyPriced => items.isNotEmpty && items.every((e) => e.hasPrice);
  int get unpricedLines => items.where((e) => !e.hasPrice).length;
  int get subtotalPaise => items.fold(0, (sum, e) => sum + e.grossPaise);
  int get discountPaise => items.fold(0, (sum, e) => sum + e.discountPaise);
  int get taxPaise => items.fold(0, (sum, e) => sum + e.taxPaise);
  int get totalPaise => subtotalPaise - discountPaise + taxPaise;
  Map<String, int> get quantitiesByUnit {
    final result = <String, int>{};
    for (final item in items) {
      result.update(item.unit, (qty) => qty + item.dispatchQuantity,
          ifAbsent: () => item.dispatchQuantity);
    }
    return result;
  }

  String get quantityLabel => quantitiesByUnit.entries
      .map((e) => '${e.value} ${e.key.toLowerCase()}')
      .join(' · ');
}

class LocalOrder {
  const LocalOrder({
    required this.localId,
    required this.clientGeneratedId,
    required this.doctorName,
    this.doctorId,
    this.clinicName,
    this.specialization,
    this.area,
    this.headOffice,
    this.deliveryAddress,
    this.notes,
    required this.orderDate,
    required this.createdAt,
    required this.updatedAt,
    required this.syncState,
    this.lastError,
    required this.attachmentName,
    required this.attachmentMime,
    required this.attachmentPath,
    required this.items,
    this.customerType = 'Doctor',
    this.contactPhone,
    this.stockistName,
    this.purchaseOrderReference,
    this.requestedDeliveryDate,
    this.priority = 'Normal',
    this.paymentTerms = 'To be agreed',
    this.creditDays,
  });
  final String localId, clientGeneratedId, doctorName;
  final String? doctorId,
      clinicName,
      specialization,
      area,
      headOffice,
      deliveryAddress,
      notes;
  final DateTime orderDate, createdAt, updatedAt;
  final OrderSyncState syncState;
  final String? lastError;
  final String attachmentName, attachmentMime, attachmentPath;
  final List<LocalOrderItem> items;
  final String customerType;
  final String? contactPhone, stockistName, purchaseOrderReference;
  final DateTime? requestedDeliveryDate;
  final String priority, paymentTerms;
  final int? creditDays;
  int get totalQuantity =>
      items.fold(0, (sum, item) => sum + item.dispatchQuantity);
  OrderTotals get totals => OrderTotals(items);
  String get reference =>
      'ORD-${clientGeneratedId.substring(0, clientGeneratedId.length < 8 ? clientGeneratedId.length : 8).toUpperCase()}';
  bool get attachmentIsPdf => attachmentMime == 'application/pdf';
  String get statusLabel => switch (syncState) {
        OrderSyncState.pending => 'Awaiting upload',
        OrderSyncState.syncing => 'Uploading',
        OrderSyncState.failed => 'Needs retry',
      };
}

/// Parses a non-negative decimal into hundredths without floating point math.
int? parseOrderDecimal(String text) {
  final value = text.trim();
  if (!RegExp(r'^\d+(\.\d{0,2})?$').hasMatch(value)) return null;
  final parts = value.split('.');
  final whole = int.tryParse(parts.first);
  if (whole == null || whole > 9999999) return null;
  return whole * 100 +
      int.parse(parts.length == 1 ? '0' : parts.last.padRight(2, '0'));
}
