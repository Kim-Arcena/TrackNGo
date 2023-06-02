import 'dart:async';

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
import 'package:trackngo/mainScreen/search_places_screen.dart';
import 'package:trackngo/mainScreen/warningDialog.dart';
import 'package:trackngo/models/ride_ref_request_info.dart';

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
    );

    setState(() {
      markerSet.add(marker);
      _driverLocationMarker = marker;
    });
  }

  void initState() {
    super.initState();
    checkIfLocationPermissionGranted();
    listenToDriverLocationChanges();
    getDriversInformation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            initialCameraPosition:
                CameraPosition(target: _initialcameraposition, zoom: 20),
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
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 250,
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15.0),
                  topRight: Radius.circular(15.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  children: [
                    Text(
                      "Driver is on the way",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                width: 30,
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  AutoSizeText(
                                    '${chosenDriverInformation?.driverFirstName ?? 'First Name'} ${chosenDriverInformation?.driverLastName ?? 'Last Name'}',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 3,
                                    minFontSize: 10,
                                  ),
                                  SizedBox(
                                    height: 7,
                                  ),
                                  AutoSizeText(
                                    chosenDriverInformation?.busNumber ??
                                        'F4343',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                    ),
                                    maxLines: 1,
                                    minFontSize: 10,
                                  ),
                                  SizedBox(
                                    height: 3,
                                  ),
                                  AutoSizeText(
                                    chosenDriverInformation
                                            ?.driverContactNumber ??
                                        '09473582942',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                    ),
                                    maxLines: 1,
                                    minFontSize: 10,
                                  ),
                                  SizedBox(
                                    height: 3,
                                  ),
                                  AutoSizeText(
                                    chosenDriverInformation?.busType ??
                                        'Air-Conditioned',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
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
                    ),
                  ],
                ),
              ),
            ),
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
