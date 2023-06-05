import 'package:firebase_database/firebase_database.dart';

class TripsHistoryModel {
  String? originAddress;
  String? destinationAddress;
  String? numberOfSeats;
  String? passengerFare;
  String? userContactNumber;
  String? userFirstName;
  String? userLastName;
  String? driverName;

  TripsHistoryModel({
    this.originAddress,
    this.destinationAddress,
    this.numberOfSeats,
    this.passengerFare,
    this.userContactNumber,
    this.userFirstName,
    this.userLastName,
    this.driverName,
  });

  TripsHistoryModel.fromSnapshot(DataSnapshot dataSnapshot) {
    numberOfSeats = (dataSnapshot.value as Map)["numberOfSeats"];
    passengerFare = (dataSnapshot.value as Map)["passengerFare"];
    userContactNumber = (dataSnapshot.value as Map)["userContactNumber"];
    userFirstName = (dataSnapshot.value as Map)["userFirstName"];
    userLastName = (dataSnapshot.value as Map)["userLastName"];
    originAddress = (dataSnapshot.value as Map)["originAddress"];
    destinationAddress = (dataSnapshot.value as Map)["destinationAddress"];
  }
}
