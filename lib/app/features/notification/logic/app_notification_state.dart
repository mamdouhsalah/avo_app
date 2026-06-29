import 'package:avo_app/app/features/notification/data/models/notification_model.dart';
import 'package:equatable/equatable.dart';

abstract class AppNotificationState extends Equatable {
  const AppNotificationState();

  @override
  List<Object> get props => [];
}

class AppNotificationInitial extends AppNotificationState {}

class AppNotificationLoading extends AppNotificationState {}

class AppNotificationLoaded extends AppNotificationState {
  final List<NotificationModel> notifications;
  final int unreadCount;
  final int totalCount;

  const AppNotificationLoaded({
    required this.notifications,
    required this.unreadCount,
    required this.totalCount,
  });

  @override
  List<Object> get props => [notifications, unreadCount, totalCount];
}

class AppNotificationError extends AppNotificationState {
  final String message;

  const AppNotificationError(this.message);

  @override
  List<Object> get props => [message];
}
