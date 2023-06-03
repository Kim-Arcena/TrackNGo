import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:trackngo/authentication/alertDialog.dart';
import 'package:trackngo/authentication/login_screen.dart';
import 'package:trackngo/mainScreen/commuter_screen.dart';

import '../global/global.dart';

class SignUpCommuter extends StatefulWidget {
  final String email;
  final String password;

  SignUpCommuter({required this.email, required this.password});

  @override
  State<SignUpCommuter> createState() => _SignUpCommuter();
}

class _SignUpCommuter extends State<SignUpCommuter> {
  final FocusNode firstnameFocus = FocusNode();
  final FocusNode lastnameFocus = FocusNode();
  final FocusNode contactFocus = FocusNode();
  final FocusNode addressFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();
  final FocusNode confirmedFocus = FocusNode();
  final _validationKey = GlobalKey<FormState>();
  bool passwordVisible = true;
  bool confirmedpasswordVisible = true;

  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _contactNumberController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();

  RegExp nameRegex = RegExp(r'\b[A-Z][a-z]*( [A-Z])?\b');
  RegExp digitRegex = RegExp(r'^(09)\d{9}$');
  RegExp emailRegex = RegExp(
      r"^[a-zA-Z\d.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z\d-]+(?:\.[a-zA-Z\d-]+)*$",
      caseSensitive: false);
  RegExp passwordRegex = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@!%*?&])[A-Za-z\d@!%*?&]{8,}$');

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.email;
    _passwordController.text = widget.password;
  }

  validateForm() {
    if (!digitRegex.hasMatch(_contactNumberController.text)) {
      MyAlertDialog(
        title: 'Invalid Contact Number',
        content: 'Contact Number must:\n'
            '    * start with "09"\n'
            '    * have 11 digits\n'
            '    * no space between digits',
      ).show(context);
    } else if (!passwordRegex.hasMatch(_passwordController.text)) {
      MyAlertDialog(
        title: 'Invalid Password',
        content: 'Password must:\n'
            '    * be minimum of 8 characters\n'
            '    * contain lower & uppercase letters\n'
            '    * contain numbers\n'
            '    * contain special symbols "@, !, %, *, ?, &"\n'
            '    * space is not considered a special symbol',
      ).show(context);
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
      };

      DatabaseReference usersRef =
          FirebaseDatabase.instance.ref().child("users");
      usersRef.child(firebaseUser.uid).set(userDataMap);
      usersRef
          .child(firebaseUser.uid)
          .child("commuters_child")
          .set(commutersInfoMap);
      currentFirebaseUser = firebaseUser;
      print("Commuter's Info Map: $commutersInfoMap");
    } else {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: "Account has not been registered");
    }
    // ignore: deprecated_member_use
    DatabaseReference usersRef = FirebaseDatabase.instance.ref().child("users");
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
    return Center(
      child: Container(
        constraints: const BoxConstraints.expand(),
        decoration: new BoxDecoration(
            image: new DecorationImage(
                image: new AssetImage("images/background.png"),
                fit: BoxFit.cover)),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: SingleChildScrollView(
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
                        Form(
                          key: _validationKey,
                          child: Column(
                            children: [
                              TextFormField(
                                validator: (isValid) {
                                  if (isValid!.isEmpty) {
                                    return 'This field requires a first name';
                                  } else if (!nameRegex
                                      .hasMatch(_firstNameController.text)) {
                                    return 'Invalid First Name';
                                  }
                                  return null;
                                },
                                inputFormatters: [
                                  FilteringTextInputFormatter.deny(RegExp(
                                      r"^(\d*);(\d*);(\w+(?: \w+)?)?;(\d*);$")),
                                ],
                                controller: _firstNameController,
                                keyboardType: TextInputType.name,
                                maxLength: 60,
                                maxLines: 1,
                                style: const TextStyle(
                                  color: Color(0xFF3a3a3a),
                                  fontSize: 14,
                                ),
                                focusNode: firstnameFocus,
                                autofocus: false,
                                decoration: InputDecoration(
                                  errorMaxLines: 1,
                                  counterText: "",
                                  labelText: 'First Name',
                                  hintText: 'Juan',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                    borderSide:
                                        BorderSide(color: Colors.black12),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                    borderSide: BorderSide(color: Colors.green),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                    borderSide: BorderSide(color: Colors.red),
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
                              TextFormField(
                                validator: (isValid) {
                                  if (isValid!.isEmpty) {
                                    return 'This field requires a last name';
                                  } else if (!nameRegex
                                      .hasMatch(_lastNameController.text)) {
                                    return 'Invalid Last Name';
                                  }
                                  return null;
                                },
                                inputFormatters: [
                                  FilteringTextInputFormatter.deny(RegExp(
                                      r"^(\d*);(\d*);(\w+(?: \w+)?)?;(\d*);$")),
                                ],
                                controller: _lastNameController,
                                keyboardType: TextInputType.name,
                                maxLength: 60,
                                maxLines: 1,
                                style: const TextStyle(
                                  color: Color(0xFF3a3a3a),
                                  fontSize: 14,
                                ),
                                focusNode: lastnameFocus,
                                autofocus: false,
                                decoration: InputDecoration(
                                  errorMaxLines: 1,
                                  counterText: "",
                                  labelText: 'Last Name',
                                  hintText: 'Dela Cruz',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                    borderSide:
                                        BorderSide(color: Colors.black12),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                    borderSide: BorderSide(color: Colors.green),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                    borderSide: BorderSide(color: Colors.red),
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
                              TextFormField(
                                validator: (isValid) {
                                  if (isValid!.isEmpty) {
                                    return 'This field requires a contact number';
                                  }
                                  if (!digitRegex.hasMatch(
                                      _contactNumberController.text)) {
                                    validateForm();
                                    return 'Invalid Contact Number';
                                  }
                                  return null;
                                },
                                inputFormatters: [
                                  FilteringTextInputFormatter.deny(RegExp(
                                      r"^(\d*);(\d*);(\w+(?: \w+)?)?;(\d*);$")),
                                ],
                                controller: _contactNumberController,
                                keyboardType: TextInputType.phone,
                                maxLength: 60,
                                maxLines: 1,
                                style: const TextStyle(
                                  color: Color(0xFF3a3a3a),
                                  fontSize: 14,
                                ),
                                focusNode: contactFocus,
                                autofocus: false,
                                decoration: InputDecoration(
                                  errorMaxLines: 1,
                                  counterText: "",
                                  labelText: 'Contact Number',
                                  hintText: '09XX-XXX-XXXX',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                    borderSide:
                                        BorderSide(color: Colors.black12),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                    borderSide: BorderSide(color: Colors.green),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                    borderSide: BorderSide(color: Colors.red),
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
                              TextFormField(
                                validator: (isValid) {
                                  if (isValid!.isEmpty) {
                                    return 'This field requires an email';
                                  } else if (!emailRegex
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
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                    borderSide:
                                        BorderSide(color: Colors.black12),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                    borderSide: BorderSide(color: Colors.green),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                    borderSide: BorderSide(color: Colors.red),
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
                              TextFormField(
                                validator: (isValid) {
                                  if (isValid!.isEmpty) {
                                    return 'This field requires a password';
                                  } else if (!passwordRegex
                                      .hasMatch(_passwordController.text)) {
                                    validateForm();
                                    return 'Invalid Password';
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
                                  hintText: '*********',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                    borderSide:
                                        BorderSide(color: Colors.black12),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                    borderSide: BorderSide(color: Colors.green),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                    borderSide: BorderSide(color: Colors.red),
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
                              const SizedBox(
                                height: 20,
                              ),
                              TextFormField(
                                validator: (isValid) {
                                  if (isValid!.isEmpty) {
                                    return 'This field requires the confirmed password';
                                  } else if (_passwordController.text !=
                                      _confirmPasswordController.text) {
                                    return 'Different Password Provided';
                                  }
                                  return null;
                                },
                                inputFormatters: [
                                  FilteringTextInputFormatter.deny(RegExp(
                                      r"^(\d*);(\d*);(\w+(?: \w+)?)?;(\d*);$")),
                                ],
                                controller: _confirmPasswordController,
                                keyboardType: TextInputType.text,
                                maxLength: 60,
                                maxLines: 1,
                                obscureText: confirmedpasswordVisible,
                                style: const TextStyle(
                                  color: Color(0xFF3a3a3a),
                                  fontSize: 14,
                                ),
                                focusNode: confirmedFocus,
                                autofocus: false,
                                decoration: InputDecoration(
                                  errorMaxLines: 1,
                                  counterText: "",
                                  labelText: 'Confirm Password',
                                  hintText: '*********',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                    borderSide:
                                        BorderSide(color: Colors.black12),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                    borderSide: BorderSide(color: Colors.green),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                    borderSide: BorderSide(color: Colors.red),
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
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            Container(
                              margin:
                                  const EdgeInsets.only(top: 45, bottom: 10),
                              child: ElevatedButton(
                                  onPressed: () {
                                    if (!_validationKey.currentState!
                                        .validate()) {
                                      return;
                                    }
                                    saveCommutersInfo();
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
          ),
        ),
      ),
    );
  }
}
