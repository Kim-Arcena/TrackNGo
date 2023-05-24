import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' hide LocationAccuracy;
import 'package:provider/provider.dart';
import 'package:trackngo/assistants/assistant_methods.dart';
import 'package:trackngo/global/global.dart';
import 'package:trackngo/infoHandler/app_info.dart';
import 'package:trackngo/models/user_ride_request_information.dart';
import 'package:trackngo/push_notifications/push_notification_system.dart';

class MainScreen extends StatefulWidget {
  final UserRideRequestInformation? userRideRequestDetails;

  const MainScreen({Key? key, this.userRideRequestDetails}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
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
  String? buttonTitle = "Arrive";
  Color? buttonColor = Color(0xFF199A5D);
  String statusText = "Now Offline";
  Color stateColor = Colors.grey;
  bool isDriverActive = false;
  TabController? tabController;
  int selectedIndex = 0;
  Position? onlineDriverCurrentPosition;
  BitmapDescriptor? iconAnimatedMarker;

  onItemClicked(int index) {
    setState(() {
      selectedIndex = index;
      tabController!.index = index;
    });
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

    PushNotificationSystem pushNotificationSystem = PushNotificationSystem();
    pushNotificationSystem.initializeCloudMessagin(context);
    pushNotificationSystem.generateAndGetToken();
  }

  void saveAssignedDriverDetailsToUserRideRequest() {
    print("saveAssignedDriverDetailsToUserRideRequest" +
        widget.userRideRequestDetails.toString());
    // if (widget.userRideRequestDetails != null &&
    //     widget.userRideRequestDetails!.rideRequestId != null) {
    //   DatabaseReference databaseReference = FirebaseDatabase.instance
    //       .ref()
    //       .child("All Ride Requests")
    //       .child(widget.userRideRequestDetails!.rideRequestId!);

    //   print("widget.userRideRequestDetails!.rideRequestId! " +
    //       widget.userRideRequestDetails!.rideRequestId!);

    //   Map driverLocationDataMap = {
    //     "latitude": driverCurrentPosition!.latitude,
    //     "longitude": driverCurrentPosition!.longitude
    //   };

    //   databaseReference.child("driverLocation").set(driverLocationDataMap);
    //   databaseReference.child("status").set("accepted");
    //   databaseReference.child("driverId").set(onlineDriverData.id);
    //   databaseReference
    //       .child("driverFirstName")
    //       .set(onlineDriverData.firstName);
    //   databaseReference.child("driverLastName").set(onlineDriverData.lastName);
    //   databaseReference
    //       .child("driverContactNumber")
    //       .set(onlineDriverData.contactNumber);
    //   databaseReference.child("driverBusType").set(onlineDriverData.busType);
    // }
    // // print("saveAssignedDriverDetailsToUserRideRequest");
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

    var passengerPickUpLatLng = LatLng(
        currentPosition.locationLatitude!, currentPosition.locationLongitude!);

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

  checkIfLocationPermissionGranted() async {
    _locationPermission = await Geolocator.requestPermission();
    if (_locationPermission == LocationPermission.denied) {
      _locationPermission = await Geolocator.requestPermission();
    }
  }

  void initState() {
    super.initState();
    checkIfLocationPermissionGranted();

    readCurrentDriveInformation();
    updateDriversLocationAtRealTime();
    drawPolyLineFromSourceToDestination();
    saveAssignedDriverDetailsToUserRideRequest();
    tabController = TabController(length: 3, vsync: this);
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
                  myLocationEnabled: true,
                  markers: markerSet,
                  circles: circleSet,
                  polylines: polyLineSet,
                ),
                statusText != "Now Online"
                    ? Container(
                        height: MediaQuery.of(context).size.height,
                        width: double.infinity,
                        color: Colors.black.withOpacity(0.5),
                      )
                    : Container(),
                Positioned(
                  top: statusText != "Now Online"
                      ? MediaQuery.of(context).size.height / 2 - 50
                      : 80,
                  left: statusText != "Now Online"
                      ? MediaQuery.of(context).size.width / 2 - 50
                      : 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: statusText == "Now Online"
                              ? EdgeInsets.all(15)
                              : null,
                          primary: statusText != "Now Online"
                              ? Color(0xFF228348)
                              : Colors.transparent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25.0)),
                          elevation: 0,
                        ),
                        onPressed: () {
                          if (isDriverActive != true) {
                            driverIsOnlineNow();
                            updateDriversLocationAtRealTime();
                            drawPolyLineFromSourceToDestination();

                            setState(() {
                              stateColor = Color(0xFF228348);
                              statusText = "Now Online";
                              isDriverActive = true;
                            });
                            Fluttertoast.showToast(msg: "You are online now");
                          } else {
                            // driverIsOfflineNow();
                            setState(() {
                              stateColor = Colors.grey;
                              statusText = "Now Offline";
                              isDriverActive = false;
                            });
                          }
                        },
                        child: statusText != "Now Online"
                            ? Text(
                                "Go Onlinee",
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white),
                              )
                            : InkResponse(
                                enableFeedback:
                                    false, // Set enableFeedback to false to remove the ripple effect
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    color: Color(0xFF73AD90),
                                  ),
                                  child: Icon(
                                    Icons.logout,
                                    color: Colors.white,
                                  ),
                                ),
                                onTap: () {
                                  driverIsOfflineNow();
                                  setState(() {
                                    stateColor = Colors.grey;
                                    statusText = "Now Offline";
                                    isDriverActive = false;
                                  });
                                },
                              ),
                      ),
                    ],
                  ),
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
                            color: statusText != "Now Online"
                                ? Color(0xFF494949)
                                : Color(0xffd4dbdd),
                            blurRadius: 10,
                            spreadRadius: 2,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: () {},
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
                        onPressed: () {},
                        icon: Icon(
                          Icons.location_on_sharp,
                        ),
                      ),
                    )),
                Positioned(
                  bottom: 75,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 250,
                    padding: EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15.0),
                        topRight: Radius.circular(15.0),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
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
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Expanded(
                          child:
                              // Add your scrollable content here
                              // Example:
                              SingleChildScrollView(
                            child: ListView.builder(
                              itemCount: acceptedRideRequestDetailsList.length,
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                // Access the current ride request object from the list
                                var rideRequest =
                                    acceptedRideRequestDetailsList[index];

                                return Container(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                                rideRequest.userFirstName
                                                        .toString() +
                                                    " " +
                                                    rideRequest.userLastName
                                                        .toString(),
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 17.0,
                                                ),
                                              ),
                                              SizedBox(height: 5.0),
                                              Text(
                                                rideRequest.originAddress
                                                    .toString(),
                                                style:
                                                    TextStyle(fontSize: 13.0),
                                              ),
                                              SizedBox(height: 5.0),
                                            ],
                                          ),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(15.0),
                                              ),
                                              fixedSize: Size(100, 35),
                                              primary:
                                                  buttonColor, // background
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

                              // ...
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
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
                          child: BottomNavigationBar(
                            items: const [
                              BottomNavigationBarItem(
                                icon: Icon(Icons.explore),
                                label: 'Home',
                              ),
                              BottomNavigationBarItem(
                                icon: Icon(Icons.attach_money),
                                label: 'Earnings',
                              ),
                              BottomNavigationBarItem(
                                icon: Icon(Icons.settings),
                                label: 'Settings',
                              ),
                            ],
                            unselectedItemColor: Color(0xFF7c7c7c),
                            selectedItemColor: Color(0xFF4E8C6F),
                            backgroundColor: Color.fromARGB(255, 240, 255, 244),
                            type: BottomNavigationBarType.fixed,
                            selectedLabelStyle:
                                const TextStyle(fontWeight: FontWeight.bold),
                            showUnselectedLabels: true,
                            currentIndex: selectedIndex,
                            onTap: onItemClicked,
                            elevation: 22,
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

    var destinationLatLng = LatLng(11.722, 122.096);

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
    usersRef
        .child(currentFirebaseUser!.uid)
        .child("newRideStatus")
        .set("idldde");
    usersRef.onValue.listen((event) {});
  }

  updateDriversLocationAtRealTime() {
    streamStreamSubscription =
        Geolocator.getPositionStream().listen((Position position) {
      driverCurrentPosition = position;
      onlineDriverCurrentPosition = driverCurrentPosition;
      if (isDriverActive == true) {
        Geofire.setLocation(currentFirebaseUser!.uid,
            driverCurrentPosition.latitude, driverCurrentPosition.longitude);
      }
      LatLng latLng = LatLng(
          driverCurrentPosition.latitude, driverCurrentPosition.longitude);

      Marker animatingMarker = Marker(
          markerId: MarkerId("animatedMarker"),
          position: latLng,
          icon: iconAnimatedMarker!,
          infoWindow: InfoWindow(title: "Current Location"));

      setState(() {
        CameraPosition cameraPosition =
            CameraPosition(target: latLng, zoom: 14);
        newGoogleMapController!
            .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

        markerSet.removeWhere(
            (element) => element.markerId.value == "animatedMarker");
        markerSet.add(animatingMarker);
      });
    });
  }

  createdActiveNearbyDriverIconMarker() async {
    if (markerSet.isNotEmpty) {
      // BitmapDescriptor iconAnimatedMarker = await BitmapDescriptor.fromAssetImage(
      //   ImageConfiguration(size: Size(48, 48)), 'images/driver.png');
      ImageConfiguration imageConfiguration =
          createLocalImageConfiguration(context, size: Size(2, 2));
      BitmapDescriptor.fromAssetImage(imageConfiguration, 'images/driver.png')
          .then((value) {
        iconAnimatedMarker = value;
      });
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
}
