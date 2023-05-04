import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' hide LocationAccuracy;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:trackngo/assistants/assistant_methods.dart';
import 'package:trackngo/global/global.dart';
import 'package:trackngo/infoHandler/app_info.dart';
import 'package:location/location.dart' as loc;

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

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
  var driverCurrentPosition;
  Set<Marker> markerSet = {};
  Set<Circle> circleSet = {};

  String statusText = "Now Offline";
  Color stateColor = Colors.grey;
  bool isDriverActive = false;

  TabController? tabController;
  int selectedIndex = 0;
  onItemClicked(int index) {
    setState(() {
      selectedIndex = index;
      tabController!.index = index;
    });
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
        ImageConfiguration(size: Size(48, 48)), 'images/commuter.png');

    Marker originMarker = Marker(
      markerId: const MarkerId("originID"),
      infoWindow:
          InfoWindow(title: currentPosition.locationName, snippet: "Origin"),
      position: driverCurrentPosition,
      icon: customIconOrigin,
    );

    Circle originCircle = Circle(
      circleId: const CircleId("originID"),
      fillColor: Color(0x225add6c),
      center: driverCurrentPosition,
      radius: 25,
      strokeWidth: 4,
      strokeColor: Color(0x225add6c),
    );

    setState(() {
      markerSet.add(originMarker);
      circleSet.add(originCircle);
    });
  }

  StreamSubscription<Position>? streamStreamSubscription;

  checkIfLocationPermissionGranted() async {
    _locationPermission = await Geolocator.requestPermission();
    if (_locationPermission == LocationPermission.denied) {
      _locationPermission = await Geolocator.requestPermission();
    }
  }

  void initState() {
    super.initState();
    checkIfLocationPermissionGranted();
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
                          driverIsOnlineNow();
                          updateDriversLocationAtRealTime();
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
                                onTap: () {},
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
        .child("users");
    usersRef
        .child(currentFirebaseUser!.uid)
        .child("drivers_child")
        .child("newRideStatus")
        .set("idle");
    usersRef.onValue.listen((event) {});
  }

  updateDriversLocationAtRealTime() {
    streamStreamSubscription =
        Geolocator.getPositionStream().listen((Position position) {
      driverCurrentPosition = position;
      if (isDriverActive == true) {
        Geofire.setLocation(currentFirebaseUser!.uid,
            driverCurrentPosition.latitude, driverCurrentPosition.longitude);
      }
      LatLng latLng = LatLng(
          driverCurrentPosition.latitude, driverCurrentPosition.longitude);

      newGoogleMapController!.animateCamera(CameraUpdate.newLatLng(latLng));
    });
  }
}