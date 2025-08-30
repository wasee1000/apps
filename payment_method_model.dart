class PaymentMethodModel {
  final String id;
  final String type; // 'card', 'upi', 'netbanking', etc.
  final String? brand; // 'visa', 'mastercard', 'amex', etc.
  final String? last4; // Last 4 digits of card
  final String? expiryMonth;
  final String? expiryYear;
  final String? cardHolderName;
  final bool isDefault;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  PaymentMethodModel({
    required this.id,
    required this.type,
    this.brand,
    this.last4,
    this.expiryMonth,
    this.expiryYear,
    this.cardHolderName,
    required this.isDefault,
    required this.createdAt,
    this.metadata,
  });

  // Factory constructor from JSON
  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      id: json['id'],
      type: json['type'],
      brand: json['brand'],
      last4: json['last4'],
      expiryMonth: json['expiry_month'],
      expiryYear: json['expiry_year'],
      cardHolderName: json['card_holder_name'],
      isDefault: json['is_default'],
      createdAt: DateTime.parse(json['created_at']),
      metadata: json['metadata'],
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'brand': brand,
      'last4': last4,
      'expiry_month': expiryMonth,
      'expiry_year': expiryYear,
      'card_holder_name': cardHolderName,
      'is_default': isDefault,
      'created_at': createdAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  // Get formatted card number
  String get maskedCardNumber {
    if (last4 == null) return '';
    return '•••• •••• •••• $last4';
  }

  // Get formatted expiry date
  String get expiryDate {
    if (expiryMonth == null || expiryYear == null) return '';
    return '$expiryMonth/$expiryYear';
  }

  // Get card brand icon name
  String get brandIconName {
    if (brand == null) return 'credit_card';
    
    switch (brand!.toLowerCase()) {
      case 'visa':
        return 'visa';
      case 'mastercard':
        return 'mastercard';
      case 'amex':
      case 'american express':
        return 'amex';
      case 'discover':
        return 'discover';
      case 'diners':
      case 'diners club':
        return 'diners';
      case 'jcb':
        return 'jcb';
      case 'unionpay':
        return 'unionpay';
      case 'rupay':
        return 'rupay';
      default:
        return 'credit_card';
    }
  }

  // Get payment method display name
  String get displayName {
    if (type == 'card') {
      if (brand != null && last4 != null) {
        return '$brand •••• $last4';
      } else if (last4 != null) {
        return 'Card •••• $last4';
      } else {
        return 'Card';
      }
    } else if (type == 'upi') {
      if (metadata != null && metadata!.containsKey('upi_id')) {
        return 'UPI: ${metadata!['upi_id']}';
      } else {
        return 'UPI';
      }
    } else if (type == 'netbanking') {
      if (metadata != null && metadata!.containsKey('bank_name')) {
        return 'Netbanking: ${metadata!['bank_name']}';
      } else {
        return 'Netbanking';
      }
    } else if (type == 'wallet') {
      if (metadata != null && metadata!.containsKey('wallet_name')) {
        return 'Wallet: ${metadata!['wallet_name']}';
      } else {
        return 'Wallet';
      }
    } else {
      return type.toUpperCase();
    }
  }

  // Check if card is expired
  bool get isExpired {
    if (expiryMonth == null || expiryYear == null) return false;
    
    final now = DateTime.now();
    final expiryDate = DateTime(
      int.parse('20${expiryYear!}'),
      int.parse(expiryMonth!),
      1,
    ).add(const Duration(days: 31)); // End of month
    
    return now.isAfter(expiryDate);
  }

  // Get card type icon
  String get cardTypeIcon {
    if (type != 'card') return 'credit_card';
    
    if (brand == null) return 'credit_card';
    
    switch (brand!.toLowerCase()) {
      case 'visa':
        return 'visa';
      case 'mastercard':
        return 'mastercard';
      case 'amex':
      case 'american express':
        return 'amex';
      case 'discover':
        return 'discover';
      case 'diners':
      case 'diners club':
        return 'diners';
      case 'jcb':
        return 'jcb';
      case 'unionpay':
        return 'unionpay';
      case 'rupay':
        return 'rupay';
      default:
        return 'credit_card';
    }
  }
}

