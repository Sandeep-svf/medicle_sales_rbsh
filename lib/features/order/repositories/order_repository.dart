import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../database/order_database.dart';
import '../models/order_models.dart';
import '../services/order_pdf_service.dart';

class OrderRepository {
  OrderRepository(
      {required OrderDatabase database, String? attachmentDirectory})
      : _database = database,
        _attachmentDirectory = attachmentDirectory;

  final OrderDatabase _database;
  final String? _attachmentDirectory;
  static const _uuid = Uuid();

  Future<String> _attachmentsPath() async {
    final root = _attachmentDirectory ??
        path.join(
            (await getApplicationSupportDirectory()).path, 'offline_orders');
    await Directory(root).create(recursive: true);
    return root;
  }

  Future<String> create(OrderDraft draft) async {
    final validation = draft.validate();
    if (validation != null) throw FormatException(validation);
    final localId = _uuid.v4();
    final now = DateTime.now().toUtc();
    final generated = draft.attachmentBytes.isEmpty;
    final attachmentName = generated
        ? 'order-${localId.substring(0, 8)}.pdf'
        : draft.attachmentName;
    final attachmentMime = generated ? 'application/pdf' : draft.attachmentMime;
    final bytes = generated
        ? await OrderPdfService.build(
            draft: draft,
            reference: 'ORD-${localId.substring(0, 8).toUpperCase()}')
        : draft.attachmentBytes;
    final directory = await _attachmentsPath();
    final safeName = attachmentName.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    final attachmentPath = path.join(directory, '${localId}_$safeName');
    await File(attachmentPath).writeAsBytes(bytes, flush: true);

    try {
      await _database.raw.transaction((transaction) async {
        await transaction.insert('orders', {
          'local_id': localId,
          'client_generated_id': localId,
          'customer_type': draft.customerType,
          'contact_phone': draft.contactPhone,
          'stockist_name': draft.stockistName,
          'purchase_order_reference': draft.purchaseOrderReference,
          'requested_delivery_date':
              draft.requestedDeliveryDate?.toIso8601String(),
          'priority': draft.priority,
          'payment_terms': draft.paymentTerms,
          'credit_days': draft.creditDays,
          'doctor_name': draft.doctorName.trim(),
          'doctor_id': draft.doctorId?.trim().isEmpty == true
              ? null
              : draft.doctorId?.trim(),
          'clinic_name': draft.clinicName?.trim(),
          'specialization': draft.specialization?.trim(),
          'area': draft.area?.trim(),
          'head_office': draft.headOffice?.trim(),
          'delivery_address': draft.deliveryAddress?.trim(),
          'notes': draft.notes?.trim(),
          'order_date': draft.orderDate.toUtc().toIso8601String(),
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
          'sync_state': OrderSyncState.pending.name,
          'attachment_name': attachmentName,
          'attachment_mime': attachmentMime,
          'attachment_path': attachmentPath,
        });
        for (final item in draft.items) {
          await transaction.insert('order_items', {
            'order_local_id': localId,
            'product_id': item.productId,
            'product_name': item.productName,
            'salt': item.salt,
            'dosage': item.dosage,
            'quantity': item.quantity,
            'unit': item.unit,
            'free_quantity': item.freeQuantity,
            'pack_description': item.packDescription,
            'unit_rate_paise': item.unitRatePaise,
            'discount_basis_points': item.discountBasisPoints,
            'tax_basis_points': item.taxBasisPoints,
            'free_sample': item.freeSample ? 1 : 0,
          });
        }
      });
      return localId;
    } catch (_) {
      try {
        await File(attachmentPath).delete();
      } on FileSystemException {
        // The database transaction is the source of truth; a missing file is harmless.
      }
      rethrow;
    }
  }

  Future<List<LocalOrder>> recentOrders({required DateTime cutoff}) async {
    final rows = await _database.raw.query(
      'orders',
      where:
          'created_at >= ? OR sync_state IN (\'pending\', \'failed\', \'syncing\')',
      whereArgs: [cutoff.toUtc().toIso8601String()],
      orderBy: 'created_at DESC',
    );
    return Future.wait(rows.map(_readOrder));
  }

  Future<LocalOrder?> findById(String id) async {
    final rows = await _database.raw
        .query('orders', where: 'local_id = ?', whereArgs: [id], limit: 1);
    return rows.isEmpty ? null : _readOrder(rows.single);
  }

