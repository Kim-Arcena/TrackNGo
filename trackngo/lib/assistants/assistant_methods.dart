import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter_platform_interface/src/types/location.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:trackngo/assistants/request_assistant.dart';
import 'package:trackngo/global/global.dart';
import 'package:trackngo/global/map_key.dart';
import 'package:trackngo/models/directions_details_info.dart';
import 'package:trackngo/models/trip_history_model.dart';

import '../infoHandler/app_info.dart';
import '../models/directions.dart';

class AssistantMethods {
  static Future<String> searchAddressForGeographicalCoordinates(
      Position position, context) async {
    String humanReadableAddress = "";
    String apiUrl =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&result_type=point_of_interest&key=$mapKey";

    var requestResponse = await RequestAssistant.receiveRequest(apiUrl);

    if (requestResponse != "Error Occurred") {
      // Check if any results were returned
      if (requestResponse["status"] == "ZERO_RESULTS" &&
          requestResponse["plus_code"] != null) {
        // Use the compound_code as a fallback option
        humanReadableAddress = requestResponse["plus_code"]["compound_code"];
      } else {
        // Get the formatted address from the first result
        humanReadableAddress =
            requestResponse["results"][0]["formatted_address"];
      }

      Directions userPickUpAddress = Directions();
      userPickUpAddress.locationLatitude = position.latitude;
      userPickUpAddress.locationLongitude = position.longitude;
      userPickUpAddress.locationName = humanReadableAddress;

      Provider.of<AppInfo>(context, listen: false)
          .updatePickUpLocationAddress(userPickUpAddress);
    }

    return humanReadableAddress;
  }

  static Future<DirectionDetailsInfo?>
      obtainOriginToDestinationDirectionDetails(
          LatLng originPosition, LatLng destinationPosition) async {
    String urlOriginToDestinationDirectionDetails =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${originPosition.latitude},${originPosition.longitude}&destination=${destinationPosition.latitude},${destinationPosition.longitude}&key=$mapKey";

    var responseDirectionApi = await RequestAssistant.receiveRequest(
        urlOriginToDestinationDirectionDetails);

    if (responseDirectionApi == "Error Occurred") {
      print("There was an error obtaining the directions");
      return null;
    }

    DirectionDetailsInfo directionDetailsInfo = DirectionDetailsInfo();
    directionDetailsInfo.e_points =
        responseDirectionApi["routes"][0]["overview_polyline"]["points"];

    directionDetailsInfo.distance_text =
        responseDirectionApi["routes"][0]["legs"][0]["distance"]["text"];
    directionDetailsInfo.distance_value =
        responseDirectionApi["routes"][0]["legs"][0]["distance"]["value"];

    int durationValue =
        responseDirectionApi["routes"][0]["legs"][0]["duration"]["value"];
    int hours = durationValue ~/ 3600;
    int minutes = (durationValue % 3600) ~/ 60;

    String durationText = '';
    if (hours > 0) {
      durationText += '${hours}h ';
    }
    if (minutes > 0) {
      durationText += '${minutes}m';
    }

    directionDetailsInfo.duration_text = durationText;
    directionDetailsInfo.duration_value = durationValue;

    return directionDetailsInfo;
  }

  static double calculateFairAmountFromOriginToDestination(
      DirectionDetailsInfo directionDetailsInfo) {
    double distanceTraveledFarePerMinute =
        (directionDetailsInfo.duration_value! / 1000) * 2 * numberOfSeats;
    double totalFairAmount = distanceTraveledFarePerMinute;
    return double.parse(totalFairAmount.toStringAsFixed(2));
  }

  static pauseLiveLocationUpdates() {
    streamStreamSubscription!.pause();
    Geofire.removeLocation(currentFirebaseUser!.uid);
  }

  static resumeLiveLocationUpdates() {
    streamStreamSubscription!.resume();
    Geofire.setLocation(currentFirebaseUser!.uid, currentPosition!.latitude,
        currentPosition!.longitude);
  }

  static sendNotificationToDriverNow(
      String deviceRegistrationToken, String userRideRequestId, context) async {
    Map<String, String> headerNotification = {
      'Content-Type': 'application/json',
      'Authorization':
          "key=AAAAwdoQeAI:APA91bGe6W2SeClvRAK16lnY3aSOSTh9_mYDhAI86AtpJNNC_ge_k75f372XjVtS5xdjDQ00e81VaCJimbYdj7n7-x17QzAWWCsJdCxkyjvlXNyRzOj7zA9FJ75jqSFF25P0H30REw1o",
    };

    Map bodyNotification = {
      "body": "Hi Driver, you have a passenger request!",
      "title": "TrackNGo"
    };

    Map dataMap = {
      "click_action": "FLUTTER_NOTIFICATION_CLICK",
      "id": 1,
      "status": "done",
      "rideRequestId": userRideRequestId
    };

    Map officialNotificationFormat = {
      "notification": bodyNotification,
      "data": dataMap,
      "priority": "high",
      "to": deviceRegistrationToken,
    };

    var responseNotification = http.post(
        Uri.parse("https://fcm.googleapis.com/fcm/send"),
        headers: headerNotification,
        body: jsonEncode(officialNotificationFormat));

    print(responseNotification);
  }

  //retrieve the trips KEYS for online user
  //trip key = ride request key
  static void readTripsKeysForOnlineUser(context) {
    print(
        "current user id from assistant methods: " + currentFirebaseUser!.uid);
    FirebaseDatabase.instance
        .ref()
        .child("driver")
        .child(currentFirebaseUser!.uid)
        .child("finishedTripHistory")
        .once()
        .then((snap) {
      if (snap.snapshot.value != null) {
        Map keysTripsId = snap.snapshot.value as Map;

        //count total number trips and share it with Provider
        int overAllTripsCounter = keysTripsId.length;
        Provider.of<AppInfo>(context, listen: false)
            .updateOverAllTripsCounter(overAllTripsCounter);

        //share trips keys with Provider
        List<String> tripsKeysList = [];
        keysTripsId.forEach((key, value) {
          tripsKeysList.add(key);
        });
        Provider.of<AppInfo>(context, listen: false)
            .updateOverAllTripsKeys(tripsKeysList);

        //get trips keys data - read trips complete information
        // Get trips keys data - read trips complete information
        Provider.of<AppInfo>(context, listen: false)
            .clearAllTripsHistoryInformation();
        readTripsHistoryInformation(context);
      }
    });
  }

  static void readTripsHistoryInformation(context) {
    var tripsAllKeys =
        Provider.of<AppInfo>(context, listen: false).historyTripsKeysList;
    print(tripsAllKeys.length.toString() + " trips keys length");
    for (String eachKey in tripsAllKeys) {
      FirebaseDatabase.instance
          .ref()
          .child("driver")
          .child(currentFirebaseUser!.uid)
          .child("finishedTripHistory")
          .child(eachKey)
          .once()
          .then((snap) {
        var eachTripHistory = TripsHistoryModel.fromSnapshot(snap.snapshot);

        Provider.of<AppInfo>(context, listen: false)
            .updateOverAllTripsHistoryInformation(eachTripHistory);
      });
    }
  }
}
