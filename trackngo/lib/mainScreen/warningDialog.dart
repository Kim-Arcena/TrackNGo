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
          iconPadding: EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: Text(title),
          content: Text(content),
          actions: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 15),
              child: SizedBox(
                height: 40,
                child: FloatingActionButton.extended(
                  label: Text("Log Out"),
                  backgroundColor: Colors.green,
                  onPressed: () {
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
