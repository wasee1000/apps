class ActivityModel {
  final String id;
  final String activityType; // 'upload', 'create', 'update', 'delete', 'user_action', etc.
  final String entityType; // 'show', 'episode', 'category', 'user', etc.
  final String? entityId;
  final String? entityName;
  final String? userId;
  final String? userName;
  final String? description;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  ActivityModel({
    required this.id,
    required this.activityType,
    required this.entityType,
    this.entityId,
    this.entityName,
    this.userId,
    this.userName,
    this.description,
    required this.timestamp,
    this.metadata,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['id'],
      activityType: json['activity_type'],
      entityType: json['entity_type'],
      entityId: json['entity_id'],
      entityName: json['entity_name'],
      userId: json['user_id'],
      userName: json['user_name'],
      description: json['description'],
      timestamp: DateTime.parse(json['timestamp']),
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'activity_type': activityType,
      'entity_type': entityType,
      'entity_id': entityId,
      'entity_name': entityName,
      'user_id': userId,
      'user_name': userName,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }

  // Get formatted timestamp
  String get formattedTimestamp {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  // Get activity icon
  String get activityIcon {
    switch (activityType) {
      case 'upload':
        return 'upload';
      case 'create':
        return 'add_circle';
      case 'update':
        return 'edit';
      case 'delete':
        return 'delete';
      case 'user_action':
        return 'person';
      case 'login':
        return 'login';
      case 'logout':
        return 'logout';
      case 'view':
        return 'visibility';
      case 'payment':
        return 'payment';
      case 'subscription':
        return 'card_membership';
      default:
        return 'info';
    }
  }

  // Get activity color
  String get activityColor {
    switch (activityType) {
      case 'upload':
        return 'blue';
      case 'create':
        return 'green';
      case 'update':
        return 'amber';
      case 'delete':
        return 'red';
      case 'user_action':
        return 'purple';
      case 'login':
        return 'teal';
      case 'logout':
        return 'grey';
      case 'view':
        return 'indigo';
      case 'payment':
        return 'green';
      case 'subscription':
        return 'orange';
      default:
        return 'blue';
    }
  }

  // Get activity title
  String get activityTitle {
    String title = '';
    
    switch (activityType) {
      case 'upload':
        title = 'Uploaded';
        break;
      case 'create':
        title = 'Created';
        break;
      case 'update':
        title = 'Updated';
        break;
      case 'delete':
        title = 'Deleted';
        break;
      case 'user_action':
        title = 'User Action';
        break;
      case 'login':
        title = 'Logged In';
        break;
      case 'logout':
        title = 'Logged Out';
        break;
      case 'view':
        title = 'Viewed';
        break;
      case 'payment':
        title = 'Payment';
        break;
      case 'subscription':
        title = 'Subscription';
        break;
      default:
        title = activityType.toUpperCase();
    }
    
    if (entityType.isNotEmpty) {
      title += ' ${entityType.toLowerCase()}';
    }
    
    if (entityName != null && entityName!.isNotEmpty) {
      title += ': $entityName';
    }
    
    return title;
  }

  // Get activity subtitle
  String get activitySubtitle {
    if (description != null && description!.isNotEmpty) {
      return description!;
    }
    
    if (userName != null && userName!.isNotEmpty) {
      return 'By $userName';
    }
    
    return formattedTimestamp;
  }
}

