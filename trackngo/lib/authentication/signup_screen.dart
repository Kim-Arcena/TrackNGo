import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:trackngo/authentication/signup_commuter.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:trackngo/authentication/signup_driver.dart';
import 'package:trackngo/authentication/login_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:trackngo/global/global.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  String? selectedImage;

  saveDriverInfo() async {
    if (selectedImage == 'images/commuter.png') {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => SignUpCommuter()));
    } else {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => SignUpDriver()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 50, horizontal: 10),
                child: Text(
                  "Choose Account Type",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedImage = 'images/commuter.png';
                      });
                    },
                    child: Neumorphic(
                      margin: const EdgeInsets.all(5),
                      style: NeumorphicStyle(
                        boxShape: NeumorphicBoxShape.roundRect(
                            BorderRadius.circular(20)),
                        depth: 5,
                        lightSource: LightSource.topLeft,
                        color: Colors.white,
                        shadowDarkColor: selectedImage == 'images/commuter.png'
                            ? Color(0xFF8DE0F4)
                            : Color(0xFFDFDFDF),
                        shadowLightColor: selectedImage == 'images/commuter.png'
                            ? Color(0xFF8DE0F4)
                            : Color(0xFFDFDFDF),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(250),
                        ),
                        child: Image.asset(
                          'images/commuter.png',
                          width: 140,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedImage = 'images/driver.png';
                      });
                    },
                    child: Neumorphic(
                      margin: const EdgeInsets.all(5),
                      style: NeumorphicStyle(
                        boxShape: NeumorphicBoxShape.roundRect(
                            BorderRadius.circular(20)),
                        depth: 5,
                        lightSource: LightSource.topLeft,
                        color: Colors.white,
                        shadowDarkColor: selectedImage == 'images/driver.png'
                            ? Color(0xFFF6D09D)
                            : Color(0xFFDFDFDF),
                        shadowLightColor: selectedImage == 'images/driver.png'
                            ? Color(0xFFF6D09D)
                            : Color(0xFFDFDFDF),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(250),
                        ),
                        child: Image.asset(
                          'images/driver.png',
                          width: 140,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(45.0),
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 30, bottom: 10),
                      child: ElevatedButton(
                          onPressed: () {
                            saveDriverInfo();
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF4E8C6F),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                              fixedSize: Size(550, 55)),
                          child: const Text(
                            "Get Started",
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
                            text: 'Have an account already? ',
                          ),
                          TextSpan(
                            text: 'Login',
                            style: const TextStyle(
                              color: Color(0xFF487E65),
                              fontWeight: FontWeight.bold,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => LoginScreen()),
                                );
                              },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
