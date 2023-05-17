import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trackngo/global/global.dart';
import 'package:trackngo/models/user_ride_request_information.dart';

class PushNotificationSystem {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  Future initializeCloudMessagin() async {
    //terminated
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? remoteMessage) {
      if (remoteMessage != null) {
        print("remote message id: ");
        print(remoteMessage.data["rideRequestId"]);
        //display ride information

        readUserRideRequestInformation(remoteMessage.data["rideRequestId"]);
      }
    });

    //foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage? remoteMessage) {
      print("remote message: ");
      print(remoteMessage?.data);
      readUserRideRequestInformation(remoteMessage?.data["rideRequestId"]);
    });

    //background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? remoteMessage) {
      print("remote message: ");
      print(remoteMessage?.data);

      readUserRideRequestInformation(remoteMessage?.data["rideRequestId"]);
    });
  }

  readUserRideRequestInformation(String rideRequestId) {
    FirebaseDatabase.instance
        .ref()
        .child("All Ride Requests")
        .child(rideRequestId)
        .once()
        .then((snapData) {
      if (snapData.snapshot.value != null) {
        double originLat = double.parse(
            (snapData.snapshot.value! as Map)["origin"]["latitude"]);
        double originLng = double.parse(
            (snapData.snapshot.value! as Map)["origin"]["longitude"]
                .toString());
        double destinationLat = double.parse(
            (snapData.snapshot.value! as Map)["destination"]["latitude"]);
        double destinationLng = double.parse(
            (snapData.snapshot.value! as Map)["destination"]["longitude"]
                .toString());
        String originAddress =
            (snapData.snapshot.value! as Map)["originAddress"];
        String destinationAddress =
            (snapData.snapshot.value! as Map)["destinationAddress"];

        String userFirstName =
            (snapData.snapshot.value! as Map)["userFirstName"].toString();
        String userLastName =
            (snapData.snapshot.value! as Map)["userLastName"].toString();

        String userContactNumber =
            (snapData.snapshot.value! as Map)["userContact"].toString();

        UserRideRequestInformation userRideRequestInformation =
            UserRideRequestInformation(
          originLatLng: LatLng(originLat, originLng),
          destinationLatLng: LatLng(destinationLat, destinationLng),
          originAddress: originAddress,
          destinationAddress: destinationAddress,
          rideRequestId: rideRequestId,
          userFirstName: userFirstName,
          userLastName: userLastName,
          userContactNumber: userContactNumber,
        );

        print("userRideRequestInformation: ");
        print(userRideRequestInformation.userLastName);
      } else {
        Fluttertoast.showToast(msg: "This ride message does not exist. ");
      }
    });
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
