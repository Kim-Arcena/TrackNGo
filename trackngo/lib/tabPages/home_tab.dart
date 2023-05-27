import 'package:flutter/material.dart';
import 'package:trackngo/authentication/signup_screen.dart';
import 'package:trackngo/splashScreen/splash_screen.dart';

class HomeTabPage extends StatefulWidget {
  const HomeTabPage({super.key});

  @override
  State<HomeTabPage> createState() => _HomeTabPage();
}

class _HomeTabPage extends State<HomeTabPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: ElevatedButton(
          child: Text('Logout'),
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (c) => const MySplashScreen()));
          },
        ),
    );
  }
}
