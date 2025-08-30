class UserModel {
  final String id;
  final String? email;
  final String? fullName;
  final String? avatarUrl;
  final String? phoneNumber;
  final DateTime? dateOfBirth;
  final String preferredLanguage;
  final String subscriptionPlan;
  final DateTime? trialStartDate;
  final DateTime? trialEndDate;
  final DateTime? subscriptionStartDate;
  final DateTime? subscriptionEndDate;
  final bool isAdmin;
  final Map<String, dynamic>? notificationPreferences;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    this.email,
    this.fullName,
    this.avatarUrl,
    this.phoneNumber,
    this.dateOfBirth,
    this.preferredLanguage = 'english',
    this.subscriptionPlan = 'free',
    this.trialStartDate,
    this.trialEndDate,
    this.subscriptionStartDate,
    this.subscriptionEndDate,
    this.isAdmin = false,
    this.notificationPreferences,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      fullName: json['full_name'],
      avatarUrl: json['avatar_url'],
      phoneNumber: json['phone_number'],
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'])
          : null,
      preferredLanguage: json['preferred_language'] ?? 'english',
      subscriptionPlan: json['subscription_plan'] ?? 'free',
      trialStartDate: json['trial_start_date'] != null
          ? DateTime.parse(json['trial_start_date'])
          : null,
      trialEndDate: json['trial_end_date'] != null
          ? DateTime.parse(json['trial_end_date'])
          : null,
      subscriptionStartDate: json['subscription_start_date'] != null
          ? DateTime.parse(json['subscription_start_date'])
          : null,
      subscriptionEndDate: json['subscription_end_date'] != null
          ? DateTime.parse(json['subscription_end_date'])
          : null,
      isAdmin: json['is_admin'] ?? false,
      notificationPreferences: json['notification_preferences'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'phone_number': phoneNumber,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'preferred_language': preferredLanguage,
      'subscription_plan': subscriptionPlan,
      'trial_start_date': trialStartDate?.toIso8601String(),
      'trial_end_date': trialEndDate?.toIso8601String(),
      'subscription_start_date': subscriptionStartDate?.toIso8601String(),
      'subscription_end_date': subscriptionEndDate?.toIso8601String(),
      'is_admin': isAdmin,
      'notification_preferences': notificationPreferences,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? avatarUrl,
    String? phoneNumber,
    DateTime? dateOfBirth,
    String? preferredLanguage,
    String? subscriptionPlan,
    DateTime? trialStartDate,
    DateTime? trialEndDate,
    DateTime? subscriptionStartDate,
    DateTime? subscriptionEndDate,
    bool? isAdmin,
    Map<String, dynamic>? notificationPreferences,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      subscriptionPlan: subscriptionPlan ?? this.subscriptionPlan,
      trialStartDate: trialStartDate ?? this.trialStartDate,
      trialEndDate: trialEndDate ?? this.trialEndDate,
      subscriptionStartDate: subscriptionStartDate ?? this.subscriptionStartDate,
      subscriptionEndDate: subscriptionEndDate ?? this.subscriptionEndDate,
      isAdmin: isAdmin ?? this.isAdmin,
      notificationPreferences:
          notificationPreferences ?? this.notificationPreferences,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isPremium => subscriptionPlan == 'premium' && 
      (subscriptionEndDate == null || subscriptionEndDate!.isAfter(DateTime.now()));

  bool get isInTrialPeriod => subscriptionPlan == 'trial' && 
      trialEndDate != null && trialEndDate!.isAfter(DateTime.now());

  bool get hasActiveSubscription => isPremium || isInTrialPeriod;

  int get trialDaysRemaining {
    if (trialEndDate == null || !isInTrialPeriod) return 0;
    return trialEndDate!.difference(DateTime.now()).inDays + 1;
  }

  int get subscriptionDaysRemaining {
    if (subscriptionEndDate == null || !isPremium) return 0;
    return subscriptionEndDate!.difference(DateTime.now()).inDays + 1;
  }

  bool get canActivateTrial => 
      subscriptionPlan == 'free' && trialStartDate == null;
}

