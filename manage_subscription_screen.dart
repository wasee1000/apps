import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/error_dialog.dart';
import '../../../shared/widgets/custom_button.dart';
import '../models/subscription_plan_model.dart';
import '../providers/subscription_provider.dart';
import '../widgets/payment_method_item.dart';

class ManageSubscriptionScreen extends ConsumerStatefulWidget {
  const ManageSubscriptionScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ManageSubscriptionScreen> createState() => _ManageSubscriptionScreenState();
}

class _ManageSubscriptionScreenState extends ConsumerState<ManageSubscriptionScreen> {
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    ref.read(subscriptionProvider.notifier).refreshSubscription();
    ref.read(paymentMethodsProvider.notifier).refreshPaymentMethods();
  }

  Future<void> _cancelSubscription() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Subscription'),
        content: const Text(
          'Are you sure you want to cancel your subscription? '
          'You will still have access until the end of your current billing period.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
    
    if (confirmed != true) return;
    
    setState(() {
      _isProcessing = true;
    });
    
    try {
      await ref.read(subscriptionProvider.notifier).cancelSubscription();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Subscription canceled successfully'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Refresh data
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => ErrorDialog(
            title: 'Error',
            message: 'Failed to cancel subscription: ${e.toString()}',
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

  Future<void> _updatePaymentMethod(String paymentMethodId) async {
    setState(() {
      _isProcessing = true;
    });
    
    try {
      await ref.read(subscriptionProvider.notifier).updatePaymentMethod(paymentMethodId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment method updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Refresh data
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => ErrorDialog(
            title: 'Error',
            message: 'Failed to update payment method: ${e.toString()}',
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
    
    // Get subscription data
    final subscriptionState = ref.watch(subscriptionProvider);
    final currentPlan = ref.watch(subscriptionPlanProvider);
    final paymentMethodsState = ref.watch(paymentMethodsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Subscription'),
        centerTitle: true,
      ),
      body: _isProcessing
          ? const LoadingIndicator(message: 'Processing...')
          : subscriptionState.when(
              data: (subscription) {
                if (subscription == null) {
                  return _buildNoSubscription();
                }
                
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Subscription details
                        _buildSubscriptionDetails(subscription, currentPlan),
                        const SizedBox(height: 24),
                        
                        // Payment method
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
                            
                            // Find current payment method
                            final currentPaymentMethod = paymentMethods.firstWhere(
                              (method) => method.id == subscription.paymentMethodId,
                              orElse: () => paymentMethods.first,
                            );
                            
                            return Column(
                              children: [
                                // Current payment method
                                PaymentMethodItem(
                                  paymentMethod: currentPaymentMethod,
                                  isSelected: true,
                                  onTap: () {},
                                ),
                                
                                // Change payment method button
                                const SizedBox(height: 16),
                                OutlinedButton.icon(
                                  onPressed: () {
                                    _showChangePaymentMethodDialog(paymentMethods);
                                  },
                                  icon: const Icon(Icons.edit),
                                  label: const Text('Change Payment Method'),
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
                        
                        // Billing history
                        Text(
                          'Billing History',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Billing history list
                        _buildBillingHistory(subscription),
                        
                        const SizedBox(height: 32),
                        
                        // Cancel subscription button
                        if (subscription.status == 'active' || 
                            subscription.status == 'trialing')
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: _cancelSubscription,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.red),
                              ),
                              child: const Text('Cancel Subscription'),
                            ),
                          ),
                        
                        // Renew subscription button
                        if (subscription.status == 'canceled')
                          SizedBox(
                            width: double.infinity,
                            child: CustomButton(
                              onPressed: () {
                                context.push('/subscription/plans');
                              },
                              text: 'Renew Subscription',
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
              loading: () => const LoadingIndicator(message: 'Loading subscription details...'),
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
                      'Failed to load subscription details',
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

  Widget _buildNoSubscription() {
    final theme = Theme.of(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.subscriptions_outlined,
            size: 64,
            color: theme.colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Active Subscription',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Subscribe to a plan to access premium content',
            style: theme.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: 200,
            child: CustomButton(
              onPressed: () {
                context.push('/subscription/plans');
              },
              text: 'View Plans',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionDetails(dynamic subscription, SubscriptionPlanModel? plan) {
    final theme = Theme.of(context);
    
    return Container(
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
          // Plan name
          Text(
            plan?.name ?? 'Premium Plan',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          
          // Status
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _getStatusColor(subscription.status),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _getStatusText(subscription.status),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Subscription details
          _buildSubscriptionInfoRow(
            'Price',
            plan?.formattedPriceWithInterval ?? '₹199/month',
            theme,
          ),
          const SizedBox(height: 8),
          
          if (subscription.status == 'trialing')
            _buildSubscriptionInfoRow(
              'Trial Ends',
              subscription.formattedTrialEndDate,
              theme,
            )
          else if (subscription.status == 'active')
            _buildSubscriptionInfoRow(
              'Next Billing',
              subscription.formattedCurrentPeriodEndDate,
              theme,
            )
          else if (subscription.status == 'canceled')
            _buildSubscriptionInfoRow(
              'Access Until',
              subscription.formattedCurrentPeriodEndDate,
              theme,
            ),
          
          const SizedBox(height: 8),
          _buildSubscriptionInfoRow(
            'Started On',
            subscription.formattedCreatedDate,
            theme,
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionInfoRow(String label, String value, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildNoPaymentMethods() {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        const SizedBox(height: 16),
        Icon(
          Icons.credit_card,
          size: 48,
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
              context.push('/subscription/payment-methods/add');
            },
            text: 'Add Payment Method',
          ),
        ),
      ],
    );
  }

  Widget _buildBillingHistory(dynamic subscription) {
    final theme = Theme.of(context);
    
    // Mock billing history
    final billingHistory = [
      {
        'date': subscription.formattedCreatedDate,
        'amount': subscription.formattedAmount,
        'status': 'Paid',
      },
    ];
    
    if (billingHistory.isEmpty) {
      return Center(
        child: Text(
          'No billing history available',
          style: theme.textTheme.bodyMedium,
        ),
      );
    }
    
    return Column(
      children: [
        for (final item in billingHistory)
          Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(item['date']),
              subtitle: Text(item['status']),
              trailing: Text(
                item['amount'],
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        
        // View all button
        if (billingHistory.length > 3)
          TextButton(
            onPressed: () {
              // Navigate to billing history screen
            },
            child: const Text('View All'),
          ),
      ],
    );
  }

  void _showChangePaymentMethodDialog(List<dynamic> paymentMethods) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Drag handle
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Change Payment Method',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Payment methods list
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: paymentMethods.length + 1,
                    itemBuilder: (context, index) {
                      if (index == paymentMethods.length) {
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            child: Icon(
                              Icons.add,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          title: Text(
                            'Add New Payment Method',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onTap: () {
                            Navigator.of(context).pop();
                            context.push('/subscription/payment-methods/add');
                          },
                        );
                      }
                      
                      final paymentMethod = paymentMethods[index];
                      
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          child: Icon(
                            Icons.credit_card,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        title: Text(paymentMethod.displayName),
                        subtitle: paymentMethod.type == 'card'
                            ? Text('Expires ${paymentMethod.expiryDate}')
                            : null,
                        trailing: paymentMethod.isDefault
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Default',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            : null,
                        onTap: () {
                          Navigator.of(context).pop();
                          _updatePaymentMethod(paymentMethod.id);
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'trialing':
        return Colors.blue;
      case 'canceled':
        return Colors.orange;
      case 'incomplete':
      case 'incomplete_expired':
      case 'past_due':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'active':
        return 'Active';
      case 'trialing':
        return 'Trial Period';
      case 'canceled':
        return 'Canceled';
      case 'incomplete':
        return 'Incomplete';
      case 'incomplete_expired':
        return 'Expired';
      case 'past_due':
        return 'Past Due';
      default:
        return 'Unknown';
    }
  }
}

