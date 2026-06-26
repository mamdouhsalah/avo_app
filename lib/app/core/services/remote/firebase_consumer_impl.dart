import 'dart:developer';

import 'package:avo_app/app/core/errors/database_exception.dart';
import 'package:avo_app/app/core/services/remote/firebase_consumer.dart';
import 'package:avo_app/app/core/services/remote/firebase_query_params.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class FirebaseConsumerImpl implements FirebaseConsumer {
  FirebaseDatabase get _database => FirebaseDatabase.instance;

  @override
  Future<void> init() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }

      _database.setPersistenceEnabled(true);
    } catch (e) {
      throw DatabaseExceptionHandler.handleException(e);
    }
  }

  Query _getQuery(String path, FirebaseQueryParams? queryParams) {
    final ref = _database.ref(path);
    return queryParams?.buildQuery(ref) ?? ref;
  }

  @override
  Future<T> get<T>(String path,
      {FirebaseQueryParams? queryParams,
      required T Function(Map<String, dynamic> json) fromJson}) async {
    try {
      final ref = _getQuery(path, queryParams);
      final snapshot = await ref.get();
      if (snapshot.exists) {
        final rawValue = snapshot.value;
        if (rawValue is Map) {
          final data = _castMap(rawValue);
          data['id'] = snapshot.key;
          final result = fromJson(data);
          log("GET SUCCESS: Path: $path, Response: $data");
          return result;
        } else {
          throw DatabaseException(
            'We encountered an issue processing the data. Please try again.',
            'invalid-data-type',
            'Expected Map data at path: $path, but found: ${rawValue.runtimeType}',
          );
        }
      } else {
        throw DatabaseException(
          'The requested information could not be found.',
          'not-found',
          'No data found at path: $path',
        );
      }
    } catch (e) {
      log("GET FAILED: Path: $path, Error: $e");
      throw DatabaseExceptionHandler.handleException(e);
    }
  }

  @override
  Future<List<T>> getList<T>(String path,
      {FirebaseQueryParams? queryParams,
      required T Function(Map<String, dynamic> json) fromJson}) async {
    try {
      final ref = _getQuery(path, queryParams);
      final snapshot = await ref.get();
      final result = _parseListSnapshot(snapshot, fromJson);
      log("GET LIST SUCCESS: Path: $path, Count: ${result.length}, Response: ${snapshot.value}");
      return result;
    } catch (e) {
      log("GET LIST FAILED: Path: $path, Error: $e");
      throw DatabaseExceptionHandler.handleException(e);
    }
  }

  @override
  Stream<List<T>> streamList<T>(String path,
      {FirebaseQueryParams? queryParams,
      required T Function(Map<String, dynamic> json) fromJson}) {
    try {
      final ref = _getQuery(path, queryParams);
      return ref.onValue.map((event) {
        return _parseListSnapshot(event.snapshot, fromJson);
      });
    } catch (e) {
      throw DatabaseExceptionHandler.handleException(e);
    }
  }

  @override
  Future<void> set(String path, {required Map<String, dynamic> data}) async {
    try {
      await _database.ref(path).set(data);
      log("SET SUCCESS: Path: $path, Data: $data");
    } catch (e) {
      log("SET FAILED: Path: $path, Error: $e");
      throw DatabaseExceptionHandler.handleException(e);
    }
  }

  @override
  Future<String> push(String path, {required Map<String, dynamic> data}) async {
    try {
      final newRef = _database.ref(path).push();
      await newRef.set(data);
      final key = newRef.key!;
      log("PUSH SUCCESS: Path: $path, Key: $key, Data: $data");
      return key;
    } catch (e) {
      log("PUSH FAILED: Path: $path, Error: $e");
      throw DatabaseExceptionHandler.handleException(e);
    }
  }

  @override
  Future<void> update(String path, {required Map<String, dynamic> data}) async {
    try {
      await _database.ref(path).update(data);
      log("UPDATE SUCCESS: Path: $path, Data: $data");
    } catch (e) {
      log("UPDATE FAILED: Path: $path, Error: $e");
      throw DatabaseExceptionHandler.handleException(e);
    }
  }

  @override
  Future<void> delete(String path) async {
    try {
      await _database.ref(path).remove();
      log("DELETE SUCCESS: Path: $path");
    } catch (e) {
      log("DELETE FAILED: Path: $path, Error: $e");
      throw DatabaseExceptionHandler.handleException(e);
    }
  }

  List<T> _parseListSnapshot<T>(
      DataSnapshot snapshot, T Function(Map<String, dynamic> json) fromJson) {
    if (!snapshot.exists || snapshot.value == null) return [];

    final List<T> results = [];
    final rawValue = snapshot.value;

    if (rawValue is Map) {
      rawValue.forEach((key, value) {
        if (value is Map) {
          final data = _castMap(value);
          data['id'] = key.toString();
          results.add(fromJson(data));
        }
      });
    } else if (rawValue is List) {
      for (int i = 0; i < rawValue.length; i++) {
        final value = rawValue[i];
        if (value is Map) {
          final data = _castMap(value);
          data['id'] = i.toString();
          results.add(fromJson(data));
        }
      }
    }

    return results;
  }

  dynamic _castValue(dynamic value) {
    if (value is Map) {
      return _castMap(value);
    } else if (value is List) {
      return value.map((item) => _castValue(item)).toList();
    }
    return value;
  }

  Map<String, dynamic> _castMap(Map<dynamic, dynamic> map) {
    return map.map((key, value) {
      return MapEntry(key.toString(), _castValue(value));
    });
  }
}
