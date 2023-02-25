import 'package:flutter/material.dart';
import 'package:trackngo/splashScreen/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp(
      child: MaterialApp(
    title: 'TrackNGo',
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
    home: MySplashScreen(),
    debugShowCheckedModeBanner: false,
  )));
}

class MyApp extends StatefulWidget {
  final Widget? child;

  MyApp({this.child});

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_MyAppState>()!.restartApp();
  } 

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Key key = UniqueKey();
  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      child: widget.child!,  
      key: key,
    );
  }
}
