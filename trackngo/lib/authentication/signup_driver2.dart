import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:trackngo/authentication/login_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:trackngo/mainScreen/main_screen.dart';
import 'package:trackngo/authentication/signup_driver.dart';

import '../global/global.dart';

class SignUpDriver2 extends StatefulWidget {
  final Map<String, dynamic> driverInfoDataMap;
  const SignUpDriver2({Key? key, required this.driverInfoDataMap})
      : super(key: key);

  @override
  State<SignUpDriver2> createState() => _SignUpDriver2State();
}

class _SignUpDriver2State extends State<SignUpDriver2> {
  TextEditingController _licenseNumberController = TextEditingController();
  TextEditingController _operatorIdController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();
  List<String> busTypeList = ['Regular', 'Air-Conditioned'];
  String? selectedBusType;

  Map<String, dynamic> driverInfoDataMap = {};

  validateForm() {
    RegExp digitRegex = RegExp(r'^\d+$');
    if (_licenseNumberController.text.isEmpty ||
        _operatorIdController.text.isEmpty ||
        selectedBusType == null ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      Fluttertoast.showToast(msg: "Please fill all the fields");
    } else if (_licenseNumberController.text.length != 4 ||
        !digitRegex.hasMatch(_licenseNumberController.text)) {
      Fluttertoast.showToast(msg: "Invalid Contact Number");
    } else if (_passwordController.text.length < 6) {
      Fluttertoast.showToast(msg: "Password must be at least 6 characters");
    } else if (_passwordController.text != _confirmPasswordController.text) {
      Fluttertoast.showToast(msg: "Password does not match");
    } else if (_operatorIdController.text.length != 4 ||
        !digitRegex.hasMatch(_operatorIdController.text)) {
    } else {
      saveDriverInfo();
    }
  }

  void saveDriverInfo() {
    driverInfoDataMap.addAll(widget.driverInfoDataMap);
    driverInfoDataMap.addAll({
      "license_number": _licenseNumberController.text.trim(),
      "operator_id": _operatorIdController.text.trim(),
      "bus_type": selectedBusType,
      "password": _passwordController.text.trim(),
      "confirm_password": _confirmPasswordController.text.trim(),
    });

    // ignore: deprecated_member_use
    DatabaseReference usersRef = FirebaseDatabase(
      databaseURL:
          "https://trackngo-d7aa0-default-rtdb.asia-southeast1.firebasedatabase.app/",
    ).ref().child("users");
    usersRef
        .child(currentFirebaseUser!.uid)
        .child("drivers_child")
        .set(driverInfoDataMap);

    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const MainScreen()));

    Fluttertoast.showToast(msg: "Driver registered successfully");
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
                padding: EdgeInsets.only(top: 30),
                child: Text(
                  "Create Driver's Account",
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
                child: Column(
                  children: [
                    TextField(
                      controller: _licenseNumberController,
                      style: const TextStyle(
                        color: Color(0xFF3a3a3a),
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        labelText: 'License Number',
                        hintText: 'XXXX-XXXXXXX',
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
                      height: 10,
                    ),
                    TextField(
                      controller: _operatorIdController,
                      style: const TextStyle(
                        color: Color(0xFF3a3a3a),
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Operator ID',
                        hintText: 'XXXX',
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
                      height: 10,
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
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: _confirmPasswordController,
                      keyboardType: TextInputType.text,
                      obscureText: true,
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
                      ),
                    ),
                    DropdownButton(
                      hint: const Text(
                        'Select Bus Type',
                        style: TextStyle(
                          color: Color(0xFF3a3a3a),
                          fontSize: 14,
                        ),
                      ),
                      value: selectedBusType,
                      onChanged: (newValue) {
                        setState(() {
                          selectedBusType = newValue.toString();
                        });
                      },
                      items: busTypeList.map((bus) {
                        return DropdownMenuItem(
                          // ignore: sort_child_properties_last
                          child: Text(
                            bus,
                            style: const TextStyle(
                                color: Color(0xFF3a3a3a),
                                fontSize: 16,
                                fontWeight: FontWeight.w500),
                          ),
                          value: bus,
                        );
                      }).toList(),
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
