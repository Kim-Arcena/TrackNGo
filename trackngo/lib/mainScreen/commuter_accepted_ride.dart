import 'dart:async';
import 'dart:math' as math;

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' hide LocationAccuracy;
import 'package:provider/provider.dart';
import 'package:trackngo/global/global.dart';
import 'package:trackngo/mainScreen/commuter_screen.dart';
import 'package:trackngo/mainScreen/search_places_screen.dart';
import 'package:trackngo/mainScreen/warningDialog.dart';
import 'package:trackngo/models/ride_ref_request_info.dart';
import 'package:trackngo/models/user_ride_request_information.dart';

import '../assistants/assistant_methods.dart';
import '../infoHandler/app_info.dart';

class CommuterAcceptedRideScreen extends StatefulWidget {
  final String chosenDriverId;
  const CommuterAcceptedRideScreen({required this.chosenDriverId});

  @override
  State<CommuterAcceptedRideScreen> createState() =>
      _CommuterAcceptedRideScreenState();

  static _CommuterAcceptedRideScreenState? of(BuildContext context) {
    return context.findAncestorStateOfType<_CommuterAcceptedRideScreenState>();
  }
}

class _CommuterAcceptedRideScreenState
    extends State<CommuterAcceptedRideScreen> {
  LatLng _initialcameraposition = LatLng(20.5937, 78.9629);
  final Completer<GoogleMapController> _controllerGoogleMap =
      Completer<GoogleMapController>();
  GoogleMapController? newGoogleMapController;
  Location _location = Location();
  LocationPermission? _locationPermission;
  String humanReadableAddress = "";
  bool _bottomSheetVisible = true;
  List<LatLng> pLineCoordinatesList = [];
  Set<Polyline> polyLineSet = {};
  BitmapDescriptor? iconAnimatedMarker;
  LatLng _busPosition = LatLng(0, 0); // Initial position at (0, 0)
  var sourceLatLng;
  var userCurrentPosition;
  Set<Marker> markerSet = {};
  Set<Circle> circleSet = {};
  String rideRequestRefId = RideRequestInfo.rideRequestRefId;
  bool activeNearbyAvailableDriversKeysLoaded = false;
  UserRideRequestInformation finishedUserRideInformation =
      UserRideRequestInformation();
  String result = '';

  void _onMapCreated(GoogleMapController _cntlr) async {
    newGoogleMapController = _cntlr;

    // Get user's current location
    Position position = await Geolocator.getCurrentPosition();

    // Get human readable address for the location
    humanReadableAddress =
        await AssistantMethods.searchAddressForGeographicalCoordinates(
            position, context);

    // Set the camera position to the user's location
    setState(() {
      _initialcameraposition = LatLng(position.latitude, position.longitude);
    });

    newGoogleMapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: _initialcameraposition, zoom: 20),
      ),
    );

    var sourcePosition =
        Provider.of<AppInfo>(context, listen: false).userPickUpLocation!;

    //originLatLng
    sourceLatLng = LatLng(
        sourcePosition.locationLatitude!, sourcePosition.locationLongitude!);

    print("this is the sourceLatLng int the _onMapCreated:: $sourceLatLng");

    // Load the custom PNG image
    BitmapDescriptor customIconOrigin = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), 'images/commuter.png');

    Marker originMarker = Marker(
      markerId: const MarkerId("originID"),
      infoWindow:
          InfoWindow(title: sourcePosition.locationName, snippet: "Origin"),
      position: sourceLatLng,
      icon: customIconOrigin,
    );

    Circle originCircle = Circle(
      circleId: const CircleId("originID"),
      fillColor: Color(0x225add6c),
      center: sourceLatLng,
      radius: 25,
      strokeWidth: 4,
      strokeColor: Color(0x225add6c),
    );

    setState(() {
      markerSet.add(originMarker);
      circleSet.add(originCircle);
    });
  }

  getDriversInformation() {
    DatabaseReference driverInfoRef = FirebaseDatabase.instance
        .ref()
        .child("driver")
        .child(chosenDriverId!)
        .child(rideRequestRefId)
        .child("acceptedRideInfo")
        .child("driverLocation");
    print("driverInfoRef is " + driverInfoRef.toString());
  }

  checkIfLocationPermissionGranted() async {
    _locationPermission = await Geolocator.requestPermission();
    if (_locationPermission == LocationPermission.denied) {
      _locationPermission = await Geolocator.requestPermission();
    }
  }

  readFinishedUserRideRequestInformation(String rideRequestId) {
    FirebaseDatabase.instance
        .ref()
        .child("All Ride Requests")
        .child(rideRequestId)
        .once()
        .then((snapData) {
      print("read user ride request information: " +
          snapData.snapshot.value.toString());
      if (snapData.snapshot.value != null) {
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
            (snapData.snapshot.value! as Map)["passengerFare"].toString();
        finishedUserRideInformation.rideRequestId = rideRequestId;
        finishedUserRideInformation.originLatLng = LatLng(originLat, originLng);
        finishedUserRideInformation.destinationLatLng =
            LatLng(destinationLat, destinationLng);
        finishedUserRideInformation.originAddress = originAddress;
        finishedUserRideInformation.destinationAddress = destinationAddress;
        finishedUserRideInformation.userFirstName = userFirstName;
        finishedUserRideInformation.userLastName = userLastName;
        finishedUserRideInformation.userContactNumber = userContactNumber;
        finishedUserRideInformation.numberOfSeats = numberOfSeats;
        finishedUserRideInformation.passengerFare = passengerFare;
      } else {
        Fluttertoast.showToast(msg: "This ride message does not exist. ");
      }
    });
  }

  Future<void> checkRideStatus() async {
    readFinishedUserRideRequestInformation(rideRequestRefId);
    FirebaseDatabase.instance
        .ref()
        .child("All Ride Requests")
        .child(rideRequestRefId)
        .child("acceptedRideInfo")
        .child("status")
        .onValue
        .listen((event) {
      print("event.snapshot.value: " + event.snapshot.value.toString());
      if (event.snapshot.value == "arrived") {
        arrivedAudio!.open(Audio("music/ride_arrived.mp3"));
        arrivedAudio!.play();
        setState(() {
          List<Marker> markerList = List<Marker>.from(markerSet);
          List<Circle> circleList = List<Circle>.from(circleSet);

          int originMarkerIndex = markerList
              .indexWhere((marker) => marker.markerId.value == "originID");
          int originCircleIndex = circleList
              .indexWhere((circle) => circle.circleId.value == "originID");

          if (originMarkerIndex != -1) {
            markerList.removeAt(originMarkerIndex);
          }

          if (originCircleIndex != -1) {
            circleList.removeAt(originCircleIndex);
          }

          setState(() {
            markerSet = Set<Marker>.from(markerList);
            circleSet = Set<Circle>.from(circleList);
          });
        });
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            content: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'images/logo.png',
                    width: 100.0,
                    height: 100.0,
                  ), // Replace 'your_image_path.png' with the actual path to your image
                  const SizedBox(height: 10),
                  Text(
                    "Your rider has arrived!",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 10),
                  const SizedBox(height: 10),
                  Text(
                    "Your rider has arrived at your location. We hope you have a pleasant experience with our service. Enjoy your trip and have a great day",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.start,
                  ),
                ],
              ),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15.0)),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  arrivedAudio!.pause();
                  arrivedAudio!.stop();
                  Navigator.of(ctx).pop();
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  child: const Text(
                    "OK",
                    style: TextStyle(
                      color: Color(0xFF4E8C6F),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      } else if (event.snapshot.value == "ontrip") {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            content: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'images/logo.png',
                    width: 100.0,
                    height: 100.0,
                  ), // Replace 'your_image_path.png' with the actual path to your image
                  const SizedBox(height: 10),
                  Text(
                    "Your are currently on trip",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 10),
                  const SizedBox(height: 10),
                  Text(
                    "Enjoy your trip to " +
                        finishedUserRideInformation.destinationAddress
                            .toString() +
                        ". Have a great day!",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.start,
                  ),
                ],
              ),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15.0)),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  child: const Text(
                    "OK",
                    style: TextStyle(
                      color: Color(0xFF4E8C6F),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      } else if (event.snapshot.value == "dropoff") {
        dropOffAudio!.open(Audio("music/arrived_atDistination.mp3"));
        dropOffAudio!.play();
        DatabaseReference finishedTripRef = FirebaseDatabase.instance
            .ref()
            .child("driver")
            .child(chosenDriverId!)
            .child("finishedTripHistory")
            .child(rideRequestRefId);

        finishedTripRef.child("rideRequestRefId").set(rideRequestRefId);
        finishedTripRef
            .child("originAddress")
            .set(finishedUserRideInformation.originAddress.toString());
        finishedTripRef
            .child("destinationAddress")
            .set(finishedUserRideInformation.destinationAddress.toString());
        finishedTripRef
            .child("userFirstName")
            .set(finishedUserRideInformation.userFirstName.toString());
        finishedTripRef
            .child("userLastName")
            .set(finishedUserRideInformation.userLastName.toString());
        finishedTripRef
            .child("userContactNumber")
            .set(finishedUserRideInformation.userContactNumber.toString());
        finishedTripRef
            .child("numberOfSeats")
            .set(finishedUserRideInformation.numberOfSeats.toString());
        finishedTripRef
            .child("passengerFare")
            .set(finishedUserRideInformation.passengerFare.toString());
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            contentPadding: EdgeInsets.zero, // Remove the padding
            content: SingleChildScrollView(
              child: Center(
                child: Column(
                  children: [
                    SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: Column(
                        children: [
                          Image.asset(
                            'images/logo.png',
                            width: 70.0,
                            height: 70.0,
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Trip Success",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "You have successfully reached your destination using TrackNGo!",
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF737574),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 15),
                          Text(
                            "Total Payment",
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF737574),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 5),
                          Text(
                            "P11.00",
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    Image.asset(
                      'images/divider.png',
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 5),
                        child: Column(
                          children: [
                            Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_pin,
                                        color: Color(0xFFA8CEB7),
                                        size: 30.0,
                                      ),
                                      Text(
                                        "Pickup",
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF4E8C6F),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 32.0),
                                    child: Text(
                                      Provider.of<AppInfo>(context)
                                                  .userPickUpLocation !=
                                              null
                                          ? Provider.of<AppInfo>(context)
                                              .userPickUpLocation!
                                              .locationName!
                                          : 'Pickup location',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 32.0),
                              child: Divider(
                                  height: 10.0,
                                  thickness: 0.5,
                                  color: Color(0xFFB9C7C0)),
                            ),
                            Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_pin,
                                        color: Color(0xFFA8CEB7),
                                        size: 30.0,
                                      ),
                                      Text(
                                        "Drop-off",
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF4E8C6F),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 32),
                                    child: Text(
                                      Provider.of<AppInfo>(context)
                                                  .userDropOffLocation !=
                                              null
                                          ? Provider.of<AppInfo>(context)
                                              .userDropOffLocation!
                                              .locationName!
                                          : 'Drop-off location',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Image.asset(
                      'images/divider.png',
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 5),
                      child: Image.asset(
                        'images/barcode.png',
                        height: 70.0,
                      ),
                    ),
                    SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.only(left: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Row(
                            children: [
                              Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                      fit: BoxFit.contain,
                                      image: AssetImage('images/driver.png')),
                                  boxShadow: [
                                    BoxShadow(
                                      offset: Offset(0, 1),
                                      blurRadius: 5,
                                      color: Colors.black.withOpacity(0.2),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      '${chosenDriverInformation?.driverFirstName ?? 'First Name'} ${chosenDriverInformation?.driverLastName ?? 'Last Name'}',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 3,
                                    ),
                                    SizedBox(
                                      height: 4,
                                    ),
                                    Text(
                                      chosenDriverInformation?.busNumber ??
                                          'F4343',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 13,
                                      ),
                                      maxLines: 1,
                                    ),
                                    SizedBox(
                                      height: 1.5,
                                    ),
                                    Text(
                                      chosenDriverInformation
                                              ?.driverContactNumber ??
                                          '09473582942',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 13,
                                      ),
                                      maxLines: 1,
                                    ),
                                    SizedBox(
                                      height: 1.5,
                                    ),
                                    Text(
                                      chosenDriverInformation?.busType ??
                                          'Air-Conditioned',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15.0)),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  dropOffAudio!.pause();
                  dropOffAudio!.stop();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CommuterScreen()));
                },
                child: Container(
                  padding: EdgeInsets.all(0), // Remove the padding
                  child: const Text(
                    "OK",
                    style: TextStyle(
                      color: Color(0xFF4E8C6F),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }
    });
  }

  // Declare a variable to hold the previous bus position
  LatLng? _previousBusPosition;

