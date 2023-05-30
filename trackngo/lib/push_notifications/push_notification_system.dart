import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trackngo/global/global.dart';
import 'package:trackngo/models/user_ride_request_information.dart';
import 'package:trackngo/push_notifications/notification_dialog_box.dart';

class PushNotificationSystem {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  Future initializeCloudMessagin(BuildContext context) async {
    //terminated
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? remoteMessage) {
      if (remoteMessage != null) {
        print("remote message id: ");
        print(remoteMessage.data["rideRequestId"]);
        //display ride information

        readUserRideRequestInformation(
            remoteMessage.data["rideRequestId"], context);
      }
    });

    //foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage? remoteMessage) {
      print("remote message: ");
      print(remoteMessage?.data);
      readUserRideRequestInformation(
          remoteMessage?.data["rideRequestId"], context);
    });

    //background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? remoteMessage) {
      print("remote message: ");
      print(remoteMessage?.data);

      readUserRideRequestInformation(
          remoteMessage?.data["rideRequestId"], context);
    });
  }

  readUserRideRequestInformation(String rideRequestId, BuildContext context) {
    FirebaseDatabase.instance
        .ref()
        .child("All Ride Requests")
        .child(rideRequestId)
        .once()
        .then((snapData) {
      print("read user ride request information: " +
          snapData.snapshot.value.toString());
      if (snapData.snapshot.value != null) {
        audioPlayer!.open(Audio("music/notification.mp3"));
        audioPlayer!.play();

        String rideRequestId = snapData.snapshot.key.toString();
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

        String numberOfSeats =
            (snapData.snapshot.value! as Map)["numberOfSeats"].toString();

        String passengerFare =
            (snapData.snapshot.value! as Map)["fare"].toString();
        UserRideRequestInformation userRideRequestDetails =
            UserRideRequestInformation();

        userRideRequestDetails.rideRequestId = rideRequestId;
        userRideRequestDetails.originLatLng = LatLng(originLat, originLng);
        userRideRequestDetails.destinationLatLng =
            LatLng(destinationLat, destinationLng);
        userRideRequestDetails.originAddress = originAddress;
        userRideRequestDetails.destinationAddress = destinationAddress;
        userRideRequestDetails.userFirstName = userFirstName;
        userRideRequestDetails.userLastName = userLastName;
        userRideRequestDetails.userContactNumber = userContactNumber;
        userRideRequestDetails.numberOfSeats = numberOfSeats;
        userRideRequestDetails.passengerFare = passengerFare;

        showDialog(
          context: context,
          builder: (BuildContext context) => NotificationDialogBox(
            userRideRequestDetails: userRideRequestDetails,
          ),
        );
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
