import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:trackngo/authentication/alertDialog.dart';
import 'package:trackngo/authentication/login_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:trackngo/mainScreen/commuter_screen.dart';
import 'package:trackngo/mainScreen/driver_screen.dart';

import '../global/global.dart';

class SignUpCommuter extends StatefulWidget {
  final String email;
  final String password;

  SignUpCommuter({required this.email, required this.password});

  @override
  State<SignUpCommuter> createState() => _SignUpCommuter();
}

class _SignUpCommuter extends State<SignUpCommuter> {
  bool passwordVisible = true;
  bool confirmedpasswordVisible = true;

  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _contactNumberController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.email;
    _passwordController.text = widget.password;
  }

  validateForm() {
    RegExp nameRegex = RegExp(r'\b[A-Z][a-z]* [A-Z][a-z]*( [A-Z])?\b');
    RegExp digitRegex = RegExp(r'^(09)[0-9]{9}$');
    RegExp emailRegex = RegExp(
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$",
        caseSensitive: false);
    RegExp passwordRegex = RegExp(
        r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');

    if (_firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _contactNumberController.text.isEmpty) {
      Fluttertoast.showToast(msg: "Please fill up all the fields");
    } else if (!nameRegex.hasMatch(_firstNameController.text) ||
        !nameRegex.hasMatch(_lastNameController.text)) {
      Fluttertoast.showToast(msg: "Invalid Name");
    } else if (!digitRegex.hasMatch(_contactNumberController.text)) {
      MyAlertDialog(
        title: 'Invalid Contact Number',
        content: 'Contact Number must:'
            '* start with "09"'
            '* have 11 digits'
            '* no space between digits',
      ).show(context);
    } else if (!emailRegex.hasMatch(_emailController.text)) {
      Fluttertoast.showToast(msg: "Invalid Email Address");
    } else if (!passwordRegex.hasMatch(_passwordController.text)) {
      MyAlertDialog(
        title: 'Invalid Password',
        content: 'Password must:'
            '* be minimum of 8 characters'
            '* contain lower & uppercase letters'
            '* contain numbers'
            '* contain special symbols, ie. "!, @, # ..."'
            '* space is not considered a special symbol',
      ).show(context);
    } else if (_passwordController.text != _confirmPasswordController.text) {
      Fluttertoast.showToast(msg: "Different Passwords Provided");
    } else {
      saveCommutersInfo();
    }
  }

  saveCommutersInfo() async {
    Map commutersInfoMap = {
      "firstName": _firstNameController.text,
      "lastName": _lastNameController.text,
      "contactNumber": _contactNumberController.text,
      "email": _emailController.text,
      "password": _passwordController.text,
      "confirmPassword": _confirmPasswordController.text,
    };

    final User? firebaseUser = (await fAuth
            .createUserWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    )
            .catchError((err) {
      Fluttertoast.showToast(msg: err.message);
    }))
        .user;

    if (firebaseUser != null) {
      Map userDataMap = {
        "id": firebaseUser.uid,
        "email": _emailController.text.trim(),
        "password": _passwordController.text.trim(),
      };

      DatabaseReference usersRef =
          FirebaseDatabase.instance.ref().child("users");
      usersRef.child(firebaseUser.uid).set(userDataMap);

      currentFirebaseUser = firebaseUser;
    } else {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: "Account has not been registered");
    }
    // ignore: deprecated_member_use
    DatabaseReference usersRef = FirebaseDatabase(
      databaseURL:
          "https://trackngo-d7aa0-default-rtdb.asia-southeast1.firebasedatabase.app/",
    ).ref().child("users");
    usersRef
        .child(firebaseUser!.uid)
        .child("commuters_child")
        .set(commutersInfoMap);

    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const CommuterScreen()));

    Fluttertoast.showToast(msg: "Commuter registered successfully");
  }

  saveCommuterAuthInfo() async {
    final User? firebaseUser = (await fAuth
            .createUserWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    )
            .catchError((err) {
      Fluttertoast.showToast(msg: err.message);
    }))
        .user;

    if (firebaseUser != null) {
      Map userDataMap = {
        "id": firebaseUser.uid,
        "email": _emailController.text.trim(),
        "password": _passwordController.text.trim(),
      };

      DatabaseReference usersRef =
          FirebaseDatabase.instance.ref().child("users");
      usersRef.child(firebaseUser.uid).set(userDataMap);

      currentFirebaseUser = firebaseUser;
    } else {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: "Account has not been registered");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Stack(
          children: <Widget>[
            Container(
              decoration: new BoxDecoration(
                  image: new DecorationImage(
                      image: new AssetImage("images/background.png"),
                      fit: BoxFit.fill)),
            ),
            SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 50),
                    child: Text(
                      "Create Commuters's Account",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(45.0),
                    child: Wrap(
                      spacing: 20,
                      runSpacing: 20,
                      children: [
                        TextField(
                          controller: _firstNameController,
                          style: const TextStyle(
                            color: Color(0xFF3a3a3a),
                            fontSize: 14,
                          ),
                          decoration: InputDecoration(
                            labelText: 'First Name',
                            hintText: 'Juan',
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
                        TextField(
                          controller: _lastNameController,
                          style: const TextStyle(
                            color: Color(0xFF3a3a3a),
                            fontSize: 14,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Last Name',
                            hintText: 'Dela Cruz',
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
                        TextField(
                          controller: _contactNumberController,
                          style: const TextStyle(
                            color: Color(0xFF3a3a3a),
                            fontSize: 14,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Contact Number',
                            hintText: '09XX-XXX-XXXX',
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
                            helperStyle: TextStyle(color: Colors.green),
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
                        TextField(
                          controller: _confirmPasswordController,
                          keyboardType: TextInputType.text,
                          obscureText: confirmedpasswordVisible,
                          style: const TextStyle(
                            color: Color(0xFF3a3a3a),
                            fontSize: 14,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Confirm Password',
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
                            helperStyle: TextStyle(color: Colors.green),
                            suffixIcon: IconButton(
                              icon: Icon(confirmedpasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off),
                              onPressed: () {
                                setState(
                                  () {
                                    confirmedpasswordVisible =
                                        !confirmedpasswordVisible;
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                        Column(
                          children: [
                            Container(
                              margin:
                                  const EdgeInsets.only(top: 45, bottom: 10),
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
                                    "Sign Up",
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
                                              builder: (context) =>
                                                  LoginScreen()),
                                        );
                                      },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
