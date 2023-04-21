import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:trackngo/authentication/login_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:trackngo/global/global.dart';
import 'package:trackngo/mainScreen/main_screen.dart';

class SignUpDriver extends StatefulWidget {
  final String email;
  final String password;

  const SignUpDriver({required this.email, required this.password});

  @override
  State<SignUpDriver> createState() => _SignUpDriver();
}

class _SignUpDriver extends State<SignUpDriver> {
  bool passwordVisible = true;
  bool confirmedpasswordVisible = true;

  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _contactNumberController = TextEditingController();
  TextEditingController _plateNumberController = TextEditingController();
  TextEditingController _licenseNumberController = TextEditingController();
  TextEditingController _operatorIdController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();
  List<String> busTypeList = ['Regular', 'Air-Conditioned'];
  String? selectedBusType;

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.email;
    _passwordController.text = widget.password;
  }

  Map<String, dynamic> driverInfoDataMap = {};

  validateForm() {
    RegExp nameRegex = RegExp(r'\b[A-Z][a-z]* [A-Z][a-z]*( [A-Z])?\b');
    RegExp digitRegex = RegExp(r'^(09)[0-9]{9}$');
    RegExp licenseRegex = RegExp(r'^[A-Z]{1}[0-9]{10}$');
    RegExp opcodeRegex = RegExp(r'^[A-Z]{2}[0-9]{4}$');
    RegExp plateRegex = RegExp(r'^[A-Z]{3}[0-9]{4}$');
    RegExp emailRegex = RegExp(
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$",
        caseSensitive: false);
    RegExp passwordRegex = RegExp(
        r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');

    if (_firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _contactNumberController.text.isEmpty ||
        _plateNumberController.text.isEmpty) {
      Fluttertoast.showToast(msg: "Kindly fill up all fields.");
    } else if (!nameRegex.hasMatch(_firstNameController.text) ||
        !nameRegex.hasMatch(_lastNameController.text)) {
      Fluttertoast.showToast(msg: "Invalid Name");
    } else if (!digitRegex.hasMatch(_contactNumberController.text)) {
      Fluttertoast.showToast(msg: "Invalid Contact Number");
    } else if (!licenseRegex.hasMatch(_licenseNumberController.text)) {
      Fluttertoast.showToast(msg: "Invalid Driver's License Number");
    } else if (!opcodeRegex.hasMatch(_operatorIdController.text)) {
      Fluttertoast.showToast(msg: "Invalid Operator ID");
    } else if (!plateRegex.hasMatch(_plateNumberController.text)) {
      Fluttertoast.showToast(msg: "Invalid Operator ID");
    } else if (selectedBusType != 'Regular' ||
        selectedBusType != 'Air-Conditioned') {
      Fluttertoast.showToast(msg: "Select Bus Type");
    } else if (!emailRegex.hasMatch(_emailController.text)) {
      Fluttertoast.showToast(msg: "Invalid Email Address");
    } else if (!passwordRegex.hasMatch(_passwordController.text)) {
      Fluttertoast.showToast(msg: "Invalid Password");
    } else if (_passwordController.text != _confirmPasswordController.text) {
      Fluttertoast.showToast(msg: "Different Passwords Provided");
    } else {
      saveDriverInfo();
    }
  }

  saveDriverInfo() async {
    Map driverInfoDataMap = {
      "firstName": _firstNameController.text.trim(),
      "lastName": _lastNameController.text.trim(),
      "email": _emailController.text.trim(),
      "contactNumber": _contactNumberController.text.trim(),
      "plateNumber": _plateNumberController.text.trim(),
      "licenseNumber": _licenseNumberController.text.trim(),
      "operatorId": _operatorIdController.text.trim(),
      "busType": selectedBusType,
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
                "https://trackngo-d7aa0-default-rtdb.asia-southeast1.firebasedatabase.app/")
        .ref()
        .child("users");
    usersRef
        .child(currentFirebaseUser!.uid)
        .child("drivers_child")
        .set(driverInfoDataMap);

    Fluttertoast.showToast(msg: "Driver's Information Saved Successfully");

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MainScreen(),
      ),
    );
  }

  saveDriverAuthInfo() async {
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 70),
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
                      controller: _licenseNumberController,
                      style: const TextStyle(
                        color: Color(0xFF3a3a3a),
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        labelText: "Driver's License Number",
                        hintText: 'A12-34-567890',
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
                      controller: _operatorIdController,
                      style: const TextStyle(
                        color: Color(0xFF3a3a3a),
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Operator ID',
                        hintText: 'AB-1234',
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
                      controller: _plateNumberController,
                      style: const TextStyle(
                        color: Color(0xFF3a3a3a),
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Plate Number',
                        hintText: 'ABC-1234',
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
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            borderSide: BorderSide(color: Color(0xFFCCCCCC)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            borderSide: BorderSide(color: Color(0xFFCCCCCC)),
                          ),
                        );
                      }).toList(),
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
                        helperStyle:TextStyle(color:Colors.green),
                        suffixIcon: IconButton(
                          icon: Icon(confirmedpasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: () {
                            setState(
                                  () {
                                confirmedpasswordVisible = !confirmedpasswordVisible;
                              },
                            );
                          },
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 20, bottom: 10),
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
