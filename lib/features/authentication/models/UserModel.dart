class UserModel {
  final String? token;
  final double? meterRange;
  final User? user;

  UserModel({
    this.token,
    this.meterRange,
    this.user,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      token: json['token'],
      meterRange: _readMeterRange(json['meter_range'] ?? json['meterRange']),
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'meter_range': meterRange,
      'user': user?.toJson(),
    };
  }

  static double? _readMeterRange(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }
}

class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final bool emailVerified;
  final String? phone;
  final double? meterRange;
  final List<HeadOffice> headOffices;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.emailVerified,
    this.phone,
    this.meterRange,
    required this.headOffices,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      emailVerified: json['emailVerified'] ?? false,
      phone: json['phone'],
      meterRange: _readMeterRange(
        json['meter_range'] ?? json['meterRange'],
      ),
      headOffices: (json['headOffices'] as List<dynamic>? ?? [])
          .map((e) => HeadOffice.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'emailVerified': emailVerified,
      'phone': phone,
      'meter_range': meterRange,
      'headOffices': headOffices.map((e) => e.toJson()).toList(),
    };
  }

  static double? _readMeterRange(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }
}

class HeadOffice {
  final String id;
  final String name;
  final double latitude;
  final double longitude;

  HeadOffice({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  factory HeadOffice.fromJson(Map<String, dynamic> json) {
    return HeadOffice(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
