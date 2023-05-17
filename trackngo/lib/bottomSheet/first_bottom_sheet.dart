import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:trackngo/assistants/geofire_assistant.dart';
import 'package:trackngo/bottomSheet/fourth_bottom_sheet.dart';
import 'package:trackngo/bottomSheet/second_bottom_sheet.dart';
import 'package:trackngo/bottomSheet/third_bottom_sheet.dart';
import 'package:trackngo/main.dart';
import 'package:trackngo/mainScreen/commuter_screen.dart';
import 'package:trackngo/models/active_nearby_available_drivers.dart';
import '../global/global.dart';
import '../infoHandler/app_info.dart';
import '../mainScreen/search_places_screen.dart';

var maxChildSize = 0.8;

class MyBottomSheet extends StatefulWidget {
  final Widget child;

  const MyBottomSheet({required this.child});

  @override
  _MyBottomSheetState createState() => _MyBottomSheetState();

  void moveToPage(int i) {}
}

class _MyBottomSheetState extends State<MyBottomSheet> {
  final PageController _pageController = PageController(initialPage: 0);

  void moveToPage(int page) {
    _pageController.animateToPage(page,
        duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.2,
      minChildSize: 0.2,
      maxChildSize: 0.8,
      builder: (BuildContext context, ScrollController scrollController) {
        return PageView(
          controller: _pageController,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0XFF358855),
                    Color(0XFF247D47),
                    Color(0XFF1C9B4E),
                    Color(0XFF358855),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: ListView(
                padding: EdgeInsets.zero,
                controller: scrollController,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 40.0, top: 40.0, right: 40, bottom: 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Create Trip",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Container(
                          child: CustomPaint(
                            painter: DottedLinePainter(),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: 40.0,
                                  height: 40.0,
                                  decoration: BoxDecoration(
                                    color: Color(0XFFDFF1E9),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: TextButton(
                                    onPressed: () {},
                                    child: Text(
                                      "1",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 40.0,
                                  height: 40.0,
                                  decoration: BoxDecoration(
                                    color: Color(0XFF021C0F),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: TextButton(
                                    onPressed: () {
                                      // Move to MyBottomSheetTwoContainer
                                      // moveToPage(1);
                                    },
                                    child: Text(
                                      "2",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 40.0,
                                  height: 40.0,
                                  decoration: BoxDecoration(
                                    color: Color(0XFF021C0F),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: TextButton(
                                    onPressed: () {},
                                    child: Text(
                                      "3",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 40.0,
                                  height: 40.0,
                                  decoration: BoxDecoration(
                                    color: Color(0XFF021C0F),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: TextButton(
                                    onPressed: () {},
                                    child: Text(
                                      "4",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  //add another container box here
                  InnerContainer(moveToPage),
                ],
              ),
            ),
            MyBottomSheetTwoContainer(
                scrollController: scrollController, moveToPage: moveToPage),
            MyBottomSheetThreeContainer(
                scrollController: scrollController, moveToPage: moveToPage),
            MyBottomSheetFourContainer(
                scrollController: scrollController, moveToPage: moveToPage),
          ],
        );
      },
    );
  }
}

class InnerContainer extends StatefulWidget {
  final void Function(int page) moveToPage;

  InnerContainer(this.moveToPage);

  @override
  _InnerContainerState createState() => _InnerContainerState();
}

class _InnerContainerState extends State<InnerContainer> {
  bool _flag = false;
  bool _flagTwo = false;
  bool _flagThree = false;
  List<ActiveNearbyAvailableDrivers> onlineNearByAvailableDriversList = [];
  DatabaseReference? referenceRideRequestRef;

  void onTap() async {
    var commuterScreenState = CommuterScreen.of(context);
    if (commuterScreenState != null) {
      await commuterScreenState.drawPolyLineFromSourceToDestination();
    }
  }

  saveRideRequestInformation() async {
    referenceRideRequestRef =
        FirebaseDatabase.instance.ref().child("All Ride Requests").push();
    final usersRef = FirebaseDatabase(
      databaseURL:
          "https://trackngo-d7aa0-default-rtdb.asia-southeast1.firebasedatabase.app/",
    ).ref().child("users");

    final currentUserCommuteRef =
        usersRef.child(currentFirebaseUser!.uid).child("commuters_child");

    final snapshot = await currentUserCommuteRef.get();

    final data =
        json.decode(json.encode(snapshot.value)) as Map<String, dynamic>?;
    if (data != null) {
      final firstName = data['firstName'];
      final lastName = data['lastName'];
      final contactNumber = data['contactNumber'];
      // do something with firstName and lastName
    } else {
      // handle the case where the snapshot or its value is null
    }

    print(snapshot.value);

    var originLocation =
        Provider.of<AppInfo>(context, listen: false).userPickUpLocation;
    var destinatinoLocation =
        Provider.of<AppInfo>(context, listen: false).userDropOffLocation;

    Map originLocationMap = {
      "latitude": originLocation!.locationLatitude.toString(),
      "longitude": originLocation!.locationLongitude.toString(),
    };
    Map destinationLocationMap = {
      "latitude": destinatinoLocation!.locationLatitude.toString(),
      "longitude": destinatinoLocation!.locationLongitude.toString(),
    };

    Map userInformationMap = {
      "origin": originLocationMap,
      "destination": destinationLocationMap,
      "time": DateTime.now().toString(),
      "userFirstName": data?['firstName'],
      "userLastName": data?['lastName'],
      "userContact": data?['contactNumber'],
      "originAddress": originLocation?.locationName ?? "",
      "destinationAddress": destinatinoLocation?.locationName ?? "",
      "driverId": "waiting",
    };

    print(userInformationMap);
    referenceRideRequestRef!.set(userInformationMap);

    onlineNearByAvailableDriversList =
        GeoFireAssistant.activeNearbyAvailableDriversList;

    searchNearestOnlineDrivers();
  }

  searchNearestOnlineDrivers() async {
    if (onlineNearByAvailableDriversList.length == 0) {
      Fluttertoast.showToast(msg: "No drivers found nearby");
      referenceRideRequestRef!.remove();
      return;

      // ignore: dead_code
      Future.delayed(Duration(seconds: 4), () {
        SystemNavigator.pop();
      });
    }

    await retrieveOnlineDriversInformation(onlineNearByAvailableDriversList);
    print("dList length is" + dList.length.toString());
    widget.moveToPage(1);
  }

  retrieveOnlineDriversInformation(List onlineNearestDriversList) async {
    DatabaseReference driverRef =
        FirebaseDatabase.instance.ref().child("driver");
    print("driver ref" + driverRef.toString());
    dList.clear();
    print("online nearest drivers list" +
        onlineNearByAvailableDriversList.length.toString());
    print(onlineNearestDriversList.length
        .toString()); // create a Set to store unique license numbers

    for (int i = 0; i < onlineNearestDriversList.length; i++) {
      await driverRef
          .child(onlineNearestDriversList[i].driverId.toString())
          .once()
          .then((dataSnapshot) {
        var driverKeyInfo = dataSnapshot.snapshot.value;

        dList.add(driverKeyInfo); // add the driver to the list
        // add the license number to the Set
        print("driver information" + driverKeyInfo.toString());
      });
    }

    print(dList.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: maxChildSize * MediaQuery.of(context).size.height * 0.735,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    "Trip",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Change",
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 55,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.only(top: 20, left: 40, right: 40),
              child: Column(
                children: <Widget>[
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
                            color: Color(0xFF4E8C6F)),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 30.0),
                    child: Text(
                      Provider.of<AppInfo>(context).userPickUpLocation != null
                          ? Provider.of<AppInfo>(context)
                              .userPickUpLocation!
                              .locationName!
                          : 'Pickup Location',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 30.0),
                    child: Divider(
                      height: 20.0,
                      thickness: 2.0,
                      color: Colors.grey[300],
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.location_pin,
                        color: Color(0xFFA8CEB7),
                        size: 30.0,
                      ),
                      Text(
                        "Dropoff",
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4E8C6F)),
                      ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 30.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SearchPlacesScreen(),
                              )).then((result) {
                            var commuterScreenState =
                                CommuterScreen.of(context);
                            commuterScreenState
                                ?.drawPolyLineFromSourceToDestination();
                          });
                        },
                        child: Text(
                          Provider.of<AppInfo>(context).userDropOffLocation !=
                                  null
                              ? Provider.of<AppInfo>(context)
                                  .userDropOffLocation!
                                  .locationName!
                              : 'Select a dropoff location',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Divider(
                      height: 40.0, thickness: 2.0, color: Color(0xFF929895)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Seats",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.people_alt_rounded,
                                  size: 24.0, color: Color(0xFF021C0F)),
                              SizedBox(
                                width: 5.0,
                              ),
                              Text(
                                "Seats Needed",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    // use setState
                                    _flag = true;
                                    _flagTwo = false;
                                    _flagThree = false;
                                  });
                                  print('clicked');
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  width: 30.0,
                                  height: 30.0,
                                  decoration: BoxDecoration(
                                    color: _flag
                                        ? Color(0xFF7d9988)
                                        : Color(0XFFDAD9E2),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: Text(
                                    "1",
                                    style: TextStyle(
                                      color:
                                          _flag ? Colors.white : Colors.black,
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 5.0,
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    // use setState
                                    _flag = false;
                                    _flagThree = false;
                                    _flagTwo = true;
                                  });
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  width: 30.0,
                                  height: 30.0,
                                  decoration: BoxDecoration(
                                    color: _flagTwo
                                        ? Color(0xFF7d9988)
                                        : Color(0XFFDAD9E2),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: Text(
                                    "2",
                                    style: TextStyle(
                                      color: _flagTwo
                                          ? Colors.white
                                          : Colors.black,
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 5.0,
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    // use setState
                                    _flag = false;
                                    _flagTwo = false;
                                    _flagThree = true;
                                  });
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  width: 30.0,
                                  height: 30.0,
                                  decoration: BoxDecoration(
                                    color: _flagThree
                                        ? Color(0xFF7d9988)
                                        : Color(0XFFDAD9E2),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: Text(
                                    "3",
                                    style: TextStyle(
                                      color: _flagThree
                                          ? Colors.white
                                          : Colors.black,
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 30,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 70,
            right: 40,
            child: Container(
              child: ElevatedButton(
                onPressed: () {
                  if (Provider.of<AppInfo>(context, listen: false)
                          .userDropOffLocation !=
                      null) {
                    saveRideRequestInformation();
                  } else {
                    Fluttertoast.showToast(
                        msg: "Please select a dropoff location",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Color(0xFF53906B),
                        textColor: Colors.white,
                        fontSize: 16.0);
                  }
                },
                child: Text(
                  'Next',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  primary: Color(0xFF53906B),
                  minimumSize: Size(200, 45),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Color(0xFF021C0F)
      ..strokeWidth = 2.7
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true
      ..strokeJoin = StrokeJoin.round;

    double dashWidth = 4;
    double dashSpace = 5;
    double startY = size.height / 2;
    double endY = size.height / 2;
    double currentX = 0;

    while (currentX < size.width) {
      canvas.drawLine(
        Offset(currentX, startY),
        Offset(currentX + dashWidth, endY),
        paint,
      );
      currentX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
