import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              child: Text("Log Out"),
              onPressed: () {
                FirebaseAuth.instance.signOut();
                currentFirebaseUser = null;
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MySplashScreen()),
                );
              },
            ),
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
