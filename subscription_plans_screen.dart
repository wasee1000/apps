import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/error_dialog.dart';
import '../../../shared/widgets/custom_button.dart';
import '../models/subscription_plan_model.dart';
import '../providers/subscription_provider.dart';
import '../widgets/plan_feature_item.dart';
import '../widgets/plan_comparison_table.dart';

class SubscriptionPlansScreen extends ConsumerStatefulWidget {
  const SubscriptionPlansScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SubscriptionPlansScreen> createState() => _SubscriptionPlansScreenState();
}

class _SubscriptionPlansScreenState extends ConsumerState<SubscriptionPlansScreen> {
  int _selectedPlanIndex = 1; // Default to premium plan

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    ref.read(subscriptionPlansProvider.notifier).refreshPlans();
    ref.read(subscriptionProvider.notifier).refreshSubscription();
  }

  void _selectPlan(int index) {
    setState(() {
      _selectedPlanIndex = index;
    });
  }

  Future<void> _subscribeToPlan(SubscriptionPlanModel plan) async {
    // Check if user has payment methods
    final paymentMethodsState = ref.read(paymentMethodsProvider);
    
    if (paymentMethodsState.hasValue && 
        paymentMethodsState.value!.isNotEmpty) {
      // User has payment methods, proceed to payment
      context.push('/subscription/payment?plan_id=${plan.id}');
    } else {
      // User has no payment methods, add one first
      context.push('/subscription/payment-methods/add?plan_id=${plan.id}');
    }
  }

  Future<void> _startFreeTrial(SubscriptionPlanModel plan) async {
    try {
      await ref.read(subscriptionProvider.notifier).startFreeTrial(plan.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Your ${plan.trialPeriodDays}-day free trial has started!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Navigate to home screen
        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => ErrorDialog(
            title: 'Trial Error',
            message: 'Failed to start free trial: ${e.toString()}',
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    
    // Get subscription plans
    final plansState = ref.watch(subscriptionPlansProvider);
    final currentSubscription = ref.watch(subscriptionProvider);
    final currentPlan = ref.watch(subscriptionPlanProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription Plans'),
        centerTitle: true,
      ),
      body: plansState.when(
        data: (plans) {
          // Filter active plans
          final activePlans = plans.where((plan) => plan.isActive).toList();
          
          if (activePlans.isEmpty) {
            return Center(
              child: Text(
                'No subscription plans available',
                style: theme.textTheme.titleMedium,
              ),
            );
          }
          
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Current plan info
                if (currentSubscription.hasValue && 
                    currentSubscription.value != null)
                  _buildCurrentPlanInfo(currentSubscription.value!, currentPlan),
                
                // Plans selection
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Choose a Plan',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                
                // Plan cards
                SizedBox(
                  height: 180,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: activePlans.length,
                    itemBuilder: (context, index) {
                      final plan = activePlans[index];
                      final isSelected = index == _selectedPlanIndex;
                      
                      return _buildPlanCard(
                        plan: plan,
                        isSelected: isSelected,
                        onTap: () => _selectPlan(index),
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Selected plan details
                if (_selectedPlanIndex < activePlans.length)
                  _buildPlanDetails(activePlans[_selectedPlanIndex]),
                
                const SizedBox(height: 24),
                
                // Plan comparison
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Plan Comparison',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                PlanComparisonTable(plans: activePlans),
                
                const SizedBox(height: 32),
              ],
            ),
          );
        },
        loading: () => const LoadingIndicator(message: 'Loading subscription plans...'),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load subscription plans',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentPlanInfo(dynamic subscription, SubscriptionPlanModel? plan) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.verified,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Text(
                'Current Plan',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            plan?.name ?? 'Free Plan',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subscription.status == 'trialing'
                ? 'Trial ends on ${subscription.formattedTrialEndDate}'
                : subscription.status == 'active'
                    ? 'Renews on ${subscription.formattedCurrentPeriodEndDate}'
                    : subscription.status == 'canceled'
                        ? 'Expires on ${subscription.formattedCurrentPeriodEndDate}'
                        : '',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (subscription.status == 'active' || 
                  subscription.status == 'trialing')
                OutlinedButton(
                  onPressed: () {
                    context.push('/subscription/manage');
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                  ),
                  child: const Text('Manage'),
                ),
              if (subscription.status == 'canceled')
                ElevatedButton(
                  onPressed: () {
                    context.push('/subscription/payment?plan_id=${plan?.id}');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: theme.colorScheme.primary,
                  ),
                  child: const Text('Renew'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard({
    required SubscriptionPlanModel plan,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withOpacity(0.5),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Popular badge
            if (plan.isPopular)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white
                      : theme.colorScheme.primary,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Text(
                  'MOST POPULAR',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            
            // Plan content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Plan name
                  Text(
                    plan.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  
                  // Plan price
                  Text(
                    plan.formattedPriceWithInterval,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  
                  // Trial period
                  if (plan.trialPeriodDays > 0)
                    Text(
                      plan.trialPeriodText,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isSelected
                            ? Colors.white.withOpacity(0.9)
                            : theme.colorScheme.primary,
                      ),
                    ),
                  
                  const Spacer(),
                  
                  // Selected indicator
                  if (isSelected)
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Selected',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanDetails(SubscriptionPlanModel plan) {
    final theme = Theme.of(context);
    final currentSubscription = ref.watch(subscriptionProvider);
    final isSubscribed = ref.watch(isSubscribedProvider);
    final isInTrialPeriod = ref.watch(isInTrialPeriodProvider);
    
    // Check if user is already subscribed to this plan
    bool isCurrentPlan = false;
    if (currentSubscription.hasValue && 
        currentSubscription.value != null) {
      isCurrentPlan = currentSubscription.value!.planId == plan.id;
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Plan name and price
          Text(
            plan.name,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          
          // Plan price
          Text(
            plan.formattedPriceWithInterval,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          
          // Plan description
          Text(
            plan.description,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          
          // Plan features
          ...plan.features.map((feature) => PlanFeatureItem(feature: feature)),
          const SizedBox(height: 24),
          
          // Action button
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              onPressed: isCurrentPlan
                  ? null
                  : () {
                      if (plan.price == 0) {
                        // Free plan, just navigate to home
                        context.go('/');
                      } else if (plan.trialPeriodDays > 0 && !isInTrialPeriod) {
                        // Has trial and user hasn't used trial yet
                        _startFreeTrial(plan);
                      } else {
                        // Subscribe directly
                        _subscribeToPlan(plan);
                      }
                    },
              text: isCurrentPlan
                  ? 'Current Plan'
                  : plan.price == 0
                      ? 'Continue with Free Plan'
                      : plan.trialPeriodDays > 0 && !isInTrialPeriod
                          ? 'Start ${plan.trialPeriodText}'
                          : 'Subscribe Now',
              isDisabled: isCurrentPlan,
            ),
          ),
          
          // Trial info
          if (plan.trialPeriodDays > 0 && !isInTrialPeriod)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'You will be charged after the trial period ends. You can cancel anytime.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

