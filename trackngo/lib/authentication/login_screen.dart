import 'dart:math' as math;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:trackngo/authentication/signup_screen.dart';
import 'package:trackngo/mainScreen/commuter_screen.dart';
import 'package:trackngo/mainScreen/driver_screen.dart';

import '../global/global.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FocusNode addressFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();
  final _validationKey = GlobalKey<FormState>();
  bool passwordVisible = true;

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  RegExp emailRegex = RegExp(
      r"^[a-zA-Z\d.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z\d-]+(?:\.[a-zA-Z\d-]+)*$",
      caseSensitive: false);
  RegExp passwordRegex = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');

  loginDriverNow() async {
    final User? firebaseUser = (await fAuth
            .signInWithEmailAndPassword(
                email: _emailController.text,
                password: _passwordController.text)
            .catchError((errMsg) {
      Fluttertoast.showToast(msg: "Error: " + errMsg.toString());
    }))
        .user;
    if (firebaseUser != null) {
      print("this is firebase user: " + firebaseUser.uid);
      DatabaseReference usersRef = FirebaseDatabase(
              databaseURL:
                  "https://trackngo-d7aa0-default-rtdb.asia-southeast1.firebasedatabase.app/")
          .ref()
          .child("users");
      DatabaseReference driverRef = FirebaseDatabase(
              databaseURL:
                  "https://trackngo-d7aa0-default-rtdb.asia-southeast1.firebasedatabase.app/")
          .ref()
          .child("driver");
      var driver = await driverRef.child(firebaseUser.uid).get();
      var user = await usersRef.child(firebaseUser.uid).get();
      var userMap = user.value as Map<dynamic, dynamic>?;
      if (driver.exists) {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const MainScreen()));
        // Navigator.push(
        //     context, MaterialPageRoute(builder: (context) => NewTripScreen()));
      }
      if (userMap != null && userMap.containsKey("commuters_child")) {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const CommuterScreen()));
      }
    }
  }

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
              body: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text("Hi, Welcome Back!",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          )),
                      const Text("Hello again, you've been missed!",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                          )),
                      Padding(
                        padding: const EdgeInsets.all(45),
                        child: Column(
                          children: [
                            Image.asset('images/logo.png',
                                width: 200.0, height: 200.0),
                            Form(
                              key: _validationKey,
                              child: Column(
                                children: [
                                  TextFormField(
                                    validator: (isValid) {
                                      if (isValid!.isEmpty) {
                                        return 'This field requires an email';
                                      }
                                      if (!emailRegex
                                          .hasMatch(_emailController.text)) {
                                        return 'Invalid Email Address';
                                      }
                                      return null;
                                    },
                                    inputFormatters: [
                                      FilteringTextInputFormatter.deny(RegExp(
                                          r"^(\d*);(\d*);(\w+(?: \w+)?)?;(\d*);$")),
                                    ],
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    maxLength: 60,
                                    maxLines: 1,
                                    style: const TextStyle(
                                      color: Color(0xFF3a3a3a),
                                      fontSize: 14,
                                    ),
                                    focusNode: addressFocus,
                                    autofocus: false,
                                    decoration: InputDecoration(
                                      errorMaxLines: 1,
                                      counterText: "",
                                      labelText: 'Email',
                                      hintText: 'email@address.com',
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                        borderSide:
                                            BorderSide(color: Colors.black12),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                        borderSide:
                                            BorderSide(color: Colors.green),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                        borderSide:
                                            BorderSide(color: Colors.red),
                                      ),
                                      hintStyle: const TextStyle(
                                        color: Color(0xFFCCCCCC),
                                        fontSize: 16,
                                      ),
                                      labelStyle: const TextStyle(
                                        color: Color(0xFF2b2b2b),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  TextFormField(
                                    validator: (isValid) {
                                      if (isValid!.isEmpty) {
                                        return 'This field requires a password';
                                      }
                                      if (!passwordRegex
                                          .hasMatch(_passwordController.text)) {
                                        return 'Incorrect Password';
                                      }
                                      return null;
                                    },
                                    inputFormatters: [
                                      FilteringTextInputFormatter.deny(RegExp(
                                          r"^(\d*);(\d*);(\w+(?: \w+)?)?;(\d*);$")),
                                    ],
                                    controller: _passwordController,
                                    keyboardType: TextInputType.text,
                                    maxLength: 60,
                                    maxLines: 1,
                                    obscureText: passwordVisible,
                                    style: const TextStyle(
                                      color: Color(0xFF3a3a3a),
                                      fontSize: 14,
                                    ),
                                    focusNode: passwordFocus,
                                    autofocus: false,
                                    decoration: InputDecoration(
                                      errorMaxLines: 1,
                                      counterText: "",
                                      labelText: 'Password',
                                      hintText: '********',
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                        borderSide:
                                            BorderSide(color: Colors.black12),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                        borderSide:
                                            BorderSide(color: Colors.green),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                        borderSide:
                                            BorderSide(color: Colors.red),
                                      ),
                                      hintStyle: const TextStyle(
                                        color: Color(0xFFCCCCCC),
                                        fontSize: 16,
                                      ),
                                      labelStyle: const TextStyle(
                                        color: Color(0xFF2b2b2b),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                      helperStyle:
                                          TextStyle(color: Colors.green),
                                      suffixIcon: IconButton(
                                        icon: Icon(passwordVisible
                                            ? Icons.visibility
                                            : Icons.visibility_off),
                                        onPressed: () {
                                          setState(
                                            () {
                                              passwordVisible =
                                                  !passwordVisible;
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              margin:
                                  const EdgeInsets.only(top: 60, bottom: 10),
                              child: ElevatedButton(
                                  onPressed: () {
                                    // if (!_validationKey.currentState!
                                    //     .validate()) {
                                    //   return;
                                    // }
                                    // loginDriverNow();
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF4E8C6F),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      fixedSize: const Size(550, 55)),
                                  child: const Text(
                                    "Login",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  )),
                            ),
                            RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  color: Color(0xFFC7C8CC),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                                children: [
                                  const TextSpan(
                                    text: 'Dont have an account? ',
                                  ),
                                  TextSpan(
                                    text: 'Signup',
                                    style: const TextStyle(
                                      color: Color(0xFF487E65),
                                      fontWeight: FontWeight.bold,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        loginDriverNow();
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  SignUpScreen()),
                                        );
                                      },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Color(0xFFB9C7C0)
      ..strokeWidth = 2.7
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true
      ..strokeJoin = StrokeJoin.round;

    double dashWidth = 4;
    double dashSpace = 5;
    double startY = size.height / 2;
    double endY = size.height / 2;
    double currentX = 0;

    // Adjust the width and height of the Rect for larger arc
    double arcWidth = 10;
    double arcHeight = 10;

    // Draw half circle at the start
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(currentX, startY),
        width: arcWidth,
        height: arcHeight,
      ),
      -math.pi,
      math.pi,
      false,
      paint,
    );

    currentX += arcWidth; // Adjust for the half circle

    while (currentX < size.width - arcWidth) {
      // Subtract the half circle at the end
      canvas.drawLine(
        Offset(currentX, startY),
        Offset(currentX + dashWidth, endY),
        paint,
      );
      currentX += dashWidth + dashSpace;
    }

    // Draw half circle at the end
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(currentX, startY),
        width: arcWidth,
        height: arcHeight,
      ),
      0,
      math.pi,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
