import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:trackngo/models/user_ride_request_information.dart';

import '../assistants/assistant_methods.dart';
import '../infoHandler/app_info.dart';

class NewTripScreen extends StatefulWidget {
  UserRideRequestInformation? userRideRequestDetails;
  NewTripScreen({this.userRideRequestDetails});

  @override
  State<NewTripScreen> createState() => _NewTripScreenState();
}

class _NewTripScreenState extends State<NewTripScreen> {
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
  var driverCurrentPosition;
  Set<Marker> markerSet = {};
  Set<Circle> circleSet = {};

  String statusText = "Now Offline";
  Color stateColor = Colors.grey;
  bool isDriverActive = false;

  TabController? tabController;
  int selectedIndex = 0;
  String? buttonTitle = "Arrive";
  Color? buttonColor = Color(0xFF199A5D);

  checkIfLocationPermissionGranted() async {
    _locationPermission = await Geolocator.requestPermission();
    if (_locationPermission == LocationPermission.denied) {
      _locationPermission = await Geolocator.requestPermission();
    }
  }

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
        CameraPosition(target: _initialcameraposition, zoom: 25),
      ),
    );

    var currentPosition =
        Provider.of<AppInfo>(context, listen: false).userPickUpLocation!;

    //originLatLng
    driverCurrentPosition = LatLng(
        currentPosition.locationLatitude!, currentPosition.locationLongitude!);

    print(
        "this is the driverCurrentPosition int the _onMapCreated:: $driverCurrentPosition");

    // Load the custom PNG image
    BitmapDescriptor customIconOrigin = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(48, 48)), 'images/driver.png');

    Marker originMarker = Marker(
      markerId: const MarkerId("originID"),
      infoWindow:
          InfoWindow(title: currentPosition.locationName, snippet: "Origin"),
      position: driverCurrentPosition,
      icon: customIconOrigin,
    );

    Circle originCircle = Circle(
      circleId: const CircleId("originID"),
      fillColor: Color(0x22e0c67f),
      center: driverCurrentPosition,
      radius: 25,
      strokeWidth: 4,
      strokeColor: Color(0x22e0c67f),
    );

    setState(() {
      markerSet.add(originMarker);
      circleSet.add(originCircle);
    });
  }

  getUserRequestList() async {
    // Create a DatabaseReference to the driver child node
    DatabaseReference driverRef = FirebaseDatabase.instance
        .reference()
        .child('driver')
        .child('currentFirebaseUser!.uid');

// Listen for changes to the newRideStatus list
    // driverRef.child('newRideStatus').onValue.listen((event) {
    //   // Retrieve the newRideStatus list from the event snapshot
    //   List<dynamic> newRideStatus = event.snapshot.value;

    //   // Access the values within the newRideStatus list
    //   if (newRideStatus != null) {
    //     newRideStatus.forEach((value) {
    //       // Do something with each value in the newRideStatus list
    //       print(value);
    //     });
    //   }
    // });
  }

  void initState() {
    super.initState();
    checkIfLocationPermissionGranted();
    getUserRequestList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition:
                      CameraPosition(target: _initialcameraposition),
                  mapType: MapType.normal,
                  onMapCreated: _onMapCreated,
                  myLocationEnabled: false,
                  markers: markerSet,
                  circles: circleSet,
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 270,
                    padding: EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15.0),
                        topRight: Radius.circular(15.0),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          "Passengers",
                          style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                        SingleChildScrollView(
                          child: ListView.builder(
                            itemCount: 1,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              return Container(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "item['name']",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18.0,
                                              ),
                                            ),
                                            SizedBox(height: 5.0),
                                            Text(
                                              'Location: ${['minutesAway']}',
                                              style: TextStyle(fontSize: 16.0),
                                            ),
                                            SizedBox(height: 5.0),
                                          ],
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                            fixedSize: Size(100, 35),
                                            primary: buttonColor, // background
                                          ),
                                          onPressed: () {},
                                          child: Text(
                                            "Arrived",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
