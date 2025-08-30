import 'package:flutter/material.dart';

import '../models/payment_method_model.dart';

class PaymentMethodItem extends StatelessWidget {
  final PaymentMethodModel paymentMethod;
  final bool isSelected;
  final VoidCallback onTap;

  const PaymentMethodItem({
    Key? key,
    required this.paymentMethod,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isSelected ? 2 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.dividerColor.withOpacity(0.3),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Card type icon
              _buildCardTypeIcon(context),
              const SizedBox(width: 16),
              
              // Card details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Card number
                    if (paymentMethod.type == 'card')
                      Text(
                        paymentMethod.maskedCardNumber,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    else
                      Text(
                        paymentMethod.displayName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    
                    // Card details
                    if (paymentMethod.type == 'card') ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          // Expiry date
                          if (paymentMethod.expiryDate.isNotEmpty) ...[
                            Text(
                              'Expires ${paymentMethod.expiryDate}',
                              style: theme.textTheme.bodySmall,
                            ),
                            const SizedBox(width: 16),
                          ],
                          
                          // Card holder name
                          if (paymentMethod.cardHolderName != null)
                            Expanded(
                              child: Text(
                                paymentMethod.cardHolderName!,
                                style: theme.textTheme.bodySmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                    ],
                    
                    // Default badge
                    if (paymentMethod.isDefault) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Default',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              // Selection indicator
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: theme.colorScheme.primary,
                )
              else
                Icon(
                  Icons.circle_outlined,
                  color: theme.dividerColor,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardTypeIcon(BuildContext context) {
    final theme = Theme.of(context);
    
    // Card brand icons
    if (paymentMethod.type == 'card') {
      switch (paymentMethod.brandIconName) {
        case 'visa':
          return Container(
            width: 48,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.blue.shade800,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Center(
              child: Text(
                'VISA',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          );
        case 'mastercard':
          return Container(
            width: 48,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.orange.shade800,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Center(
              child: Text(
                'MC',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          );
        case 'amex':
          return Container(
            width: 48,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.blue.shade600,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Center(
              child: Text(
                'AMEX',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          );
        case 'rupay':
          return Container(
            width: 48,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.green.shade700,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Center(
              child: Text(
                'RuPay',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          );
        default:
          return Container(
            width: 48,
            height: 32,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Center(
              child: Icon(
                Icons.credit_card,
                color: Colors.white,
                size: 20,
              ),
            ),
          );
      }
    }
    
    // Other payment types
    IconData iconData;
    Color backgroundColor;
    
    switch (paymentMethod.type) {
      case 'upi':
        iconData = Icons.account_balance;
        backgroundColor = Colors.purple.shade700;
        break;
      case 'netbanking':
        iconData = Icons.account_balance_wallet;
        backgroundColor = Colors.blue.shade700;
        break;
      case 'wallet':
        iconData = Icons.account_balance_wallet;
        backgroundColor = Colors.orange.shade700;
        break;
      default:
        iconData = Icons.payment;
        backgroundColor = theme.colorScheme.primary;
    }
    
    return Container(
      width: 48,
      height: 32,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Icon(
          iconData,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}

