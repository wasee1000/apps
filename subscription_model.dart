class SubscriptionModel {
  final String plan;
  final bool isTrialActive;
  final bool isPremiumActive;
  final int trialDaysRemaining;
  final int subscriptionDaysRemaining;

  SubscriptionModel({
    required this.plan,
    required this.isTrialActive,
    required this.isPremiumActive,
    required this.trialDaysRemaining,
    required this.subscriptionDaysRemaining,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      plan: json['plan'] ?? 'free',
      isTrialActive: json['is_trial_active'] ?? false,
      isPremiumActive: json['is_premium_active'] ?? false,
      trialDaysRemaining: json['trial_days_remaining'] ?? 0,
      subscriptionDaysRemaining: json['subscription_days_remaining'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plan': plan,
      'is_trial_active': isTrialActive,
      'is_premium_active': isPremiumActive,
      'trial_days_remaining': trialDaysRemaining,
      'subscription_days_remaining': subscriptionDaysRemaining,
    };
  }

  SubscriptionModel copyWith({
    String? plan,
    bool? isTrialActive,
    bool? isPremiumActive,
    int? trialDaysRemaining,
    int? subscriptionDaysRemaining,
  }) {
    return SubscriptionModel(
      plan: plan ?? this.plan,
      isTrialActive: isTrialActive ?? this.isTrialActive,
      isPremiumActive: isPremiumActive ?? this.isPremiumActive,
      trialDaysRemaining: trialDaysRemaining ?? this.trialDaysRemaining,
      subscriptionDaysRemaining:
          subscriptionDaysRemaining ?? this.subscriptionDaysRemaining,
    );
  }

  bool get hasActiveSubscription => isPremiumActive;

  bool get canActivateTrial => plan == 'free' && !isTrialActive && trialDaysRemaining == 0;

  String get statusText {
    if (plan == 'premium' && isPremiumActive) {
      return 'Premium (${subscriptionDaysRemaining} days left)';
    } else if (plan == 'trial' && isTrialActive) {
      return 'Trial (${trialDaysRemaining} days left)';
    } else {
      return 'Free';
    }
  }
}

