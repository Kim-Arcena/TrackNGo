import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' hide LocationAccuracy;
import 'package:provider/provider.dart';
import 'package:trackngo/assistants/geofire_assistant.dart';
import 'package:trackngo/authentication/signup_screen.dart';
import 'package:trackngo/global/global.dart';
import 'package:trackngo/mainScreen/search_places_screen.dart';
import 'package:trackngo/models/active_nearby_available_drivers.dart';

import '../assistants/assistant_methods.dart';
import '../bottomSheet/first_bottom_sheet.dart';
import '../infoHandler/app_info.dart';
import '../splashScreen/splash_screen.dart';

class CommuterScreen extends StatefulWidget {
  const CommuterScreen({Key? key});

  @override
  State<CommuterScreen> createState() => _CommuterScreenState();

  static _CommuterScreenState? of(BuildContext context) {
    return context.findAncestorStateOfType<_CommuterScreenState>();
  }
}

class _CommuterScreenState extends State<CommuterScreen> {
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
  var sourceLatLng;
  var userCurrentPosition;
  Set<Marker> markerSet = {};
  Set<Circle> circleSet = {};

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
        CameraPosition(target: _initialcameraposition, zoom: 25),
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
        ImageConfiguration(size: Size(48, 48)), 'images/commuter.png');

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

    initializeGeoFireListener();
  }

  checkIfLocationPermissionGranted() async {
    _locationPermission = await Geolocator.requestPermission();
    if (_locationPermission == LocationPermission.denied) {
      _locationPermission = await Geolocator.requestPermission();
    }
  }

  void initState() {
    super.initState();
    checkIfLocationPermissionGranted();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition:
                CameraPosition(target: _initialcameraposition),
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
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MySplashScreen()),
                    );
                  },
                  icon: Icon(
                    Icons.logout,
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
          Align(
            alignment: Alignment.bottomCenter,
            child: MyBottomSheet(
              child: Container(
                height: 30,
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
            ImageConfiguration(size: Size(48, 48)), 'images/driver.png');

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

  initializeGeoFireListener() async {
    Geofire.initialize("activeDrivers");

    currentPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    userCurrentPosition = currentPosition;

    Geofire.queryAtLocation(
            userCurrentPosition!.latitude, userCurrentPosition!.longitude, 5)!
        .listen((map) {
      print(map);
      if (map != null) {
        var callBack = map['callBack'];

        //latitude will be retrieved from map['latitude']
        //longitude will be retrieved from map['longitude']

        switch (callBack) {
          case Geofire.onKeyEntered: //when a key enters the radius
            ActiveNearbyAvailableDrivers activeNearbyAvailableDriver =
                ActiveNearbyAvailableDrivers();

            activeNearbyAvailableDriver.locationLatitude = map['latitude'];
            activeNearbyAvailableDriver.locationLongitude = map['longitude'];
            activeNearbyAvailableDriver.driverId = map['key'];
            GeoFireAssistant.activeNearbyAvailableDriversList
                .add(activeNearbyAvailableDriver);

            if (activeNearbyAvailableDriversKeysLoaded == true) {
              displayActiveDriversOnMap();
            }

            break;

          case Geofire.onKeyExited: //when a key exits the radius
            GeoFireAssistant.deleteOfflineDriverFromList(map['key']);
            displayActiveDriversOnMap();
            break;

          case Geofire.onKeyMoved: //when a key moves within the radius
            ActiveNearbyAvailableDrivers activeNearbyAvailableDriver =
                ActiveNearbyAvailableDrivers();

            activeNearbyAvailableDriver.locationLatitude = map['latitude'];
            activeNearbyAvailableDriver.locationLongitude = map['longitude'];
            activeNearbyAvailableDriver.driverId = map['key'];

            GeoFireAssistant.updateActiveNearbyAvailableDriverLocation(
                activeNearbyAvailableDriver);
            displayActiveDriversOnMap();
            break;

          //when the query is ready to load
          case Geofire.onGeoQueryReady:
            displayActiveDriversOnMap();
            print(map['result']);
            displayActiveDriversOnMap();
            break;
        }
      }

      setState(() {});
    });
  }

  displayActiveDriversOnMap() async {
    Set<Marker> driverMarkerSet = Set<Marker>();

    for (ActiveNearbyAvailableDrivers eachDriver
        in GeoFireAssistant.activeNearbyAvailableDriversList) {
      LatLng eachDriverActivePosition =
          LatLng(eachDriver.locationLatitude!, eachDriver.locationLongitude!);

      BitmapDescriptor busIcon = await BitmapDescriptor.fromAssetImage(
          ImageConfiguration(size: Size(8, 8)), 'images/bus.png');

      Marker driverMarker = Marker(
        markerId: MarkerId(eachDriver.driverId!),
        position: eachDriverActivePosition,
        icon: busIcon,
        rotation: 360,
      );

      driverMarkerSet.add(driverMarker);
    }

    setState(() {
      // add the driver markers to the existing marker set
      markerSet.addAll(driverMarkerSet);
    });
  }
}
