  import 'package:flutter/src/material/colors.dart';
  import 'package:google_maps_flutter/google_maps_flutter.dart';

  class UserRideRequestInformation {
    LatLng? originLatLng;
    LatLng? destinationLatLng;

    String? originAddress;
    String? destinationAddress;

    String? rideRequestId;
    String? userFirstName;
    String? userLastName;
    String? userContactNumber;
    String? numberOfSeats;
    String? passengerFare;

    UserRideRequestInformation({
      this.originLatLng,
      this.destinationLatLng,
      this.originAddress,
      this.destinationAddress,
      this.rideRequestId,
      this.userFirstName,
      this.userLastName,
      this.userContactNumber,
      this.numberOfSeats,
      this.passengerFare,
    });

    set buttonColor(MaterialAccentColor buttonColor) {}

    set buttonTitle(String buttonTitle) {}

    toJson() {}
  }
