import 'package:firebase_core/firebase_core.dart';

class DatabaseException {
  final String message;
  final String? code;
  const DatabaseException(this.message, [this.code]);

  @override
  toString() => 'DatabaseException: $message (Code: $code)';
}

class DatabaseExceptionHandler {
  static DatabaseException handleException(dynamic error) {
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return DatabaseException('You do not have permission to access this data.', error.code);
        case 'disconnected':
          return DatabaseException('Network connection lost. Please check your internet.', error.code);
        case 'network-error':
          return DatabaseException('A network error occurred.', error.code);
        default:
          return DatabaseException(error.message ?? 'An unknown Firebase error occurred.', error.code);
      }
    }
    return DatabaseException('An unexpected error occurred: ${error.toString()}');
  }
}