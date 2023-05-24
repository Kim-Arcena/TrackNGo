import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:trackngo/assistants/assistant_methods.dart';
import 'package:trackngo/global/global.dart';
import 'package:trackngo/mainScreen/driver_trip_screen.dart';
import 'package:trackngo/models/user_ride_request_information.dart';

class NotificationDialogBox extends StatefulWidget {
  UserRideRequestInformation? userRideRequestDetails;

  NotificationDialogBox({this.userRideRequestDetails});

  @override
  State<NotificationDialogBox> createState() => _NotificationDialogBoxState();
}

class _NotificationDialogBoxState extends State<NotificationDialogBox> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 1.0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0)), //this right here
      child: Container(
        height: 420,
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("New Ride Request",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 20.0),
              Column(
                children: [
                  Row(
                    children: [
                      Text(
                          widget.userRideRequestDetails!.userFirstName! +
                              " " +
                              widget.userRideRequestDetails!.userLastName!,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Spacer(),
                      Text(
                          widget.userRideRequestDetails!.numberOfSeats! +
                              " seat",
                          style: TextStyle(fontSize: 16)),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        widget.userRideRequestDetails!.userContactNumber!,
                        style: TextStyle(fontSize: 16),
                      ),
                      Spacer(),
                      RichText(
                        text: TextSpan(
                          text: "Paid: ",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                          ),
                          children: const <TextSpan>[
                            TextSpan(
                                text: '₱100.00',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15)),
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: 20.0,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.location_pin,
                            color: Color(0xFFA8CEB7),
                            size: 30.0,
                          ),
                          Text("Pickup Location",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Text(
                        widget.userRideRequestDetails!.originAddress!,
                      ),
                    ],
                  ),
                  Divider(color: Colors.black, thickness: 1),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.location_pin,
                            color: Color(0xFFA8CEB7),
                            size: 30.0,
                          ),
                          Text("Dropoff Location",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Text(
                        widget.userRideRequestDetails!.destinationAddress!,
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: 20.0,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  fixedSize: Size(280, 45),
                  primary: Color(0xFF199A5D), // background
                ),
                onPressed: () {
                  audioPlayer!.pause();
                  audioPlayer!.stop();
                  audioPlayer = AssetsAudioPlayer();

                  acceptRideRequest(context);
                  // Navigator.of(context).pop();
                },
                child: Text(
                  "ACCEPT RIDE",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  fixedSize: Size(280, 45),
                  primary: Color(0xFF808381), // background
                ),
                onPressed: () {
                  audioPlayer!.pause();
                  audioPlayer!.stop();
                  audioPlayer = AssetsAudioPlayer();
                  Navigator.of(context).pop();
                },
                child: Text(
                  "REJECT RIDE",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  acceptRideRequest(BuildContext context) {
    String getRideRequestId = "";

    FirebaseDatabase.instance
        .ref()
        .child("driver")
        .child(currentFirebaseUser!.uid)
        .child("newRideStatus")
        .once()
        .then((snap) {
      if (snap.snapshot.value != null) {
        getRideRequestId = snap.snapshot.value.toString();
      } else {
        Fluttertoast.showToast(
            msg: "Ride request has been cancelled",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Color(0xFF199A5D),
            textColor: Colors.white,
            fontSize: 16.0);
      }
      print("ride request id: " + getRideRequestId);
      print("ride request idff: " +
          widget.userRideRequestDetails!.rideRequestId!);
      bool isRideRequestIdExists = false;

      for (var item in acceptedRideRequestDetailsList) {
        if (item.rideRequestId ==
            widget.userRideRequestDetails!.rideRequestId) {
          isRideRequestIdExists = true;
          break;
        }
      }

      if (!isRideRequestIdExists) {
        acceptedRideRequestDetailsList.add(widget.userRideRequestDetails!);
        print("Added to the list");
      } else {
        print("The rideRequestId already exists in the list");
      }

      print(acceptedRideRequestDetailsList.length);

      print("the length of the list is: " +
          acceptedRideRequestDetailsList.length.toString());
      for (int i = 0; i < acceptedRideRequestDetailsList.length; i++) {
        print(acceptedRideRequestDetailsList[i].rideRequestId!);
        print(acceptedRideRequestDetailsList[i].userFirstName!);
        print(acceptedRideRequestDetailsList[i].userLastName!);
        print(acceptedRideRequestDetailsList[i].userContactNumber!);
        print(acceptedRideRequestDetailsList[i].originAddress!);
      }

      saveAssignedDriverDetailsToUserRideRequest();

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => DriverTripScreen(
            userRideRequestDetails: widget.userRideRequestDetails,
          ),
        ),
      );
    });
  }

  Future<void> saveAssignedDriverDetailsToUserRideRequest() async {
    print("saveAssignedDriverDetailsToUserRideRequest" +
        widget.userRideRequestDetails.toString());
    if (widget.userRideRequestDetails != null &&
        widget.userRideRequestDetails!.rideRequestId != null) {
      DatabaseReference databaseReference = FirebaseDatabase.instance
          .ref()
          .child("All Ride Requests")
          .child(widget.userRideRequestDetails!.rideRequestId!)
          .child("acceptedRideInfo");

      AssistantMethods.pauseLiveLocationUpdates();

      print("widget.userRideRequestDetails!.rideRequestId! " +
          widget.userRideRequestDetails!.rideRequestId!);

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      var driverCurrentPosition = position;

      Map driverLocationDataMap = {
        "latitude": driverCurrentPosition!.latitude,
        "longitude": driverCurrentPosition!.longitude
      };

      databaseReference.child("driverLocation").set(driverLocationDataMap);
      databaseReference.child("status").set("accepted");
      databaseReference.child("driverId").set(onlineDriverData.id);
      databaseReference
          .child("driverFirstName")
          .set(onlineDriverData.firstName);
      databaseReference.child("driverLastName").set(onlineDriverData.lastName);
      databaseReference
          .child("driverContactNumber")
          .set(onlineDriverData.contactNumber);
      databaseReference.child("driverBusType").set(onlineDriverData.busType);

      saveRideRequestIdToDriverHistory();
    }
  }

  saveRideRequestIdToDriverHistory() {
    DatabaseReference tripHistoryReference = FirebaseDatabase.instance
        .ref()
        .child("driver")
        .child(currentFirebaseUser!.uid)
        .child("tripHistory");
    tripHistoryReference
        .child(widget.userRideRequestDetails!.rideRequestId!)
        .set(true);
  }
}
