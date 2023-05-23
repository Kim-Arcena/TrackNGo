import "dart:async";

import "package:flutter/material.dart";
import "package:trackngo/authentication/login_screen.dart";
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
    fAuth.currentUser != null
        ? AssistantMethods.readCurrentOnlineUserInfo()
        : null;
    Timer(const Duration(seconds: 3), () async {
      if (await fAuth.currentUser != null) {
        // ignore: use_build_context_synchronously
        currentFirebaseUser = fAuth.currentUser;
        Navigator.push(
            context, MaterialPageRoute(builder: (c) => MainScreen()));
      } else {
        Navigator.push(
            context, MaterialPageRoute(builder: (c) => LoginScreen()));
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
