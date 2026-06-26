import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:avo_app/app/core/constants/database_paths.dart';

class PresenceService {
  static void initialize() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        final uid = user.uid;
        final userStatusRef = FirebaseDatabase.instance.ref('${DatabasePaths.users}/$uid');

        final connectedRef = FirebaseDatabase.instance.ref('.info/connected');

        connectedRef.onValue.listen((event) {
          final isConnected = event.snapshot.value as bool? ?? false;
          if (isConnected) {
            userStatusRef.onDisconnect().update({
              'isOnline': false,
              'lastSeen': ServerValue.timestamp,
            }).then((_) {
              userStatusRef.update({
                'isOnline': true,
                'lastSeen': ServerValue.timestamp,
              });
            });
          }
        });
      }
    });
  }
}
