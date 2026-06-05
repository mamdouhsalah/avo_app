import 'package:firebase_database/firebase_database.dart';

class FirebaseQueryParams {
  final String? orderByChild;
  final String? orderByKey;
  final String? orderByValue;
  final dynamic equalTo;
  final int? limitToFirst;
  final int? limitToLast;
  final dynamic startAt;
  final dynamic endAt;

  FirebaseQueryParams({
    this.orderByChild,
    this.orderByKey,
    this.orderByValue,
    this.equalTo,
    this.limitToFirst,
    this.limitToLast,
    this.startAt,
    this.endAt,
  });

  Query buildQuery(DatabaseReference ref) {

    Query query = ref;

    if (orderByChild != null) {
      query = query.orderByChild(orderByChild!);
    } else if (orderByKey != null) {
      query = query.orderByKey();
    } else if (orderByValue != null) {
      query = query.orderByValue();
    }

    if (equalTo != null) query = query.equalTo(equalTo);
    if (startAt != null) query = query.startAt(startAt);
    if (endAt != null) query = query.endAt(endAt);

    if (limitToFirst != null) query = query.limitToFirst(limitToFirst!);
    if (limitToLast != null) query = query.limitToLast(limitToLast!);

    return query;
  } 
}