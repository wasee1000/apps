import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/error_dialog.dart';
import '../../../shared/widgets/custom_button.dart';
import '../models/subscription_plan_model.dart';
import '../models/payment_method_model.dart';
import '../providers/subscription_provider.dart';
import '../widgets/payment_method_item.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  final String planId;

  const PaymentScreen({
    Key? key,
    required this.planId,
  }) : super(key: key);

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  String? _selectedPaymentMethodId;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Load payment methods
    ref.read(paymentMethodsProvider.notifier).refreshPaymentMethods();
    
    // Set default payment method if available
    final paymentMethodsState = ref.read(paymentMethodsProvider);
    if (paymentMethodsState.hasValue && 
        paymentMethodsState.value!.isNotEmpty) {
      final defaultMethod = paymentMethodsState.value!
          .firstWhere(
            (method) => method.isDefault,
            orElse: () => paymentMethodsState.value!.first,
          );
      
      setState(() {
        _selectedPaymentMethodId = defaultMethod.id;
      });
    }
  }

  void _selectPaymentMethod(String id) {
    setState(() {
      _selectedPaymentMethodId = id;
    });
  }

  Future<void> _processPayment() async {
    if (_selectedPaymentMethodId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a payment method'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    setState(() {
      _isProcessing = true;
    });
    
    try {
      await ref.read(subscriptionProvider.notifier).subscribeToPlan(
        widget.planId,
        _selectedPaymentMethodId!,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Subscription successful!'),
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
            title: 'Payment Error',
            message: 'Failed to process payment: ${e.toString()}',
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Get subscription plan
    final plansState = ref.watch(subscriptionPlansProvider);
    final paymentMethodsState = ref.watch(paymentMethodsProvider);
    
    // Find the selected plan
    SubscriptionPlanModel? selectedPlan;
    if (plansState.hasValue) {
      selectedPlan = plansState.value.firstWhere(
        (plan) => plan.id == widget.planId,
        orElse: () => SubscriptionPlanModel.premium(),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        centerTitle: true,
      ),
      body: _isProcessing
          ? const LoadingIndicator(message: 'Processing payment...')
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order summary
                    _buildOrderSummary(selectedPlan),
                    const SizedBox(height: 24),
                    
                    // Payment methods
                    Text(
                      'Payment Method',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Payment methods list
                    paymentMethodsState.when(
                      data: (paymentMethods) {
                        if (paymentMethods.isEmpty) {
                          return _buildNoPaymentMethods();
                        }
                        
                        return Column(
                          children: [
                            ...paymentMethods.map((method) => PaymentMethodItem(
                              paymentMethod: method,
                              isSelected: _selectedPaymentMethodId == method.id,
                              onTap: () => _selectPaymentMethod(method.id),
                            )),
                            
                            // Add new payment method button
                            ListTile(
                              leading: CircleAvatar(
                                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                                child: Icon(
                                  Icons.add,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              title: Text(
                                'Add New Payment Method',
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onTap: () {
                                context.push('/subscription/payment-methods/add?plan_id=${widget.planId}');
                              },
                            ),
                          ],
                        );
                      },
                      loading: () => const Center(
                        child: CircularProgressIndicator(),
                      ),
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
                              'Failed to load payment methods',
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
                    
                    const SizedBox(height: 32),
                    
                    // Payment button
                    SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        onPressed: _selectedPaymentMethodId != null
                            ? _processPayment
                            : null,
                        text: 'Pay Now',
                        isDisabled: _selectedPaymentMethodId == null,
                      ),
                    ),
                    
                    // Terms and conditions
                    const SizedBox(height: 16),
                    Text(
                      'By proceeding, you agree to our Terms of Service and Privacy Policy. '
                      'Your subscription will automatically renew unless canceled at least 24 hours before the end of the current period.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildOrderSummary(SubscriptionPlanModel? plan) {
    final theme = Theme.of(context);
    
    if (plan == null) {
      return const SizedBox.shrink();
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Plan details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${plan.name} Plan',
                style: theme.textTheme.titleMedium,
              ),
              Text(
                plan.formattedPrice,
                style: theme.textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Billing cycle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Billing Cycle',
                style: theme.textTheme.bodyMedium,
              ),
              Text(
                _getBillingCycleText(plan),
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
          
          // Trial period
          if (plan.trialPeriodDays > 0) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Free Trial',
                  style: theme.textTheme.bodyMedium,
                ),
                Text(
                  plan.trialPeriodText,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
          
          const Divider(height: 32),
          
          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                plan.trialPeriodDays > 0
                    ? 'Free for ${plan.trialPeriodDays} days'
                    : plan.formattedPrice,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: plan.trialPeriodDays > 0
                      ? theme.colorScheme.primary
                      : null,
                ),
              ),
            ],
          ),
          
          // First charge date
          if (plan.trialPeriodDays > 0) ...[
            const SizedBox(height: 8),
            Text(
              'First charge on ${_getFirstChargeDate(plan.trialPeriodDays)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNoPaymentMethods() {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        const SizedBox(height: 16),
        Icon(
          Icons.credit_card,
          size: 64,
          color: theme.colorScheme.primary.withOpacity(0.5),
        ),
        const SizedBox(height: 16),
        Text(
          'No Payment Methods',
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Add a payment method to continue',
          style: theme.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: CustomButton(
            onPressed: () {
              context.push('/subscription/payment-methods/add?plan_id=${widget.planId}');
            },
            text: 'Add Payment Method',
          ),
        ),
      ],
    );
  }

  String _getBillingCycleText(SubscriptionPlanModel plan) {
    switch (plan.interval) {
      case 'day':
        return plan.intervalCount == 1
            ? 'Daily'
            : 'Every ${plan.intervalCount} days';
      case 'week':
        return plan.intervalCount == 1
            ? 'Weekly'
            : 'Every ${plan.intervalCount} weeks';
      case 'month':
        return plan.intervalCount == 1
            ? 'Monthly'
            : 'Every ${plan.intervalCount} months';
      case 'year':
        return plan.intervalCount == 1
            ? 'Yearly'
            : 'Every ${plan.intervalCount} years';
      default:
        return '${plan.intervalCount} ${plan.interval}';
    }
  }

  String _getFirstChargeDate(int trialDays) {
    final now = DateTime.now();
    final firstChargeDate = now.add(Duration(days: trialDays));
    
    return '${firstChargeDate.day}/${firstChargeDate.month}/${firstChargeDate.year}';
  }
}

