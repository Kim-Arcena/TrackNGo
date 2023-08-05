import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';

import '../global/global.dart';
import '../splashScreen/splash_screen.dart';

class MyWarningDialog {
  final String title;
  final String content;

  MyWarningDialog({required this.title, required this.content});

  show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          iconPadding: EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          title: Text(title),
          content: Text(content),
          actions: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 15),
              child: SizedBox(
                height: 40,
                child: FloatingActionButton.extended(
                  label: Text("Logout"),
                  backgroundColor: Color(0xFF4e8c6f),
                  onPressed: () {
                    // driverIsOfflineNow();
                    FirebaseAuth.instance.signOut();
                    currentFirebaseUser = null;
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MySplashScreen()),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 15),
              child: SizedBox(
                height: 40,
                child: FloatingActionButton.extended(
                  label: Text("Cancel"),
                  backgroundColor: Colors.grey,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

driverIsOfflineNow() {
  Geofire.removeLocation(currentFirebaseUser!.uid);
  // ignore: deprecated_member_use
  DatabaseReference? usersRef = FirebaseDatabase(
          databaseURL:
              "https://trackngo-d7aa0-default-rtdb.asia-southeast1.firebasedatabase.app/")
      .ref()
      .child("activeDrivers")
      .child(currentFirebaseUser!.uid);
  usersRef.remove();
}
