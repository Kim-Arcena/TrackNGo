import "dart:async";

import "package:firebase_database/firebase_database.dart";
import "package:flutter/material.dart";
import "package:trackngo/authentication/login_screen.dart";
import "package:trackngo/mainScreen/commuter_screen.dart";
import "package:trackngo/mainScreen/driver_screen.dart";

import "../assistants/assistant_methods.dart";
import "../global/global.dart";

class MySplashScreen extends StatefulWidget {
  const MySplashScreen({super.key});

  @override
  State<MySplashScreen> createState() => _MySplashScreenState();
}

class _MySplashScreenState extends State<MySplashScreen> {
  startTimer() {
    print(fAuth.currentUser);
    fAuth.currentUser != null
        ? AssistantMethods.readCurrentOnlineUserInfo()
        : null;
    Timer(const Duration(seconds: 3), () async {
      print("fAuth.currentUser: " + fAuth.currentUser.toString());
      if (fAuth.currentUser != null) {
        DatabaseReference usersRef = FirebaseDatabase(
                databaseURL:
                    "https://trackngo-d7aa0-default-rtdb.asia-southeast1.firebasedatabase.app/")
            .ref()
            .child("users");
        DatabaseReference driverRef = FirebaseDatabase(
                databaseURL:
                    "https://trackngo-d7aa0-default-rtdb.asia-southeast1.firebasedatabase.app/")
            .ref()
            .child("driver");
        var driver = await driverRef.child(fAuth.currentUser!.uid).get();
        var user = await usersRef.child(fAuth.currentUser!.uid).get();
        var userMap = user.value as Map<dynamic, dynamic>?;
        if (driver.exists) {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const MainScreen()));
          // Navigator.push(
          //     context, MaterialPageRoute(builder: (context) => NewTripScreen()));
        }
        if (userMap != null && userMap.containsKey("commuters_child")) {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const CommuterScreen()));
        }
      } else {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const LoginScreen()));
      }
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
