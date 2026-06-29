import 'package:firebase_core/firebase_core.dart';

class DatabaseException {
  final String message;
  final String? code;
  final String? technicalMessage;

  const DatabaseException(this.message, [this.code, this.technicalMessage]);

  @override
  String toString() => message;
}

class DatabaseExceptionHandler {
  static DatabaseException handleException(dynamic error) {
    if (error is DatabaseException) {
      return error;
    }

    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return DatabaseException(
            'You do not have permission to access this data.',
            error.code,
            error.message,
          );
        case 'disconnected':
          return DatabaseException(
            'Network connection lost. Please check your internet.',
            error.code,
            error.message,
          );
        case 'network-error':
          return DatabaseException(
            'A network error occurred. Please check your connection.',
            error.code,
            error.message,
          );
        default:
          return DatabaseException(
            'Something went wrong. Please try again.',
            error.code,
            error.message ?? 'An unknown Firebase error occurred.',
          );
      }
    }

    return DatabaseException(
      'An unexpected error occurred. Please try again.',
      'unknown',
      error.toString(),
    );
  }
}