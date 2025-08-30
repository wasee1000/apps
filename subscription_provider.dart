import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/subscription_model.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/utils/exceptions.dart';
import '../models/payment_method_model.dart';
import '../models/subscription_plan_model.dart';
import '../../auth/providers/auth_provider.dart';

// Subscription Provider
class SubscriptionNotifier extends StateNotifier<AsyncValue<SubscriptionModel?>> {
  final SupabaseService _supabaseService;

  SubscriptionNotifier(this._supabaseService) : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    try {
      final subscription = await _supabaseService.getCurrentSubscription();
      state = AsyncValue.data(subscription);
    } catch (e) {
      state = const AsyncValue.data(null);
    }
  }

  Future<void> refreshSubscription() async {
    try {
      state = const AsyncValue.loading();
      final subscription = await _supabaseService.getCurrentSubscription();
      state = AsyncValue.data(subscription);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      throw SubscriptionException('Failed to refresh subscription: ${e.toString()}');
    }
  }

  Future<void> subscribeToPlan(String planId, String paymentMethodId) async {
    try {
      state = const AsyncValue.loading();
      final subscription = await _supabaseService.subscribeToPlan(planId, paymentMethodId);
      state = AsyncValue.data(subscription);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      throw SubscriptionException('Failed to subscribe to plan: ${e.toString()}');
    }
  }

  Future<void> startFreeTrial(String planId) async {
    try {
      state = const AsyncValue.loading();
      final subscription = await _supabaseService.startFreeTrial(planId);
      state = AsyncValue.data(subscription);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      throw SubscriptionException('Failed to start free trial: ${e.toString()}');
    }
  }

  Future<void> cancelSubscription() async {
    try {
      state = const AsyncValue.loading();
      final subscription = await _supabaseService.cancelSubscription();
      state = AsyncValue.data(subscription);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      throw SubscriptionException('Failed to cancel subscription: ${e.toString()}');
    }
  }

  Future<void> updatePaymentMethod(String paymentMethodId) async {
    try {
      state = const AsyncValue.loading();
      final subscription = await _supabaseService.updatePaymentMethod(paymentMethodId);
      state = AsyncValue.data(subscription);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      throw SubscriptionException('Failed to update payment method: ${e.toString()}');
    }
  }
}

final subscriptionProvider = StateNotifierProvider<SubscriptionNotifier, AsyncValue<SubscriptionModel?>>((ref) {
  final supabaseService = SupabaseService();
  return SubscriptionNotifier(supabaseService);
});

// Subscription Plans Provider
class SubscriptionPlansNotifier extends StateNotifier<AsyncValue<List<SubscriptionPlanModel>>> {
  final SupabaseService _supabaseService;

  SubscriptionPlansNotifier(this._supabaseService) : super(const AsyncValue.loading()) {
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    try {
      final plans = await _supabaseService.getSubscriptionPlans();
      state = AsyncValue.data(plans);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> refreshPlans() async {
    try {
      state = const AsyncValue.loading();
      final plans = await _supabaseService.getSubscriptionPlans();
      state = AsyncValue.data(plans);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      throw SubscriptionException('Failed to refresh plans: ${e.toString()}');
    }
  }
}

final subscriptionPlansProvider = StateNotifierProvider<SubscriptionPlansNotifier, AsyncValue<List<SubscriptionPlanModel>>>((ref) {
  final supabaseService = SupabaseService();
  return SubscriptionPlansNotifier(supabaseService);
});

// Payment Methods Provider
class PaymentMethodsNotifier extends StateNotifier<AsyncValue<List<PaymentMethodModel>>> {
  final SupabaseService _supabaseService;

  PaymentMethodsNotifier(this._supabaseService) : super(const AsyncValue.loading()) {
    _loadPaymentMethods();
  }

  Future<void> _loadPaymentMethods() async {
    try {
      final paymentMethods = await _supabaseService.getPaymentMethods();
      state = AsyncValue.data(paymentMethods);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> refreshPaymentMethods() async {
    try {
      state = const AsyncValue.loading();
      final paymentMethods = await _supabaseService.getPaymentMethods();
      state = AsyncValue.data(paymentMethods);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      throw PaymentException('Failed to refresh payment methods: ${e.toString()}');
    }
  }

  Future<void> addPaymentMethod({
    required String cardNumber,
    required String expiryMonth,
    required String expiryYear,
    required String cvc,
    required String cardHolderName,
  }) async {
    try {
      await _supabaseService.addPaymentMethod(
        cardNumber: cardNumber,
        expiryMonth: expiryMonth,
        expiryYear: expiryYear,
        cvc: cvc,
        cardHolderName: cardHolderName,
      );
      
      // Refresh payment methods
      await refreshPaymentMethods();
    } catch (e) {
      throw PaymentException('Failed to add payment method: ${e.toString()}');
    }
  }

  Future<void> deletePaymentMethod(String paymentMethodId) async {
    try {
      await _supabaseService.deletePaymentMethod(paymentMethodId);
      
      // Refresh payment methods
      await refreshPaymentMethods();
    } catch (e) {
      throw PaymentException('Failed to delete payment method: ${e.toString()}');
    }
  }

  Future<void> setDefaultPaymentMethod(String paymentMethodId) async {
    try {
      await _supabaseService.setDefaultPaymentMethod(paymentMethodId);
      
      // Refresh payment methods
      await refreshPaymentMethods();
    } catch (e) {
      throw PaymentException('Failed to set default payment method: ${e.toString()}');
    }
  }
}

final paymentMethodsProvider = StateNotifierProvider<PaymentMethodsNotifier, AsyncValue<List<PaymentMethodModel>>>((ref) {
  final supabaseService = SupabaseService();
  return PaymentMethodsNotifier(supabaseService);
});

// Subscription Status Providers
final isSubscribedProvider = Provider<bool>((ref) {
  final subscriptionState = ref.watch(subscriptionProvider);
  
  if (subscriptionState.hasValue && subscriptionState.value != null) {
    final subscription = subscriptionState.value!;
    return subscription.status == 'active' || subscription.status == 'trialing';
  }
  
  return false;
});

final isInTrialPeriodProvider = Provider<bool>((ref) {
  final subscriptionState = ref.watch(subscriptionProvider);
  
  if (subscriptionState.hasValue && subscriptionState.value != null) {
    final subscription = subscriptionState.value!;
    return subscription.status == 'trialing';
  }
  
  return false;
});

final canAccessPremiumContentProvider = Provider<bool>((ref) {
  final isAuthenticated = ref.watch(isAuthenticatedProvider);
  final isSubscribed = ref.watch(isSubscribedProvider);
  final isInTrialPeriod = ref.watch(isInTrialPeriodProvider);
  
  return isAuthenticated && (isSubscribed || isInTrialPeriod);
});

final subscriptionPlanProvider = Provider<SubscriptionPlanModel?>((ref) {
  final subscriptionState = ref.watch(subscriptionProvider);
  final plansState = ref.watch(subscriptionPlansProvider);
  
  if (subscriptionState.hasValue && 
      subscriptionState.value != null && 
      plansState.hasValue) {
    final subscription = subscriptionState.value!;
    final plans = plansState.value;
    
    return plans.firstWhere(
      (plan) => plan.id == subscription.planId,
      orElse: () => SubscriptionPlanModel.free(),
    );
  }
  
  return SubscriptionPlanModel.free();
});

