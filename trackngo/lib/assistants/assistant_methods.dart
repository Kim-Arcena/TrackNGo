import 'dart:convert';

import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter_platform_interface/src/types/location.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:trackngo/assistants/request_assistant.dart';
import 'package:trackngo/global/global.dart';
import 'package:trackngo/global/map_key.dart';
import 'package:trackngo/models/directions_details_info.dart';

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

  static readCurrentOnlineUserInfo() {}

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
    var destinationAddress =
        Provider.of<AppInfo>(context, listen: false).userDropOffLocation;

    Map<String, String> headerNotification = {
      'Content-Type': 'application/json',
      'Authorization': deviceRegistrationToken,
    };

    Map bodyNotification = {
      "body":
          "Destination address is $destinationAddress, you have a passenger request!",
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
  }
}
