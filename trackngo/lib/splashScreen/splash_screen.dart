import "dart:async";

import "package:flutter/material.dart";
import "package:trackngo/authentication/login_screen.dart";
import "package:trackngo/authentication/signup_screen.dart";
import "package:trackngo/mainScreen/main_screen.dart";

import "../global/global.dart";

class MySplashScreen extends StatefulWidget {
  const MySplashScreen({super.key});

  @override
  State<MySplashScreen> createState() => _MySplashScreenState();
}

class _MySplashScreenState extends State<MySplashScreen> {
  startTimer() {
    Timer(const Duration(seconds: 3), () async {
      if (fAuth.currentUser != null) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (c) => const MainScreen()));
      } else {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (c) => const LoginScreen()));
      }

      Navigator.push(
          context, MaterialPageRoute(builder: (c) => SignUpScreen()));
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
