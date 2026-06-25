import 'package:avo_app/app/core/services/remote/cloudinary_service.dart';
import 'package:avo_app/app/core/services/remote/firebase_consumer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseConsumer extends Mock implements FirebaseConsumer {}

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockCloudinaryService extends Mock implements CloudinaryService {}

class MockUserCredintial extends Mock implements UserCredential {}

class MockUser extends Mock implements User {}