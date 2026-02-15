class UserModel {
  final String id;
  final String pseudo;
  final String phoneNumber;
  final String? email;
  final String userType; // 'user' or 'admin'

  UserModel({
    required this.id,
    required this.pseudo,
    required this.phoneNumber,
    this.email,
    this.userType = 'user',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final String rawPseudo =
        json['user_pseudo']?.toString() ?? json['pseudo']?.toString() ?? '';
    final String rawPhone =
        json['user_phone']?.toString() ??
        json['phone']?.toString() ??
        json['phone_number']?.toString() ??
        '';

    // Safety check: if pseudo is a UUID or empty, use fallback
    final bool isUuid = rawPseudo.length == 36 && rawPseudo.contains('-');

    return UserModel(
      id:
          json['user_id']?.toString() ??
          json['id']?.toString() ??
          json['id_user']?.toString() ??
          '',
      pseudo: (isUuid || rawPseudo.isEmpty) ? 'User' : rawPseudo,
      phoneNumber: rawPhone,
      email: json['user_email']?.toString() ?? json['email']?.toString(),
      userType: json['user_type']?.toString() ?? 'user',
    );
  }

  UserModel copyWith({
    String? id,
    String? pseudo,
    String? phoneNumber,
    String? email,
    String? userType,
  }) {
    return UserModel(
      id: id ?? this.id,
      pseudo: pseudo ?? this.pseudo,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      userType: userType ?? this.userType,
    );
  }

  bool get isAdmin => userType == 'admin';
}

class MeterModel {
  final String id;
  final String serialNumber;
  final double currentBalance;
  final bool isActive;
  final String? valveState;
  final int? batteryLevel;
  final int? rssi;
  final String? location;

  MeterModel({
    required this.id,
    required this.serialNumber,
    required this.currentBalance,
    required this.isActive,
    this.valveState,
    this.batteryLevel,
    this.rssi,
    this.location,
  });

  factory MeterModel.fromJson(Map<String, dynamic> json) {
    return MeterModel(
      id: json['meter_id'] ?? json['id_meter'] ?? '',
      serialNumber: json['serial_id'] ?? json['serial_number'] ?? '',
      currentBalance: (json['current_balance'] ?? 0).toDouble(),
      isActive: json['meter_state'] == 'ACTIVE' || (json['is_active'] ?? false),
      valveState: json['valve_state'],
      batteryLevel: json['battery_level'],
      rssi: json['rssi'],
      location: json['location'],
    );
  }
}

class RefillModel {
  final String id;
  final double price;
  final double volume;
  final String paymentMethod;
  final DateTime createdAt;

  RefillModel({
    required this.id,
    required this.price,
    required this.volume,
    required this.paymentMethod,
    required this.createdAt,
  });

  factory RefillModel.fromJson(Map<String, dynamic> json) {
    return RefillModel(
      id: json['refill_id'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      volume: (json['volume'] ?? 0).toDouble(),
      paymentMethod: json['refill_method'] ?? json['payment_method'] ?? 'CASH',
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}

class DashboardDataModel {
  final double currentBalance;
  final double totalSpent;
  final int activeMeters;
  final List<MeterModel> meters;
  final List<RefillModel> recentRefills;
  final UserModel? userInfo;

  DashboardDataModel({
    required this.currentBalance,
    required this.totalSpent,
    required this.activeMeters,
    required this.meters,
    required this.recentRefills,
    this.userInfo,
  });

  factory DashboardDataModel.fromJson(Map<String, dynamic> json) {
    return DashboardDataModel(
      currentBalance: (json['current_balance'] ?? 0).toDouble(),
      totalSpent: (json['total_spent'] ?? 0).toDouble(),
      activeMeters: json['active_meters'] ?? 0,
      userInfo: json['user_info'] != null
          ? UserModel.fromJson(json['user_info'])
          : null,
      meters: (json['meters'] as List? ?? [])
          .map((m) => MeterModel.fromJson(m))
          .toList(),
      recentRefills: (json['recent_refills'] as List? ?? [])
          .map((r) => RefillModel.fromJson(r))
          .toList(),
    );
  }
}

// ============================================================
// Admin-specific models
// ============================================================

/// Meter model as seen by the admin (with more fields)
class AdminMeterModel {
  final String meterId;
  final String? userId;
  final String? adminId;
  final String? token;
  final bool attributed;
  final String serialId;
  final String meterState;
  final DateTime registeredAt;
  final String? deviceId;

  AdminMeterModel({
    required this.meterId,
    this.userId,
    this.adminId,
    this.token,
    required this.attributed,
    required this.serialId,
    required this.meterState,
    required this.registeredAt,
    this.deviceId,
  });

  factory AdminMeterModel.fromJson(Map<String, dynamic> json) {
    return AdminMeterModel(
      meterId: json['meter_id']?.toString() ?? '',
      userId: json['user_id']?.toString(),
      adminId: json['admin_id']?.toString(),
      token: json['token']?.toString(),
      attributed: json['attributed'] ?? false,
      serialId: json['serial_id']?.toString() ?? '',
      meterState: json['meter_state']?.toString() ?? 'INACTIVE',
      registeredAt:
          DateTime.tryParse(json['registered_at']?.toString() ?? '') ??
          DateTime.now(),
      deviceId: json['device_id']?.toString(),
    );
  }

  bool get isActive => meterState == 'ACTIVE';
  bool get isLinked => attributed && userId != null;
}

/// User model as seen by the admin
class AdminUserModel {
  final String userId;
  final String phone;
  final String pseudo;
  final String? email;
  final DateTime createdAt;
  final DateTime updatedAt;

  AdminUserModel({
    required this.userId,
    required this.phone,
    required this.pseudo,
    this.email,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AdminUserModel.fromJson(Map<String, dynamic> json) {
    return AdminUserModel(
      userId: json['user_id']?.toString() ?? '',
      phone: json['user_phone']?.toString() ?? '',
      pseudo: json['user_pseudo']?.toString() ?? '',
      email: json['user_email']?.toString(),
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updated_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}

/// Transaction history model for admin
class TransactionModel {
  final String refillId;
  final String? userId;
  final String meterId;
  final String? refillPhone;
  final String refillMethod;
  final String refillState;
  final double price;
  final double volume;
  final DateTime createdAt;
  final DateTime updatedAt;

  TransactionModel({
    required this.refillId,
    this.userId,
    required this.meterId,
    this.refillPhone,
    required this.refillMethod,
    required this.refillState,
    required this.price,
    required this.volume,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      refillId: json['refill_id']?.toString() ?? '',
      userId: json['user_id']?.toString(),
      meterId: json['meter_id']?.toString() ?? '',
      refillPhone: json['refill_phone']?.toString(),
      refillMethod: json['refill_method']?.toString() ?? 'CASH',
      refillState: json['refill_state']?.toString() ?? 'PENDING',
      price: (json['price'] ?? 0).toDouble(),
      volume: (json['volume'] ?? 0).toDouble(),
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updated_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}

/// Report model for admin
class ReportModel {
  final String reportId;
  final String adminId;
  final DateTime startedAt;
  final DateTime endedAt;
  final String format;
  final DateTime createdAt;

  ReportModel({
    required this.reportId,
    required this.adminId,
    required this.startedAt,
    required this.endedAt,
    required this.format,
    required this.createdAt,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      reportId: json['report_id']?.toString() ?? '',
      adminId: json['admin_id']?.toString() ?? '',
      startedAt:
          DateTime.tryParse(json['started_at']?.toString() ?? '') ??
          DateTime.now(),
      endedAt:
          DateTime.tryParse(json['ended_at']?.toString() ?? '') ??
          DateTime.now(),
      format: json['format']?.toString() ?? 'CSV',
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}
