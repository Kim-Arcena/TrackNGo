import 'package:flutter/material.dart';

class RideRequest {
  // existing properties

  late String buttonTitle;
  late Color buttonColor;

  RideRequest({required String rideRequestId}/* existing constructor parameters */) {
    // existing constructor logic
    buttonTitle = "Initial Button Title";
    buttonColor = Colors.blue; // or any default color
  }
}
