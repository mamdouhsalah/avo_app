import 'package:avo_app/app/core/models/login_request_model.dart';
import 'package:avo_app/app/core/models/user_profile_model.dart';
import 'package:avo_app/app/core/services/remote/firebase_consumer.dart';
import 'package:avo_app/app/core/services/remote/firebase_query_params.dart';
import 'package:avo_app/app/features/auth/data/auth_repository_impl.dart';
import 'package:avo_app/my_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'auth/mock_auth.dart';

class FakeFirebaseConsumer implements FirebaseConsumer {
  @override
  Future<void> init() async {}
  @override
  Future<T> get<T>(String path,
      {FirebaseQueryParams? queryParams,
      required T Function(Map<String, dynamic> json) fromJson}) async {
    throw UnimplementedError();
  }

  @override
  Future<List<T>> getList<T>(String path,
      {FirebaseQueryParams? queryParams,
      required T Function(Map<String, dynamic> json) fromJson}) async {
    return [];
  }

  @override
  Stream<List<T>> streamList<T>(String path,
      {FirebaseQueryParams? queryParams,
      required T Function(Map<String, dynamic> json) fromJson}) {
    return const Stream.empty();
  }

  @override
  Future<void> set(String path, {required Map<String, dynamic> data}) async {}
  @override
  Future<String> push(String path,
          {required Map<String, dynamic> data}) async =>
      '';
  @override
  Future<void> update(String path,
      {required Map<String, dynamic> data}) async {}
  @override
  Future<void> delete(String path) async {}
}

void main() {
  late MockFirebaseConsumer mockFirebaseConsumer;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockCloudinaryService mockCloudinaryService;
  late AuthRepositoryImpl authRepository;
  late MockUserCredintial mockUserCredintial;
  late MockUser mockUser;

  setUp(() {
    mockFirebaseConsumer = MockFirebaseConsumer();
    mockFirebaseAuth = MockFirebaseAuth();
    mockCloudinaryService = MockCloudinaryService();
    mockUserCredintial = MockUserCredintial();
    mockUser = MockUser();

    authRepository = AuthRepositoryImpl(
        consumer: mockFirebaseConsumer,
        firebaseAuth: mockFirebaseAuth,
        cloudinaryService: mockCloudinaryService);
  });

  group("Test Auth", () {
    test('test logout should return an empty AuthResponseModel', () async {
      when(() => mockFirebaseAuth.signOut())
          .thenAnswer((_) async => Future.value());

      await authRepository.logout();

      verify(() => mockFirebaseAuth.signOut()).called(1);
    });

    test('test login should return AuthResponseModel', () async {
      final UserProfileModel expectedProfile = UserProfileModel(
          email: 'abdallahalqiran765@gmail.com',
          fullName: "Abdallah Mahmoud",
          role: "Engineer",
          gender: 'Male',
          dateOfBirth: "07-06-2005",
          phoneNumber: "01016611062",
          height: 220,
          weight: 160,
          image: "the moon",
          isVerified: true);

      final LoginRequestModel loginRequestModel = LoginRequestModel(
          email: 'abdallahalqiran765@gmail.com', password: 'Abdallah@2026');

      when(() => mockUser.uid).thenReturn('fake_uid_1234');
      when(() => mockUser.emailVerified).thenReturn(true);
      when(() => mockUserCredintial.user).thenReturn(mockUser);

      when(() => mockFirebaseAuth.signInWithEmailAndPassword(
              email: loginRequestModel.email,
              password: loginRequestModel.password))
          .thenAnswer((_) async => mockUserCredintial);

      when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);

      when(() => mockFirebaseConsumer.get<UserProfileModel>(
            'users/fake_uid_1234',
            fromJson: any(named: 'fromJson'),
          )).thenAnswer((_) async => expectedProfile);

      final result = await authRepository.login(loginRequestModel);

      expect(result.email, expectedProfile.email);
      expect(result.fullName, expectedProfile.fullName);
      expect(result.role, expectedProfile.role);
      expect(result.gender, expectedProfile.gender);
      expect(result.dateOfBirth, expectedProfile.dateOfBirth);
      expect(result.phoneNumber, expectedProfile.phoneNumber);
      expect(result.height, expectedProfile.height);
      expect(result.weight, expectedProfile.weight);
      expect(result.image, expectedProfile.image);
      expect(result.isVerified, expectedProfile.isVerified);
    });
  });


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