  Future<List<LocalOrder>> pendingOrders(
      {int limit = 10, String afterId = ''}) async {
    final rows = await _database.raw.query(
      'orders',
      // Include syncing rows so an app killed mid-upload retries them on the
      // next launch instead of leaving them permanently stuck.
      where: 'local_id > ? AND sync_state IN (?, ?, ?)',
      whereArgs: [
        afterId,
        OrderSyncState.pending.name,
        OrderSyncState.failed.name,
        OrderSyncState.syncing.name,
      ],
      orderBy: 'local_id ASC',
      limit: limit,
    );
    return Future.wait(rows.map(_readOrder));
  }

  Future<void> markSyncing(String localId) async {
    await _database.raw.update(
      'orders',
      {
        'sync_state': OrderSyncState.syncing.name,
        'last_error': null,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      },
      where: 'local_id = ?',
      whereArgs: [localId],
    );
  }

  Future<void> markFailed(String localId, Object error) async {
    await _database.raw.update(
      'orders',
      {
        'sync_state': OrderSyncState.failed.name,
        'last_error': error.toString(),
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      },
      where: 'local_id = ?',
      whereArgs: [localId],
    );
  }

  Future<void> deleteLocal(String localId, {String? attachmentPath}) async {
    await _database.raw.transaction((transaction) async {
      await transaction.delete(
        'order_items',
        where: 'order_local_id = ?',
        whereArgs: [localId],
      );
      await transaction.delete(
        'orders',
        where: 'local_id = ?',
        whereArgs: [localId],
      );
    });
    if (attachmentPath != null) {
      try {
        await File(attachmentPath).delete();
      } on FileSystemException {
        // The attachment may already have been removed after a successful upload.
      }
    }
  }

  Future<LocalOrder> _readOrder(Map<String, Object?> row) async {
    final itemRows = await _database.raw.query(
      'order_items',
      where: 'order_local_id = ?',
      whereArgs: [row['local_id']],
      orderBy: 'id',
    );
    return LocalOrder(
      localId: row['local_id'] as String,
      clientGeneratedId: row['client_generated_id'] as String,
      customerType: row['customer_type'] as String? ?? 'Doctor',
      contactPhone: row['contact_phone'] as String?,
      stockistName: row['stockist_name'] as String?,
      purchaseOrderReference: row['purchase_order_reference'] as String?,
      requestedDeliveryDate:
          DateTime.tryParse(row['requested_delivery_date'] as String? ?? ''),
      priority: row['priority'] as String? ?? 'Normal',
      paymentTerms: row['payment_terms'] as String? ?? 'To be agreed',
      creditDays: row['credit_days'] as int?,
      doctorName: row['doctor_name'] as String,
      doctorId: row['doctor_id'] as String?,
      clinicName: row['clinic_name'] as String?,
      specialization: row['specialization'] as String?,
      area: row['area'] as String?,
      headOffice: row['head_office'] as String?,
      deliveryAddress: row['delivery_address'] as String?,
      notes: row['notes'] as String?,
      orderDate: DateTime.parse(row['order_date'] as String),
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
      syncState: OrderSyncState.values.byName(row['sync_state'] as String),
      lastError: row['last_error'] as String?,
      attachmentName: row['attachment_name'] as String,
      attachmentMime: row['attachment_mime'] as String,
      attachmentPath: row['attachment_path'] as String,
      items: itemRows
          .map(
            (item) => LocalOrderItem(
              productId: item['product_id'] as String,
              productName: item['product_name'] as String,
              salt: item['salt'] as String?,
              dosage: item['dosage'] as String?,
              quantity: item['quantity'] as int,
              unit: item['unit'] as String,
              freeQuantity: item['free_quantity'] as int? ?? 0,
              packDescription: item['pack_description'] as String?,
              unitRatePaise: item['unit_rate_paise'] as int?,
              discountBasisPoints: item['discount_basis_points'] as int? ?? 0,
              taxBasisPoints: item['tax_basis_points'] as int? ?? 0,
              freeSample: item['free_sample'] == 1,
            ),
          )
          .toList(),
    );
  }

  Uint8List? readAttachment(LocalOrder order) {
    final file = File(order.attachmentPath);
    return file.existsSync() ? file.readAsBytesSync() : null;
  }
}
