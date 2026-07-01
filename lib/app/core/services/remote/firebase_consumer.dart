import 'package:avo_app/app/core/services/remote/firebase_query_params.dart';

abstract class FirebaseConsumer {
  Future<void> init();

  Future<T> get<T>(
    String path, {
    FirebaseQueryParams? queryParams,
    required T Function(Map<String, dynamic> json) fromJson,
  });

  Future<List<T>> getList<T>(
    String path, {
    FirebaseQueryParams? queryParams,
    required T Function(Map<String, dynamic> json) fromJson,
  });

  Stream<List<T>> streamList<T>(
    String path, {
    FirebaseQueryParams? queryParams,
    required T Function(Map<String, dynamic> json) fromJson,
  });

  Future<void> set(String path, {required Map<String, dynamic> data});

  Future<String> push(String path, {required Map<String, dynamic> data});

  Future<void> update(String path, {required Map<String, dynamic> data});

  Future<void> delete(String path);

  String? getRefrence({required String path});
}
