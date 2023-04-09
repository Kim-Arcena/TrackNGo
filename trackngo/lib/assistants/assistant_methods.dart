import 'package:flutter/src/widgets/framework.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter_platform_interface/src/types/location.dart';
import 'package:provider/provider.dart';
import 'package:trackngo/assistants/request_assistant.dart';
import 'package:trackngo/global/map_key.dart';

import '../infoHandler/app_info.dart';
import '../models/directions.dart';

class AssistantMethods {
  static Future<String> searchAddressForGeographicalCoordinates(
      Position position, context) async {
    String humanReadableAddress = "";
    String apiUrl =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&result_type=street_address&key=$mapKey";

    var requestResponse = await RequestAssistant.receiveRequest(apiUrl);

    if (requestResponse != "Error Occurred") {
      // Get the formatted address from the first result
      humanReadableAddress = requestResponse["results"][0]["formatted_address"];

      Directions userPickUpAddress = Directions();
      userPickUpAddress.locationLatitude = position.latitude;
      userPickUpAddress.locationLongitude = position.longitude;
      userPickUpAddress.locationName = humanReadableAddress;

      Provider.of<AppInfo>(context, listen: false)
          .updateUserPickUpLocationAddress(userPickUpAddress);
    }

    return humanReadableAddress;
  }
}
