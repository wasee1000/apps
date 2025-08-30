/// Base exception class for the app
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  AppException(this.message, {this.code, this.details});

  @override
  String toString() => 'AppException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Authentication related exceptions
class AuthException extends AppException {
  AuthException(String message, {String? code, dynamic details})
      : super(message, code: code, details: details);
}

/// Data fetching and processing exceptions
class DataException extends AppException {
  DataException(String message, {String? code, dynamic details})
      : super(message, code: code, details: details);
}

/// Network related exceptions
class NetworkException extends AppException {
  NetworkException(String message, {String? code, dynamic details})
      : super(message, code: code, details: details);
}

/// Storage related exceptions
class StorageException extends AppException {
  StorageException(String message, {String? code, dynamic details})
      : super(message, code: code, details: details);
}

/// Video playback related exceptions
class VideoException extends AppException {
  VideoException(String message, {String? code, dynamic details})
      : super(message, code: code, details: details);
}

/// Subscription related exceptions
class SubscriptionException extends AppException {
  SubscriptionException(String message, {String? code, dynamic details})
      : super(message, code: code, details: details);
}

/// Download related exceptions
class DownloadException extends AppException {
  DownloadException(String message, {String? code, dynamic details})
      : super(message, code: code, details: details);
}

/// Permission related exceptions
class PermissionException extends AppException {
  PermissionException(String message, {String? code, dynamic details})
      : super(message, code: code, details: details);
}

/// Validation related exceptions
class ValidationException extends AppException {
  ValidationException(String message, {String? code, dynamic details})
      : super(message, code: code, details: details);
}

/// Admin related exceptions
class AdminException extends AppException {
  AdminException(String message, {String? code, dynamic details})
      : super(message, code: code, details: details);
}

