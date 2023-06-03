import 'package:flutter/material.dart';

class MyAlertDialog {
  final String title;
  final String content;

  MyAlertDialog({required this.title, required this.content});

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
              child: Text(
                "OK",
                style: TextStyle(
                  color: Color(0xFF4E8C6F),
                ),
              ),
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
