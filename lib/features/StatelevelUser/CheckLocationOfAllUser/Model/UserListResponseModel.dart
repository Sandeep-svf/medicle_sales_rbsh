class UserListResponse {
  bool? success;
  String? message;
  Pagination? pagination;
  List<Usert>? users;
  Statey? state;
  int? headOfficesCount;

  UserListResponse({
    this.success,
    this.message,
    this.pagination,
    this.users,
    this.state,
    this.headOfficesCount,
  });

  factory UserListResponse.fromJson(Map<String, dynamic> json) {
    return UserListResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      pagination: json['pagination'] != null
          ? Pagination.fromJson(json['pagination'])
          : null,
      users: json['data']?['users'] != null && json['data']['users'] is List
          ? List<Usert>.from(json['data']['users'].map((x) => Usert.fromJson(x)))
          : [],
      state: json['data']?['state'] != null
          ? Statey.fromJson(json['data']['state'])
          : null,
      headOfficesCount: json['data']?['headOfficesCount'] ?? 0,
    );
  }
}

class Usert {
  String? id;
  String? employeeCode;
  String? name;
  String? email;
  String? role;
  String? department;
  String? headOffice;
  String? headOffices;
  String? state;
  String? branch;
  String? employmentType;
  String? mobileNumber;
  double? salaryAmount;
  bool? isActive;
  String? createdAt;

  Usert({
    this.id,
    this.employeeCode,
    this.name,
    this.email,
    this.role,
    this.department,
    this.headOffice,
    this.headOffices,
    this.state,
    this.branch,
    this.employmentType,
    this.mobileNumber,
    this.salaryAmount,
    this.isActive,
    this.createdAt,
  });

  factory Usert.fromJson(Map<String, dynamic> json) {
    return Usert(
      id: json['id'] ?? '',
      employeeCode: json['employeeCode'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      department: json['department'] ?? 'Not Assigned',
      headOffice: json['headOffice'] ?? 'Not Assigned',
      headOffices: json['headOffices'] ?? '',
      state: json['state'] ?? '',
      branch: json['branch'] ?? 'Not Assigned',
      employmentType: json['employmentType'] ?? 'Not Assigned',
      mobileNumber: json['mobileNumber'] ?? '',
      salaryAmount: json['salaryAmount']?.toDouble(),
      isActive: json['isActive'] ?? false,
      createdAt: json['createdAt'] ?? '',
    );
  }
}

class Pagination {
  int? currentPage;
  int? totalPages;
  int? totalCount;
  int? limit;
  bool? hasNext;
  bool? hasPrev;

  Pagination({
    this.currentPage,
    this.totalPages,
    this.totalCount,
    this.limit,
    this.hasNext,
    this.hasPrev,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      currentPage: json['currentPage'] ?? 1,
      totalPages: json['totalPages'] ?? 1,
      totalCount: json['totalCount'] ?? 0,
      limit: json['limit'] ?? 50,
      hasNext: json['hasNext'] ?? false,
      hasPrev: json['hasPrev'] ?? false,
    );
  }
}

class Statey {
  String? id;
  String? name;

  Statey({
    this.id,
    this.name,
  });

  factory Statey.fromJson(Map<String, dynamic> json) {
    return Statey(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
    );
  }
}
