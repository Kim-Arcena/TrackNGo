import "dart:async";

import "package:flutter/material.dart";
import "package:trackngo/mainScreen/main_screen.dart";

class MySplashScreen extends StatefulWidget {
  const MySplashScreen({super.key});

  @override
  State<MySplashScreen> createState() => _MySplashScreenState();
}

class _MySplashScreenState extends State<MySplashScreen> {
  startTimer() {
    Timer(const Duration(seconds: 3), () async {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => MainScreen()));
    });
  }

  initState() {
    super.initState();
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black12,
      child: const Center(
        child: Text('Splash Screen'),
      ),
    );
  }
}
