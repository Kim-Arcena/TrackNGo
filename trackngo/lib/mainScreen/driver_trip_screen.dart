import 'dart:async';

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
import 'package:trackngo/models/user_ride_request_information.dart';
import 'package:trackngo/push_notifications/push_notification_system.dart';

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
  List<String> rideRequestStatus = List.generate(3, (index) => "accepted");
  String durationFromOriginToDestination = "";
  bool isRequestDirectionDetails = false;
  String statusTextButton = "Accepted";
  int indexChosen = -1;
  String? buttonTitle = "Arrived";
  Color? buttonColor = Colors.blue;

  List<UserRideRequestInformation> acceptedRideRequestDetailsLists = [
    UserRideRequestInformation(
      originAddress: "123 Main Street",
      rideRequestId: "1",
      userFirstName: "John",
      userLastName: "Doe",
      userContactNumber: "1234567890",
    ),
    UserRideRequestInformation(
      originAddress: "456 Elm Street",
      rideRequestId: "2",
      userFirstName: "Jane",
      userLastName: "Smith",
      userContactNumber: "9876543210",
    ),
    UserRideRequestInformation(
      originAddress: "456 Elm Street",
      rideRequestId: "3",
      userFirstName: "Myrt",
      userLastName: "Myrt",
      userContactNumber: "9876543230",
    ),
  ];

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
        CameraPosition(target: _initialcameraposition, zoom: 19),
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
        infoWindow: InfoWindow(title: "Current Location"),
      );

      setState(() {
        CameraPosition cameraPosition =
            CameraPosition(target: latLngLiveDriverPosition, zoom: 16);
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
      3, (index) => false); //use acceptedRideRequestDetailsLists.length
  List<bool> isDropped = List.generate(3, (index) => false);

  @override
  Widget build(BuildContext context) {
    createDriverIconMarker();
    return Scaffold(
      body: Positioned(
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
                      var rideRequest = acceptedRideRequestDetailsList[index];

                      return Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      rideRequest.userFirstName.toString() +
                                          " " +
                                          rideRequest.userLastName.toString(),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17.0,
                                      ),
                                    ),
                                    SizedBox(height: 5.0),
                                    Text(
                                      rideRequest.originAddress.toString(),
                                      style: TextStyle(fontSize: 13.0),
                                    ),
                                    SizedBox(height: 5.0),
                                  ],
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                    fixedSize: Size(120, 35),
                                    primary: isInRoute[index] &&
                                            !isDropped[index]
                                        ? Colors.blue
                                        : isInRoute[index] && isDropped[index]
                                            ? Colors.redAccent
                                            : Colors.lightGreen,
                                  ),
                                  onPressed: () {
                                    if (rideRequestStatus[index] ==
                                        "accepted") {
                                      setState(() {
                                        isInRoute[index] = !isInRoute[index];
                                        indexChosen = index;
                                        rideRequestStatus[index] = "arrived";
                                      });
                                    } else if (rideRequestStatus[index] ==
                                        "arrived") {
                                      setState(() {
                                        isDropped[index] = !isDropped[index];
                                        indexChosen = index;
                                        rideRequestStatus[index] = "ontrip";
                                      });
                                    }
                                  },
                                  child: Text(
                                    isInRoute[index] && !isDropped[index]
                                        ? "In Route"
                                        : isInRoute[index] && isDropped[index]
                                            ? "Dropped Off"
                                            : "Accepted",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
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
            ],
          ),
        ),
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
            ImageConfiguration(size: Size(10, 10)), 'images/terminal.png');

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
