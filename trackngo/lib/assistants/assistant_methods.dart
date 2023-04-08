import 'package:flutter/src/widgets/framework.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter_platform_interface/src/types/location.dart';
import 'package:trackngo/assistants/request_assistant.dart';
import 'package:trackngo/global/map_key.dart';

class AssistantMethods {
  static Future<String> searchAddressForGeographicalCoordinates(
      Position position) async {
    String humanReadableAddress = "";
    String apiUrl =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey";

    var requestResponse = await RequestAssistant.receiveRequest(apiUrl);

    if (requestResponse != "Error Occurred") {
      humanReadableAddress = requestResponse["results"][0]["formatted_address"];
    }

    return humanReadableAddress;
  }
}
