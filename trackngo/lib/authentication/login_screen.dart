import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:trackngo/authentication/signup_screen.dart';
import 'package:trackngo/mainScreen/commuter_screen.dart';
import 'package:trackngo/mainScreen/main_screen.dart';
import 'package:flutter/gestures.dart';
import 'dart:developer' as developer;
import '../global/global.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool passwordVisible = true;

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  validateForm() {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      Fluttertoast.showToast(msg: "Please fill up all the fields");
    }
    if (!_emailController.text.contains("@")) {
      Fluttertoast.showToast(msg: "Please enter a valid email");
    } else {
      loginDriverNow();
    }
  }

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

      var user = await usersRef.child(firebaseUser.uid).get();
      var userMap = user.value as Map<dynamic, dynamic>?;
      if (userMap != null && userMap.containsKey("drivers_child")) {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const MainScreen()));
      }
      if (userMap != null && userMap.containsKey("commuters_child")) {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const CommuterScreen()));
      }
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
                    Image.asset('images/logo.png', width: 200.0, height: 200.0),
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
                    const SizedBox(height: 20),
                    TextField(
                      controller: _passwordController,
                      keyboardType: TextInputType.text,
                      obscureText: passwordVisible,
                      style: const TextStyle(
                        color: Color(0xFF3a3a3a),
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: '*********',
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
                        helperStyle:TextStyle(color:Colors.green),
                        suffixIcon: IconButton(
                          icon: Icon(passwordVisible
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: () {
                            setState(
                                  () {
                                passwordVisible = !passwordVisible;
                              },
                            );
                          },
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 60, bottom: 10),
                      child: ElevatedButton(
                          onPressed: () {
                            validateForm();
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
                                validateForm();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SignUpScreen()),
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
    );
  }
}
