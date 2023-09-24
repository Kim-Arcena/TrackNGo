import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' hide LocationAccuracy;
import 'package:provider/provider.dart';
import 'package:trackngo/assistants/assistant_methods.dart';
import 'package:trackngo/global/global.dart';
import 'package:trackngo/infoHandler/app_info.dart';
import 'package:trackngo/mainScreen/driver_screen.dart';
import 'package:trackngo/mainScreen/warningDialog.dart';
import 'package:trackngo/models/user_ride_request_information.dart';
import 'package:trackngo/push_notifications/push_notification_system.dart';
import 'package:trackngo/tabPages/earning_tab.dart';
import 'package:trackngo/tabPages/profile_tab.dart';

class DriverTripScreen extends StatefulWidget {
  final UserRideRequestInformation? userRideRequestDetails;

  const DriverTripScreen({Key? key, this.userRideRequestDetails})
      : super(key: key);

  @override
  State<DriverTripScreen> createState() => _DriverTripScreenState();
}

class _DriverTripScreenState extends State<DriverTripScreen>
    with SingleTickerProviderStateMixin {
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
  var driverCurrentPosition;
  Set<Marker> markerSet = {};
  Set<Circle> circleSet = {};
  Set<Marker> passengerMarkerSet = {};
  String statusText = "Now Offline";
  Color stateColor = Colors.grey;
  bool isDriverActive = false;
  TabController? tabController;
  int selectedIndex = 0;
  Position? onlineDriverCurrentPosition;
  BitmapDescriptor? iconAnimatedMarker;
  List<String> rideRequestStatus = List.generate(10, (index) => "accepted");
  String durationFromOriginToDestination = "";
  bool isRequestDirectionDetails = false;
  String statusTextButton = "Accepted";
  int indexChosen = -1;
  String? buttonTitle = "Arrived";
  Color? buttonColor = Colors.blue;

  onItemClicked(int index) {
    setState(() {
      selectedIndex = index;
      tabController!.index = index;
    });
  }

  void onItemSelected(int index) {
    if (index == 0) {
      // Check if the "Earnings" item is clicked (index 1)
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => DriverTripScreen()));
    } else if (index == 1) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => EarningsTabPage()));
    } else if (index == 2) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => ProfileTabPage()));
    } else {
      setState(() {
        selectedIndex = index;
      });
    }
  }

  readCurrentDriveInformation() async {
    DatabaseReference usersRef = FirebaseDatabase(
            databaseURL:
                "https://trackngo-d7aa0-default-rtdb.asia-southeast1.firebasedatabase.app/")
        .ref()
        .child("driver");
    usersRef.child(currentFirebaseUser!.uid).once().then((snap) {
      if (snap.snapshot.value != null) {
        print("the current firebase user is " + currentFirebaseUser!.uid);

        onlineDriverData.id = (snap.snapshot.value as Map)["id"];
        onlineDriverData.firstName = (snap.snapshot.value as Map)["firstName"];
        onlineDriverData.lastName = (snap.snapshot.value as Map)["lastName"];
        onlineDriverData.contactNumber =
            (snap.snapshot.value as Map)["contactNumber"];
        onlineDriverData.email = (snap.snapshot.value as Map)["email"];
        onlineDriverData.licenseNumber =
            (snap.snapshot.value as Map)["licenseNumber"];
        onlineDriverData.operatorId =
            (snap.snapshot.value as Map)["operatorId"];
        onlineDriverData.plateNumber =
            (snap.snapshot.value as Map)["plateNumber"];
        onlineDriverData.busType = (snap.snapshot.value as Map)["busType"];

        print("online driver data" + onlineDriverData.firstName.toString());
        print(onlineDriverData.lastName);
        print("online driver contactNumber" +
            onlineDriverData.contactNumber.toString());
      } else {
        print("online driver data is null");
      }
    });
    AssistantMethods.readTripsKeysForOnlineUser(context);

    PushNotificationSystem pushNotificationSystem = PushNotificationSystem();
    pushNotificationSystem.initializeCloudMessagin(context);
    pushNotificationSystem.generateAndGetToken();
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
        CameraPosition(
            target: _initialcameraposition,
            zoom: 19,
            tilt: 40,
            bearing: position.heading),
      ),
    );

    var currentPosition =
        Provider.of<AppInfo>(context, listen: false).userPickUpLocation!;

    //originLatLng
    driverCurrentPosition = LatLng(
        currentPosition.locationLatitude!, currentPosition.locationLongitude!);

    print(
        "this is the driverCurrentPosition int the _onMapCreated:: $driverCurrentPosition");

    var passengerPickUpLatLng = LatLng(
        currentPosition.locationLatitude!, currentPosition.locationLongitude!);
  }

  checkIfLocationPermissionGranted() async {
    _locationPermission = await Geolocator.requestPermission();
    if (_locationPermission == LocationPermission.denied) {
      _locationPermission = await Geolocator.requestPermission();
    }
  }

  createDriverIconMarker() {
    if (iconAnimatedMarker == null) {
      ImageConfiguration imageConfiguration =
          createLocalImageConfiguration(context, size: Size(2, 2));
      BitmapDescriptor.fromAssetImage(imageConfiguration, "images/driver.png")
          .then((value) {
        iconAnimatedMarker = value;
      });
    }
  }

  getDriversLocationUpdatesAtRealTime() {
    LatLng oldLatlng = LatLng(0, 0);

    streamSubscriptionDriverLivePosition =
        Geolocator.getPositionStream().listen((Position position) async {
      driverCurrentPosition = position;
      onlineDriverCurrentPosition = position;

      LatLng latLngLiveDriverPosition = LatLng(
          driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);

      Marker animatingMarker = Marker(
        markerId: MarkerId("animatingMarkerID"),
        position: latLngLiveDriverPosition,
        icon: iconAnimatedMarker!,
        infoWindow: InfoWindow(
            title: "Current Location",
            snippet: driverCurrentPosition!.toString()),
      );

      setState(() {
        CameraPosition cameraPosition = CameraPosition(
            target: latLngLiveDriverPosition,
            zoom: 16,
            tilt: 40,
            bearing: position.heading);
        newGoogleMapController!
            .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

        markerSet.removeWhere(
            (element) => element.markerId.value == "animatingMarkerID");
        markerSet.add(animatingMarker);
      });

      oldLatlng = latLngLiveDriverPosition;
      updateDurationTimeAtRealTime();
      Map driverLatLngMap = {
        "latitude": driverCurrentPosition!.latitude.toString(),
        "longitude": driverCurrentPosition!.longitude.toString(),
      };
    });
  }

  updateDurationTimeAtRealTime() async {
    if (isRequestDirectionDetails) {
      isRequestDirectionDetails = true;
      var originLatLng = LatLng(onlineDriverCurrentPosition!.latitude,
          onlineDriverCurrentPosition!.longitude);
      if (onlineDriverCurrentPosition == null) {
        return;
      }
      var destinationLatLng;
    }
    print("the accepted ride request list is " +
        acceptedRideRequestDetailsList.length.toString());
    for (int i = 0; i < acceptedRideRequestDetailsList.length; i++) {
      print("request origin location" +
          acceptedRideRequestDetailsList[i].originAddress!.toString() +
          "  " +
          i.toString());

      BitmapDescriptor passengerOriginMarkerIcon =
          await BitmapDescriptor.fromAssetImage(
              ImageConfiguration(size: Size(48, 48)), 'images/commuter.png');

      Marker passengerOriginMarker = Marker(
        markerId: MarkerId(
            "passenger" + i.toString()), // Use the index as the MarkerId
        position: acceptedRideRequestDetailsList[i].originLatLng!,
        icon: passengerOriginMarkerIcon,
        infoWindow: InfoWindow(
            title: acceptedRideRequestDetailsList[i].rideRequestId.toString(),
            snippet: "Origin"),
      );
      BitmapDescriptor passengerDestinationMarkerIcon =
          await BitmapDescriptor.fromAssetImage(
              ImageConfiguration(size: Size(10, 10)), 'images/Dropoff.png');

      Marker passengerDestinationMarker = Marker(
        markerId:
            MarkerId("pin" + i.toString()), // Use the index as the MarkerId
        position: acceptedRideRequestDetailsList[i].destinationLatLng!,
        icon: passengerDestinationMarkerIcon,
        infoWindow: InfoWindow(
            title: acceptedRideRequestDetailsList[i].rideRequestId.toString(),
            snippet: "Origin"),
      );
      setState(() {
        markerSet.add(passengerOriginMarker);
        markerSet.add(passengerDestinationMarker);
      });
    }
  }

  void initState() {
    super.initState();
    checkIfLocationPermissionGranted();

    readCurrentDriveInformation();
    getDriversLocationUpdatesAtRealTime();
    drawPolyLineFromSourceToDestination();
    tabController = TabController(length: 3, vsync: this);
  }

  List<bool> isInRoute = List.generate(
      10, (index) => false); //use acceptedRideRequestDetailsLists.length
  List<bool> isDropped = List.generate(10, (index) => false);

  @override
  Widget build(BuildContext context) {
    createDriverIconMarker();
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
                  myLocationEnabled: true,
                  markers: markerSet,
                  circles: circleSet,
                  polylines: polyLineSet,
                ),
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
                  initialChildSize: 0.4,
                  minChildSize: 0.4,
                  maxChildSize: 0.6,
                  builder: (BuildContext context,
                      ScrollController scrollController) {
                    return Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 25, horizontal: 15),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15.0),
                          topRight: Radius.circular(15.0),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 2,
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            "Passengers",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 12),
                              child: SingleChildScrollView(
                                controller: scrollController,
                                child: ListView.builder(
                                  itemCount:
                                      acceptedRideRequestDetailsList.length,
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    var rideRequest =
                                        acceptedRideRequestDetailsList[index];
                                    String originAddress =
                                        rideRequest.originAddress.toString();
                                    bool isLongText = originAddress.length > 20;
                                    return Container(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    AutoSizeText(
                                                      rideRequest.userFirstName
                                                              .toString() +
                                                          " " +
                                                          rideRequest
                                                              .userLastName
                                                              .toString(),
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                      maxLines: 3,
                                                      minFontSize: 10,
                                                    ),
                                                    SizedBox(height: 5.0),
                                                    FittedBox(
                                                      fit: BoxFit.scaleDown,
                                                      child: AutoSizeText(
                                                        rideRequest
                                                            .originAddress
                                                            .toString(),
                                                        style: TextStyle(
                                                            fontSize: 12.0),
                                                        maxLines: 2,
                                                        minFontSize: 10,
                                                        maxFontSize: 12,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15.0),
                                                  ),
                                                  fixedSize: Size(120, 35),
                                                  primary: isInRoute[index] &&
                                                          !isDropped[index]
                                                      ? Color(0xFF06A6D0)
                                                      : isInRoute[index] &&
                                                              isDropped[index]
                                                          ? Color(0xffEB565C)
                                                          : Color(0xFF2D9D69),
                                                ),
                                                onPressed: () {
                                                  if (rideRequestStatus[
                                                          index] ==
                                                      "accepted") {
                                                    FirebaseDatabase.instance
                                                        .ref()
                                                        .child(
                                                            "All Ride Requests")
                                                        .child(rideRequest
                                                            .rideRequestId
                                                            .toString())
                                                        .child(
                                                            "acceptedRideInfo")
                                                        .child("status")
                                                        .set("arrived");
                                                    setState(() {
                                                      isInRoute[index] =
                                                          !isInRoute[index];
                                                      indexChosen = index;
                                                      rideRequestStatus[index] =
                                                          "arrived";
                                                    });
                                                  } else if (rideRequestStatus[
                                                          index] ==
                                                      "arrived") {
                                                    FirebaseDatabase.instance
                                                        .ref()
                                                        .child(
                                                            "All Ride Requests")
                                                        .child(rideRequest
                                                            .rideRequestId
                                                            .toString())
                                                        .child(
                                                            "acceptedRideInfo")
                                                        .child("status")
                                                        .set("ontrip");
                                                    setState(() {
                                                      isDropped[index] =
                                                          !isDropped[index];
                                                      indexChosen = index;
                                                      rideRequestStatus[index] =
                                                          "ontrip";
                                                    });
                                                  } else {
                                                    FirebaseDatabase.instance
                                                        .ref()
                                                        .child(
                                                            "All Ride Requests")
                                                        .child(rideRequest
                                                            .rideRequestId
                                                            .toString())
                                                        .child(
                                                            "acceptedRideInfo")
                                                        .child("status")
                                                        .set("dropoff");
                                                    setState(() {
                                                      acceptedRideRequestDetailsList
                                                          .removeAt(index);
                                                    });
                                                    if (acceptedRideRequestDetailsList
                                                            .length ==
                                                        0) {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              MainScreen(),
                                                        ),
                                                      );
                                                    }
                                                  }
                                                },
                                                child: AutoSizeText(
                                                  isInRoute[index] &&
                                                          !isDropped[index]
                                                      ? "In Route"
                                                      : isInRoute[index] &&
                                                              isDropped[index]
                                                          ? "Drop Off"
                                                          : "Arrive",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  maxLines: 3,
                                                  minFontSize: 10,
                                                  maxFontSize: 12,
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
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(250),
                        topRight: Radius.circular(250),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 25.0,
                          offset: Offset(0, -15), // changes position of shadow
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                      child: SizedBox(
                        height: 90,
                        child: Material(
                          elevation: 10,
                          borderOnForeground: true,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Color(0xFF2D9D69),
                            ),
                            child: BottomNavigationBar(
                              items: [
                                BottomNavigationBarItem(
                                  icon: Container(
                                    height: 0,
                                    child: Icon(
                                      Icons.explore,
                                      size: 30,
                                    ),
                                  ),
                                  label: '',
                                ),
                                BottomNavigationBarItem(
                                  icon: Container(
                                    height: 0,
                                    child: Icon(
                                      Icons.wallet,
                                      size: 30,
                                    ),
                                  ),
                                  label: '',
                                ),
                                BottomNavigationBarItem(
                                  icon: Container(
                                    height: 0,
                                    child: Icon(
                                      Icons.person,
                                      size: 30,
                                    ),
                                  ),
                                  label: '',
                                ),
                              ],
                              unselectedItemColor: Color(0xFFe3efe7),
                              selectedItemColor: Colors.white,
                              backgroundColor: Color(0xFF2D9D69),
                              type: BottomNavigationBarType.fixed,
                              selectedLabelStyle:
                                  const TextStyle(fontWeight: FontWeight.bold),
                              showUnselectedLabels: true,
                              currentIndex: selectedIndex,
                              onTap: onItemSelected,
                            ),
                          ),
                        ),
                      ),
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

  Future<void> drawPolyLineFromSourceToDestination() async {
    var sourcePosition =
        Provider.of<AppInfo>(context, listen: false).userPickUpLocation!;

    //originLatLng
    sourceLatLng = LatLng(
        sourcePosition.locationLatitude!, sourcePosition.locationLongitude!);

    print("this is the sourceLatLng :: $sourceLatLng");

    var destinationLatLng = LatLng(10.720321, 122.562019);

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
            ImageConfiguration(size: Size(10, 10)), 'images/term.png');

    Marker destinationMarker = Marker(
      markerId: const MarkerId("destinationID"),
      position: destinationLatLng,
      icon: customIconDestination,
      infoWindow: InfoWindow(title: "Ungka Terminal 1"),
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

  driverIsOnlineNow() async {
    String pathToReference = "activeDrivers";

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    driverCurrentPosition = position;

    print("driverCurrentPosition" +
        driverCurrentPosition.latitude.toString() +
        " " +
        driverCurrentPosition.longitude.toString());

    Geofire.initialize(pathToReference);
    Geofire.setLocation(currentFirebaseUser!.uid,
        driverCurrentPosition.latitude, driverCurrentPosition.longitude);

    // ignore: deprecated_member_use
    DatabaseReference usersRef = FirebaseDatabase(
            databaseURL:
                "https://trackngo-d7aa0-default-rtdb.asia-southeast1.firebasedatabase.app/")
        .ref()
        .child("driver");
    usersRef.child(currentFirebaseUser!.uid).child("newRideStatus").set("idle");
    usersRef.onValue.listen((event) {});
  }
}

driverIsOfflineNow() {
  Geofire.removeLocation(currentFirebaseUser!.uid);
  // ignore: deprecated_member_use
  DatabaseReference? usersRef = FirebaseDatabase(
          databaseURL:
              "https://trackngo-d7aa0-default-rtdb.asia-southeast1.firebasedatabase.app/")
      .ref()
      .child("driver")
      .child(currentFirebaseUser!.uid)
      .child("newRideStatus");
  usersRef.onDisconnect();
  usersRef.remove();
  usersRef = null;

  Future.delayed(const Duration(seconds: 2), () {
    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  });
}
