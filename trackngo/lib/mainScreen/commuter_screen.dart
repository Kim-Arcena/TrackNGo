import 'dart:async';
import 'dart:math';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:location/location.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:trackngo/mainScreen/search_places_screen.dart';

import '../assistants/assistant_methods.dart';
import '../bottomSheet/first_bottom_sheet.dart';
import '../infoHandler/app_info.dart';

class CommuterScreen extends StatefulWidget {
  const CommuterScreen({Key? key});

  @override
  State<CommuterScreen> createState() => _CommuterScreenState();
}

class _CommuterScreenState extends State<CommuterScreen> {
  LatLng _initialcameraposition = LatLng(20.5937, 78.9629);
  final Completer<GoogleMapController> _controllerGoogleMap =
      Completer<GoogleMapController>();
  GoogleMapController? newGoogleMapController;
  Location _location = Location();
  LocationPermission? _locationPermission;
  String humanReadableAddress = "";
  Set<Marker> _markers = {};
  bool _bottomSheetVisible = true;

  List<LatLng> pLineCoordinatesList = [];
  Set<Polyline> polyLineSet = {};

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

    // Load the custom PNG image
    BitmapDescriptor customIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(48, 48)), 'images/commuter.png');

    // Update the map's markers to use the custom PNG icon
    setState(() {
      _markers.clear();
      _markers.add(Marker(
          markerId: MarkerId("current_location"),
          position: _initialcameraposition,
          icon: customIcon));
    });

    newGoogleMapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: _initialcameraposition, zoom: 25),
      ),
    );
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
            markers: _markers,
            polylines: polyLineSet,
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
                  onPressed: () {},
                  icon: Icon(Icons.qr_code_rounded),
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
                                    "Dropodddff",
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

    var sourceLatLng = LatLng(
        sourcePosition.locationLatitude!, sourcePosition.locationLongitude!);

    var destinationLatLng = LatLng(destinationPosition.locationLatitude!,
        destinationPosition.locationLongitude!);

    var directionDetailsInfo =
        await AssistantMethods.obtainOriginToDestinationDirectionDetails(
            sourceLatLng, destinationLatLng);

    Navigator.pop(context);

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
  }
}
