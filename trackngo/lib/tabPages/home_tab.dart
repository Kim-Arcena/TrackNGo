import 'package:flutter/material.dart';

class HomeTabPage extends StatefulWidget {
  const HomeTabPage({super.key});

  @override
  State<HomeTabPage> createState() => _HomeTabPage();
}

class _HomeTabPage extends State<HomeTabPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Home Tab'),
    );
  }
}
