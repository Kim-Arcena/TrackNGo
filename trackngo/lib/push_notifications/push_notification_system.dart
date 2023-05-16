import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:trackngo/global/global.dart';

class PushNotificationSystem {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  Future initializeCloudMessagin() async {
    //terminated
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? remoteMessage) {
      if (remoteMessage != null) {
        //display ride information
      }
    });

    //foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage? remoteMessage) {});

    //background
    FirebaseMessaging.onMessageOpenedApp
        .listen((RemoteMessage? remoteMessage) {});
  }

  Future generateAndGetToken() async {
    String? registrationToken = await messaging.getToken();
    print("registration token: ");
    print(registrationToken);
    FirebaseDatabase.instance
        .ref()
        .child("driver")
        .child(currentFirebaseUser!.uid)
        .child("token")
        .set(registrationToken);

    messaging.subscribeToTopic("allDrivers");
    messaging.subscribeToTopic("allUsers");
  }
}
