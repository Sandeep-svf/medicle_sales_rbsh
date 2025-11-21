// models/invoice_model.dart
import 'dart:convert';

class InvoiceResponse {
  final bool success;
  final List<Invoice> data;
  final Pagination? pagination;

  InvoiceResponse({
    required this.success,
    required this.data,
    this.pagination,
  });

  factory InvoiceResponse.fromJson(Map<String, dynamic> json) {
    return InvoiceResponse(
      success: json['success'] ?? false,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => Invoice.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
      pagination: json['pagination'] != null
          ? Pagination.fromJson(json['pagination'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'data': data.map((e) => e.toJson()).toList(),
    'pagination': pagination?.toJson(),
  };
}

class Invoice {
  final String id;
  final String? partyName;
  final String? stockistId;
  final String? invoiceNumber;
  final String? invoiceDate;
  final String? invoiceImageUrl;
  final String? invoiceImagePublicId;
  final String? trackingLink;
  final String? awbNumber;
  final String? courierCompanyName;
  final String? status;
  final String? remarks;
  final String? createdBy;
  final String? updatedBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Stockist? stockist;
  final Creator? creator;
  final Updater? updater;

  Invoice({
    required this.id,
    this.partyName,
    this.stockistId,
    this.invoiceNumber,
    this.invoiceDate,
    this.invoiceImageUrl,
    this.invoiceImagePublicId,
    this.trackingLink,
    this.awbNumber,
    this.courierCompanyName,
    this.status,
    this.remarks,
    this.createdBy,
    this.updatedBy,
    this.createdAt,
    this.updatedAt,
    this.stockist,
    this.creator,
    this.updater,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    DateTime? _tryParse(String? s) {
      if (s == null) return null;
      try {
        return DateTime.parse(s);
      } catch (_) {
        return null;
      }
    }

    return Invoice(
      id: (json['id'] ?? '') as String,
      partyName: json['party_name'] as String?,
      stockistId: json['stockist_id'] as String?,
      invoiceNumber: json['invoice_number'] as String?,
      invoiceDate: json['invoice_date'] as String?,
      invoiceImageUrl: json['invoice_image_url'] as String?,
      invoiceImagePublicId: json['invoice_image_public_id'] as String?,
      trackingLink: json['tracking_link'] as String?,
      awbNumber: json['awb_number'] as String?,
      courierCompanyName: json['courier_company_name'] as String?,
      status: json['status'] as String?,
      remarks: json['remarks'] as String?,
      createdBy: json['created_by'] as String?,
      updatedBy: json['updated_by'] as String?,
      createdAt: _tryParse(json['created_at'] as String?),
      updatedAt: _tryParse(json['updated_at'] as String?),
      stockist: json['Stockist'] != null
          ? Stockist.fromJson(json['Stockist'] as Map<String, dynamic>)
          : null,
      creator: json['creator'] != null
          ? Creator.fromJson(json['creator'] as Map<String, dynamic>)
          : null,
      updater: json['updater'] != null
          ? Updater.fromJson(json['updater'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'party_name': partyName,
    'stockist_id': stockistId,
    'invoice_number': invoiceNumber,
    'invoice_date': invoiceDate,
    'invoice_image_url': invoiceImageUrl,
    'invoice_image_public_id': invoiceImagePublicId,
    'tracking_link': trackingLink,
    'awb_number': awbNumber,
    'courier_company_name': courierCompanyName,
    'status': status,
    'remarks': remarks,
    'created_by': createdBy,
    'updated_by': updatedBy,
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
    'Stockist': stockist?.toJson(),
    'creator': creator?.toJson(),
    'updater': updater?.toJson(),
  };
}

class Stockist {
  final String id;
  final String? firmName;
  final String? emailAddress;
  final String? mobileNumber;
  final String? registeredOfficeAddress;

  Stockist({
    required this.id,
    this.firmName,
    this.emailAddress,
    this.mobileNumber,
    this.registeredOfficeAddress,
  });

  factory Stockist.fromJson(Map<String, dynamic> json) => Stockist(
    id: (json['id'] ?? '') as String,
    firmName: json['firm_name'] as String?,
    emailAddress: json['email_address'] as String?,
    mobileNumber: json['mobile_number'] as String?,
    registeredOfficeAddress: json['registered_office_address'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'firm_name': firmName,
    'email_address': emailAddress,
    'mobile_number': mobileNumber,
    'registered_office_address': registeredOfficeAddress,
  };
}

class Creator {
  final String id;
  final String? name;
  final String? email;

  Creator({
    required this.id,
    this.name,
    this.email,
  });

  factory Creator.fromJson(Map<String, dynamic> json) => Creator(
    id: (json['id'] ?? '') as String,
    name: json['name'] as String?,
    email: json['email'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
  };
}

class Updater {
  final String id;
  final String? name;
  final String? email;

  Updater({
    required this.id,
    this.name,
    this.email,
  });

  factory Updater.fromJson(Map<String, dynamic> json) => Updater(
    id: (json['id'] ?? '') as String,
    name: json['name'] as String?,
    email: json['email'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
  };
}

class Pagination {
  final int? currentPage;
  final int? totalPages;
  final int? totalCount;
  final int? limit;

  Pagination({
    this.currentPage,
    this.totalPages,
    this.totalCount,
    this.limit,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    currentPage: json['currentPage'] as int?,
    totalPages: json['totalPages'] as int?,
    totalCount: json['totalCount'] as int?,
    limit: json['limit'] as int?,
  );

  Map<String, dynamic> toJson() => {
    'currentPage': currentPage,
    'totalPages': totalPages,
    'totalCount': totalCount,
    'limit': limit,
  };
}
