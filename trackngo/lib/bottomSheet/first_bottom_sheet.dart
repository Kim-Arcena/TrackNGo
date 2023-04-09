import 'package:flutter/material.dart';

class MyBottomSheet extends StatelessWidget {
  final Widget child;

  const MyBottomSheet({required this.child});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.2,
      maxChildSize: 0.8,
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Color(0XFF1D954C),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: ListView(
            controller: scrollController,
            children: <Widget>[
              Container(height: 10),
              child,
            ],
          ),
        );
      },
    );
  }
}
