import "dart:async";

import "package:firebase_database/firebase_database.dart";
import "package:flutter/material.dart";
import "package:trackngo/authentication/login_screen.dart";
import "package:trackngo/mainScreen/commuter_screen.dart";
import "package:trackngo/mainScreen/driver_screen.dart";

import "../global/global.dart";

class MySplashScreen extends StatefulWidget {
  const MySplashScreen({super.key});
  @override
  State<MySplashScreen> createState() => _MySplashScreenState();
}

class _MySplashScreenState extends State<MySplashScreen> {
  startTimer() {
    Timer(const Duration(seconds: 3), () async {
      print("fAuth.currentUser: " + fAuth.currentUser.toString());
      if (fAuth.currentUser != null) {
        currentFirebaseUser = fAuth.currentUser;
        DatabaseReference usersRef =
            FirebaseDatabase.instance.ref().child("users");
        DatabaseReference driverRef =
            FirebaseDatabase.instance.ref().child("driver");
        var driver = await driverRef.child(fAuth.currentUser!.uid).get();
        var user = await usersRef.child(fAuth.currentUser!.uid).get();
        var userMap = user.value as Map<dynamic, dynamic>?;
        if (driver.exists) {
          print("driverrrssfsd");
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const MainScreen()));
          // Navigator.push(
          //     context, MaterialPageRoute(builder: (context) => NewTripScreen()));
        }
        if (userMap != null && userMap.containsKey("commuters_child")) {
          print("shett");
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const CommuterScreen()));
        }
      } else {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const LoginScreen()));
      }
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const LoginScreen()));
    });
  }

  initState() {
    super.initState();
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: Image.asset(
                "images/banner.png",
                width: 200,
                height: 200,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 50),
            child: Text(
              "Copyright © 2023 by TrackNGo UPV III.\nAll rights reserved.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    ));
  }
}
