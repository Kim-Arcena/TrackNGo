import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trackngo/splashScreen/splash_screen.dart';

import 'infoHandler/app_info.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp(
      child: ChangeNotifierProvider(
    create: (context) => AppInfo(),
    child: MaterialApp(
      title: 'TrackNGo',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: MySplashScreen(),
      debugShowCheckedModeBanner: false,
    ),
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
