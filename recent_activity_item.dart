import 'package:flutter/material.dart';

import '../models/activity_model.dart';

class RecentActivityItem extends StatelessWidget {
  final ActivityModel activity;

  const RecentActivityItem({
    Key? key,
    required this.activity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Activity icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getActivityColor(activity.activityColor).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getActivityIcon(activity.activityIcon),
                color: _getActivityColor(activity.activityColor),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            
            // Activity details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Activity title
                  Text(
                    activity.activityTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  
                  // Activity subtitle
                  Text(
                    activity.activitySubtitle,
                    style: theme.textTheme.bodyMedium,
                  ),
                  
                  // User name if available
                  if (activity.userName != null && 
                      activity.userName!.isNotEmpty &&
                      activity.activitySubtitle != 'By ${activity.userName}') ...[
                    const SizedBox(height: 4),
                    Text(
                      'By ${activity.userName}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
            
            // Timestamp
            Text(
              activity.formattedTimestamp,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getActivityIcon(String iconName) {
    switch (iconName) {
      case 'upload':
        return Icons.upload_file;
      case 'add_circle':
        return Icons.add_circle;
      case 'edit':
        return Icons.edit;
      case 'delete':
        return Icons.delete;
      case 'person':
        return Icons.person;
      case 'login':
        return Icons.login;
      case 'logout':
        return Icons.logout;
      case 'visibility':
        return Icons.visibility;
      case 'payment':
        return Icons.payment;
      case 'card_membership':
        return Icons.card_membership;
      default:
        return Icons.info;
    }
  }

  Color _getActivityColor(String colorName) {
    switch (colorName) {
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'amber':
        return Colors.amber;
      case 'red':
        return Colors.red;
      case 'purple':
        return Colors.purple;
      case 'teal':
        return Colors.teal;
      case 'grey':
        return Colors.grey;
      case 'indigo':
        return Colors.indigo;
      case 'orange':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }
}

