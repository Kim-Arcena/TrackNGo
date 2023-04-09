import 'package:flutter/material.dart';
import 'package:trackngo/global/map_key.dart';
import 'package:trackngo/models/predicted_places.dart';

import '../assistants/request_assistant.dart';
import '../models/directions.dart';

class PlacePredictionTileDesign extends StatelessWidget {
  final PredictedPlaces? predictedPlaces;

  PlacePredictionTileDesign({this.predictedPlaces});

  getPlaceAddressDetails(String placeId, context) async {
    String placeDirectionDetailsUrl =
        "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$mapKey";

    var responseApi =
        await RequestAssistant.receiveRequest(placeDirectionDetailsUrl);

    if (responseApi == "Error Occurred") {
      return;
    }

    if (responseApi["status"] == "OK") {
      Directions directions = Directions();

      directions.locationId = placeId;
      directions.locationName = responseApi["result"]["name"];
      directions.locationLatitude =
          responseApi["result"]["geometry"]["location"]["lat"];
      directions.locationLongitude =
          responseApi["result"]["geometry"]["location"]["lng"];

      print("location name: ${directions.locationName}");
      print("location latitude: ${directions.locationLatitude}");
      print("location longitude: ${directions.locationLongitude}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: () {
          getPlaceAddressDetails(predictedPlaces!.place_id!, context);
        },
        style: ElevatedButton.styleFrom(
          primary: Colors.white,
          onPrimary: Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              const Icon(Icons.add_location),
              const SizedBox(width: 14),
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(predictedPlaces!.main_text!,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 2),
                  Text(predictedPlaces!.secondary_text!,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12)),
                  const SizedBox(height: 8),
                ],
              )),
            ],
          ),
        ));
  }
}
