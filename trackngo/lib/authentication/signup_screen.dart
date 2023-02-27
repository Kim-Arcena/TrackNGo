import 'package:flutter/material.dart';
import 'package:trackngo/authentication/signup_commuter.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:trackngo/authentication/signup_driver.dart';
import 'package:trackngo/authentication/login_screen.dart';
import 'package:flutter/gestures.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  String? selectedImage;

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
                padding: EdgeInsets.all(30.0),
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
                    TextField(
                      controller: _emailController,
                      style: const TextStyle(
                        color: Color(0xFF3a3a3a),
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: 'email@address.com',
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: BorderSide(color: Color(0xFFCCCCCC)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: BorderSide(color: Color(0xFFCCCCCC)),
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
                      height: 20,
                    ),
                    TextField(
                      controller: _passwordController,
                      keyboardType: TextInputType.text,
                      obscureText: true,
                      style: const TextStyle(
                        color: Color(0xFF3a3a3a),
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: '********',
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: BorderSide(color: Color(0xFFCCCCCC)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: BorderSide(color: Color(0xFFCCCCCC)),
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
                    Container(
                      margin: const EdgeInsets.only(top: 60, bottom: 10),
                      child: ElevatedButton(
                          onPressed: () {
                            if (selectedImage == 'images/driver.png') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SignUpDriver()),
                              );
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SignUpCommuter()),
                              );
                            }
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