// Declare a variable to hold the marker instance
  Marker? _driverLocationMarker;

  Future<void> listenToDriverLocationChanges() async {
    print("chosenDriverId is " + chosenDriverId.toString());
    DatabaseReference driversRef = FirebaseDatabase.instance
        .ref()
        .child('activeDrivers')
        .child(chosenDriverId!)
        .child('l');

    driversRef.onValue.listen((event) {
      if (event.snapshot.value != null) {
        dynamic locationData = event.snapshot.value;
        if (locationData is List && locationData.length >= 2) {
          double latitude = locationData[0] as double;
          double longitude = locationData[1] as double;
          LatLng newBusPosition = LatLng(latitude, longitude);

          // Animate the marker movement if there's a previous position
          if (_previousBusPosition != null) {
            animateMarkerToPosition(newBusPosition);
          } else {
            // Create the initial marker if there's no previous position
            createDriverLocationMarker(newBusPosition);
          }

          // Store the current position as the previous position
          _previousBusPosition = newBusPosition;
        }
      }
    });
  }

  void animateMarkerToPosition(LatLng newPosition) {
    final markerId = const MarkerId("driverID");
    final marker = _driverLocationMarker!.copyWith(
      positionParam: newPosition,
    );
    setState(() {
      markerSet.remove(_driverLocationMarker);
      markerSet.add(marker);
      _driverLocationMarker = marker;
    });
  }

  void createDriverLocationMarker(LatLng position) async {
    BitmapDescriptor customIconDestination =
        await BitmapDescriptor.fromAssetImage(
            ImageConfiguration(size: Size(10, 10)), 'images/bus.png');

    final markerId = const MarkerId("driverID");
    final marker = Marker(
      markerId: markerId,
      position: position,
      icon: customIconDestination,
      rotation: getMarkerRotation(position),
    );

    setState(() {
      markerSet.add(marker);
      _driverLocationMarker = marker;
    });
  }

  double getMarkerRotation(LatLng position) {
    // Calculate the rotation angle based on the road or other criteria
    // For example, you can use the difference in latitude or longitude between two positions

    // Here's a sample calculation using the difference in longitude
    if (_previousBusPosition != null) {
      double deltaLongitude =
          position.longitude - _previousBusPosition!.longitude;
      return math.atan2(deltaLongitude, 0) * 180 / math.pi;
    }

    // Return a default rotation angle if there's no previous position
    return 0;
  }

  void initState() {
    super.initState();
    checkIfLocationPermissionGranted();
    listenToDriverLocationChanges();
    getDriversInformation();
    checkRideStatus();
    drawPolyLineFromSourceToDestination();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            initialCameraPosition: CameraPosition(
                target: _initialcameraposition, zoom: 20, tilt: 40),
            cameraTargetBounds: CameraTargetBounds(
              LatLngBounds(
                northeast: LatLng(11.689764, 123.491869),
                southwest: LatLng(10.225571, 121.560314),
              ),
            ),
            mapType: MapType.normal,
            onMapCreated: _onMapCreated,
            polylines: polyLineSet,
            markers: markerSet,
            circles: circleSet,
          ),
          Positioned(
              left: 40.0,
              top: 80.0,
              child: Container(
                width: 50.0,
                height: 50.0,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xffd4dbdd),
                      blurRadius: 12,
                      spreadRadius: 2,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          content: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                const Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    "Pickup",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF4E8C6F),
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_pin,
                                      color: Colors.green,
                                      size: 30.0,
                                    ),
                                    const SizedBox(
                                        width:
                                            10.0), // Add some space between the icon and text field
                                    Expanded(
                                      child: TextField(
                                        controller: TextEditingController(
                                          text: Provider.of<AppInfo>(context)
                                                      .userPickUpLocation !=
                                                  null
                                              ? Provider.of<AppInfo>(context)
                                                  .userPickUpLocation!
                                                  .locationName!
                                              : 'Pickup Location',
                                        ),
                                        decoration: InputDecoration(
                                          hintText: 'Pickup Location',
                                        ),
                                        maxLines: null,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 30.0),
                                const Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    "Dropoff",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF4E8C6F),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10.0),
                                GestureDetector(
                                  onTap: () {
                                    //go to search places screen
                                    var responseFromSearchScreen =
                                        Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            SearchPlacesScreen(),
                                      ),
                                    );
                                  },
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.location_pin,
                                        color: Color(0xFFA8CEB7),
                                        size: 30.0,
                                      ),
                                      SizedBox(
                                          width:
                                              10.0), // Add some space between the icon and text field
                                      Expanded(
                                        child: TextField(
                                          controller: TextEditingController(
                                            text: Provider.of<AppInfo>(context)
                                                        .userDropOffLocation !=
                                                    null
                                                ? Provider.of<AppInfo>(context)
                                                    .userDropOffLocation!
                                                    .locationName!
                                                : 'DropOff Location',
                                          ),
                                          decoration: InputDecoration(
                                            hintText: 'DropOff Location',
                                          ),
                                          maxLines: null,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          actions: <Widget>[
                            TextButton(
                              child: Text('Cancel'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: Text('OK'),
                              onPressed: () {
                                if (Provider.of<AppInfo>(context, listen: false)
                                        .userDropOffLocation ==
                                    null) {
                                  Fluttertoast.showToast(
                                      msg: "Please select a dropoff location");
                                } else {
                                  drawPolyLineFromSourceToDestination();
                                }
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                  icon: Icon(
                    Icons.location_on_sharp,
                  ),
                ),
              )),
          Positioned(
              right: 40.0,
              top: 80.0,
              child: Container(
                width: 50.0,
                height: 50.0,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xffd4dbdd),
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: () {
                    MyWarningDialog(
                      title: "Logging Out...",
                      content:
                          "You are attempting to log out from your account. Will you continue?\n",
                    ).show(context);
                  },
                  icon: Icon(
                    Icons.logout,
                  ),
                ),
              )),
          DraggableScrollableSheet(
            initialChildSize: 0.31,
            minChildSize: 0.31,
            maxChildSize: 0.53,
            builder: (BuildContext context, ScrollController scrollController) {
              return Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 250,
                  padding:
                      EdgeInsets.only(top: 25, left: 10, right: 10, bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.0),
                      topRight: Radius.circular(20.0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 2,
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Center(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        children: [
                          AutoSizeText(
                            "Driver Information",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 3,
                            minFontSize: 10,
                          ),
                          SizedBox(height: 10),
                          // Add your non-scrollable content here
                          Column(
                            children: [
                              Container(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 0, horizontal: 20),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Row(
                                        children: [
                                          Container(
                                            width: 90,
                                            height: 90,
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                  fit: BoxFit.contain,
                                                  image: AssetImage(
                                                      'images/driver.png')),
                                              boxShadow: [
                                                BoxShadow(
                                                  offset: Offset(0, 1),
                                                  blurRadius: 5,
                                                  color: Colors.black
                                                      .withOpacity(0.2),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Row(
                                                children: [
                                                  AutoSizeText(
                                                    '${chosenDriverInformation?.driverFirstName ?? 'First Name'} ${chosenDriverInformation?.driverLastName ?? 'Last Name'}',
                                                    style: TextStyle(
                                                      color: Color(0xFF006836),
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    maxLines: 3,
                                                    minFontSize: 10,
                                                  ),
                                                  SizedBox(
                                                    width: 7,
                                                  ),
                                                  AutoSizeText(
                                                    '09534535345',
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 12,
                                                    ),
                                                    maxLines: 3,
                                                    minFontSize: 10,
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 3,
                                              ),
                                              Row(
                                                children: [
                                                  AutoSizeText(
                                                    chosenDriverInformation
                                                            ?.busNumber ??
                                                        'F4343',
                                                    style: TextStyle(
                                                      color: Color(0xFF006836),
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    maxLines: 1,
                                                    minFontSize: 10,
                                                  ),
                                                  SizedBox(width: 15),
                                                  AutoSizeText(
                                                    chosenDriverInformation
                                                            ?.busType ??
                                                        'Air-Conditioned',
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 16,
                                                    ),
                                                    maxLines: 1,
                                                    minFontSize: 10,
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 3,
                                              ),
                                              Row(
                                                children: [
                                                  AutoSizeText(
                                                    chosenDriverInformation
                                                            ?.busNumber ??
                                                        'Booked: 1',
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 16,
                                                    ),
                                                    maxLines: 1,
                                                    minFontSize: 10,
                                                  ),
                                                  SizedBox(width: 15),
                                                  AutoSizeText(
                                                    chosenDriverInformation
                                                            ?.busType ??
                                                        'Fare: P10.0',
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 16,
                                                    ),
                                                    maxLines: 1,
                                                    minFontSize: 10,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 15),
                          Divider(
                            height: 1,
                            thickness: 1.5,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 5),
                            child: Column(
                              children: [
                                Container(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.location_pin,
                                            color: Color(0xFFA8CEB7),
                                            size: 30.0,
                                          ),
                                          Text(
                                            "Pickup",
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF4E8C6F),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 32.0),
                                        child: Text(
                                          Provider.of<AppInfo>(context)
                                                      .userPickUpLocation !=
                                                  null
                                              ? Provider.of<AppInfo>(context)
                                                  .userPickUpLocation!
                                                  .locationName!
                                              : 'Pickup Location',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 32.0),
                                  child: Divider(
                                      height: 10.0,
                                      thickness: 0.5,
                                      color: Color(0xFFB9C7C0)),
                                ),
                                Container(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.location_pin,
                                            color: Color(0xFFA8CEB7),
                                            size: 30.0,
                                          ),
                                          Text(
                                            "Drop-off",
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF4E8C6F),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 32),
                                        child: Text(
                                          Provider.of<AppInfo>(context)
                                                      .userDropOffLocation !=
                                                  null
                                              ? Provider.of<AppInfo>(context)
                                                  .userDropOffLocation!
                                                  .locationName!
                                              : 'Drop-off location',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> drawPolyLineFromSourceToDestination() async {
    var sourcePosition =
        Provider.of<AppInfo>(context, listen: false).userPickUpLocation!;
    var destinationPosition =
        Provider.of<AppInfo>(context, listen: false).userDropOffLocation!;

    //originLatLng
    sourceLatLng = LatLng(
        sourcePosition.locationLatitude!, sourcePosition.locationLongitude!);

    print("this is the sourceLatLng :: $sourceLatLng");

    var destinationLatLng = LatLng(destinationPosition.locationLatitude!,
        destinationPosition.locationLongitude!);

    var directionDetailsInfo =
        await AssistantMethods.obtainOriginToDestinationDirectionDetails(
            sourceLatLng, destinationLatLng);
    setState(() {
      tripDrirectionDetailsInfo = directionDetailsInfo;
    });

    print("This is encoded points :: ");
    print(directionDetailsInfo!.e_points);

    PolylinePoints pPoints = PolylinePoints();
    List<PointLatLng> decodedPolyLinePointsResultList =
        pPoints.decodePolyline(directionDetailsInfo.e_points!);

    pLineCoordinatesList.clear();

    if (decodedPolyLinePointsResultList.isNotEmpty) {
      decodedPolyLinePointsResultList.forEach((PointLatLng pointLatLng) {
        pLineCoordinatesList
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }

    polyLineSet.clear();

    setState(() {
      Polyline polyline = Polyline(
        polylineId: const PolylineId("PolylineID"),
        color: Color(0XFF25ba6f),
        jointType: JointType.round,
        points: pLineCoordinatesList,
        width: 5,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );

      polyLineSet.add(polyline);
    });

    LatLngBounds boundLatLng;
    if (sourceLatLng.latitude > destinationLatLng.latitude &&
        sourceLatLng.longitude > destinationLatLng.longitude) {
      boundLatLng =
          LatLngBounds(southwest: destinationLatLng, northeast: sourceLatLng);
    } else if (sourceLatLng.longitude > destinationLatLng.longitude) {
      boundLatLng = LatLngBounds(
        southwest: LatLng(sourceLatLng.latitude, destinationLatLng.longitude),
        northeast: LatLng(destinationLatLng.latitude, sourceLatLng.longitude),
      );
    } else if (sourceLatLng.latitude > destinationLatLng.latitude) {
      boundLatLng = LatLngBounds(
        southwest: LatLng(destinationLatLng.latitude, sourceLatLng.longitude),
        northeast: LatLng(sourceLatLng.latitude, destinationLatLng.longitude),
      );
    } else {
      boundLatLng =
          LatLngBounds(southwest: sourceLatLng, northeast: destinationLatLng);
    }
    newGoogleMapController!
        .animateCamera(CameraUpdate.newLatLngBounds(boundLatLng, 70));

    BitmapDescriptor customIconDestination =
        await BitmapDescriptor.fromAssetImage(
            ImageConfiguration(devicePixelRatio: 2.5),
            'images/destination.png');

    Marker destinationMarker = Marker(
      markerId: const MarkerId("destinationID"),
      infoWindow: InfoWindow(
          title: destinationPosition.locationName, snippet: "Destination"),
      position: destinationLatLng,
      icon: customIconDestination,
    );

    Circle destinationCircle = Circle(
      circleId: const CircleId("destinationID"),
      fillColor: Color(0x225add6c),
      center: destinationLatLng,
      radius: 20,
      strokeWidth: 4,
      strokeColor: Color(0x22b0e5d9),
    );

    setState(() {
      markerSet.add(destinationMarker);
      circleSet.add(destinationCircle);
    });
  }
}
