
import 'package:avo_app/my_app.dart';
import 'package:avo_app/app/core/services/remote/firebase_consumer.dart';
import 'package:avo_app/app/core/services/remote/firebase_query_params.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeFirebaseConsumer implements FirebaseConsumer {
  @override
  Future<void> init() async {}
  @override
  Future<T> get<T>(String path, {FirebaseQueryParams? queryParams, required T Function(Map<String, dynamic> json) fromJson}) async {
    throw UnimplementedError();
  }
  @override
  Future<List<T>> getList<T>(String path, {FirebaseQueryParams? queryParams, required T Function(Map<String, dynamic> json) fromJson}) async {
    return [];
  }
  @override
  Stream<List<T>> streamList<T>(String path, {FirebaseQueryParams? queryParams, required T Function(Map<String, dynamic> json) fromJson}) {
    return const Stream.empty();
  }
  @override
  Future<void> set(String path, {required Map<String, dynamic> data}) async {}
  @override
  Future<String> push(String path, {required Map<String, dynamic> data}) async => '';
  @override
  Future<void> update(String path, {required Map<String, dynamic> data}) async {}
  @override
  Future<void> delete(String path) async {}
}

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(firebaseConsumer: FakeFirebaseConsumer()));

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
