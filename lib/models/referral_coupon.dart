/// A manually-issued referral reward for a client.
///
/// When a client refers a lead that turns into a successful engagement,
/// the freelancer can create a coupon (percentage or fixed amount) and
/// apply it to that client's invoices. Everything is manual by design.
class ReferralCoupon {
  final String id;
  final String clientId;
  final String code;

  /// 'percentage' or 'fixed'
  final String type;
  final double value;

  /// 'active', 'used' or 'expired'
  final String status;
  final String note;
  final DateTime createdAt;
  final DateTime? expiresAt;

  ReferralCoupon({
    required this.id,
    required this.clientId,
    required this.code,
    this.type = 'percentage',
    this.value = 0,
    this.status = 'active',
    this.note = '',
    DateTime? createdAt,
    this.expiresAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isActive => status == 'active';
  bool get isPercentage => type == 'percentage';

  /// Absolute discount amount this coupon applies to [subtotal].
  double discountFor(double subtotal) {
    if (type == 'percentage') return subtotal * value / 100;
    return value;
  }

  ReferralCoupon copyWith({
    String? clientId,
    String? code,
    String? type,
    double? value,
    String? status,
    String? note,
    DateTime? expiresAt,
  }) {
    return ReferralCoupon(
      id: id,
      clientId: clientId ?? this.clientId,
      code: code ?? this.code,
      type: type ?? this.type,
      value: value ?? this.value,
      status: status ?? this.status,
      note: note ?? this.note,
      createdAt: createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'clientId': clientId,
        'code': code,
        'type': type,
        'value': value,
        'status': status,
        'note': note,
        'createdAt': createdAt.toIso8601String(),
        'expiresAt': expiresAt?.toIso8601String(),
      };

  factory ReferralCoupon.fromJson(Map<dynamic, dynamic> json) => ReferralCoupon(
        id: json['id']?.toString() ?? '',
        clientId: json['clientId']?.toString() ?? '',
        code: json['code']?.toString() ?? '',
        type: json['type']?.toString() ?? 'percentage',
        value: (json['value'] as num?)?.toDouble() ?? 0,
        status: json['status']?.toString() ?? 'active',
        note: json['note']?.toString() ?? '',
        createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
            DateTime.now(),
        expiresAt: DateTime.tryParse(json['expiresAt']?.toString() ?? ''),
      );
}
