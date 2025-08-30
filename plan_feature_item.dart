import 'package:flutter/material.dart';

class PlanFeatureItem extends StatelessWidget {
  final String feature;
  final bool isIncluded;
  final Color? checkColor;

  const PlanFeatureItem({
    Key? key,
    required this.feature,
    this.isIncluded = true,
    this.checkColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Check icon
          Icon(
            isIncluded ? Icons.check_circle : Icons.cancel,
            color: isIncluded
                ? checkColor ?? theme.colorScheme.primary
                : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 12),
          
          // Feature text
          Expanded(
            child: Text(
              feature,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isIncluded
                    ? null
                    : theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

