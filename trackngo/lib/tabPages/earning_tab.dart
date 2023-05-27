import 'package:flutter/material.dart';

class EarningsTabPage extends StatefulWidget {
  const EarningsTabPage({super.key});

  @override
  State<EarningsTabPage> createState() => _EarningsTabPageState();
}

class _EarningsTabPageState extends State<EarningsTabPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: <Widget>[
          Container(
            constraints: const BoxConstraints.expand(),
            decoration: new BoxDecoration(
                image: new DecorationImage(
                    image: new AssetImage("images/background.png"),
                    fit: BoxFit.fill)),
            child: Scaffold(
              backgroundColor: Colors.transparent,
                body: ListView(
                  padding: EdgeInsets.all(45.0),
                  children: [
                      const SizedBox(
                        height: 50,
                      ),
                    Text("Summary of Earnings",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
            ),
          ),
        ],
      ),
    );
  }
}
