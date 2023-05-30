import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:trackngo/authentication/alertDialog.dart';
import 'package:trackngo/authentication/login_screen.dart';
import 'package:trackngo/global/global.dart';
import 'package:trackngo/mainScreen/driver_screen.dart';
import 'package:trackngo/push_notifications/push_notification_system.dart';

class SignUpDriver extends StatefulWidget {
  final String email;
  final String password;

  const SignUpDriver({required this.email, required this.password});

  @override
  State<SignUpDriver> createState() => _SignUpDriver();
}

class _SignUpDriver extends State<SignUpDriver> {
  final FocusNode firstnameFocus = FocusNode();
  final FocusNode lastnameFocus = FocusNode();
  final FocusNode contactFocus = FocusNode();
  final FocusNode licenseFocus = FocusNode();
  final FocusNode opcodeFocus = FocusNode();
  final FocusNode plateFocus = FocusNode();
  final FocusNode addressFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();
  final FocusNode confirmedFocus = FocusNode();
  final _validationKey = GlobalKey<FormState>();
  bool passwordVisible = true;
  bool confirmedPasswordVisible = true;

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

  RegExp nameRegex = RegExp(r'\b[A-Z][a-z]*( [A-Z])?\b');
  RegExp digitRegex = RegExp(r'^(09)\d{9}$');
  RegExp licenseRegex = RegExp(r'^[A-Z]\d{10}$');
  RegExp opcodeRegex = RegExp(r'^[A-Z]{2}\d{4}$');
  RegExp plateRegex = RegExp(r'^[A-Z]{3}\d{4}$');
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

  Map<String, dynamic> driverInfoDataMap = {};

  validateForm() {
    if (!digitRegex.hasMatch(_contactNumberController.text)) {
      MyAlertDialog(
        title: 'Invalid Contact Number',
        content: 'Contact Number must:\n'
            '    * start with "09"\n'
            '    * have 11 digits\n'
            '    * no space between digits',
      ).show(context);
    } else if (!licenseRegex.hasMatch(_licenseNumberController.text)) {
      MyAlertDialog(
        title: "Invalid Driver's License Number",
        content: "Driver's License must:\n"
            '    * start with an uppercase letter\n'
            '    * followed by 10 digits\n'
            '    * contain 11 characters\n'
            '    * no space between characters',
      ).show(context);
    } else if (!opcodeRegex.hasMatch(_operatorIdController.text)) {
      MyAlertDialog(
        title: "Invalid Operator ID",
        content: "Operator ID must:\n"
            '    * start with 2 uppercase letters\n'
            '    * followed by 4 digits\n'
            '    * contain 6 characters\n'
            '    * no space between characters',
      ).show(context);
    } else if (!plateRegex.hasMatch(_plateNumberController.text)) {
      MyAlertDialog(
        title: "Invalid Plate Number",
        content: "Plate Number must:\n"
            '    * start with 3 uppercase letters\n'
            '    * followed by 4 digits\n'
            '    * contain 7 characters\n'
            '    * no space between characters\n',
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

  saveDriverInfo() async {
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
      currentFirebaseUser = firebaseUser;
    } else {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: "Account has not been registered");
    }

    Map driverInfoDataMap = {
      "id": currentFirebaseUser!.uid,
      "firstName": _firstNameController.text.trim(),
      "lastName": _lastNameController.text.trim(),
      "email": _emailController.text.trim(),
      "contactNumber": _contactNumberController.text.trim(),
      "plateNumber": _plateNumberController.text.trim(),
      "licenseNumber": _licenseNumberController.text.trim(),
      "operatorId": _operatorIdController.text.trim(),
      "busType": selectedBusType,
    };

    // ignore: deprecated_member_use
    DatabaseReference usersRef = FirebaseDatabase(
            databaseURL:
                "https://trackngo-d7aa0-default-rtdb.asia-southeast1.firebasedatabase.app/")
        .ref()
        .child("driver");
    usersRef.child(currentFirebaseUser!.uid).set(driverInfoDataMap);

    Fluttertoast.showToast(msg: "Driver's Information Saved Successfully");
    PushNotificationSystem pushNotificationSystem = PushNotificationSystem();
    pushNotificationSystem.initializeCloudMessagin(context);
    pushNotificationSystem.generateAndGetToken();
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
                                    return "This field requires a driver's license";
                                  }
                                  if (!licenseRegex.hasMatch(
                                      _licenseNumberController.text)) {
                                    validateForm();
                                    return "Invalid Driver's License Number";
                                  }
                                  return null;
                                },
                                inputFormatters: [
                                  FilteringTextInputFormatter.deny(RegExp(
                                      r"^(\d*);(\d*);(\w+(?: \w+)?)?;(\d*);$")),
                                ],
                                controller: _licenseNumberController,
                                keyboardType: TextInputType.text,
                                maxLength: 60,
                                maxLines: 1,
                                style: const TextStyle(
                                  color: Color(0xFF3a3a3a),
                                  fontSize: 14,
                                ),
                                focusNode: licenseFocus,
                                autofocus: false,
                                decoration: InputDecoration(
                                  errorMaxLines: 1,
                                  counterText: "",
                                  labelText: "Driver's License Number",
                                  hintText: 'A12-34-567890',
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
                                    return "This field requires an operator id";
                                  }
                                  if (!opcodeRegex
                                      .hasMatch(_operatorIdController.text)) {
                                    validateForm();
                                    return 'Invalid Operator ID';
                                  }
                                  return null;
                                },
                                inputFormatters: [
                                  FilteringTextInputFormatter.deny(RegExp(
                                      r"^(\d*);(\d*);(\w+(?: \w+)?)?;(\d*);$")),
                                ],
                                controller: _operatorIdController,
                                keyboardType: TextInputType.text,
                                maxLength: 60,
                                maxLines: 1,
                                style: const TextStyle(
                                  color: Color(0xFF3a3a3a),
                                  fontSize: 14,
                                ),
                                focusNode: opcodeFocus,
                                autofocus: false,
                                decoration: InputDecoration(
                                  errorMaxLines: 1,
                                  counterText: "",
                                  labelText: 'Operator ID',
                                  hintText: 'AB-1234',
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
                                    return "This field requires a plate number";
                                  }
                                  if (!plateRegex
                                      .hasMatch(_plateNumberController.text)) {
                                    validateForm();
                                    return 'Invalid Plate Number';
                                  }
                                  return null;
                                },
                                inputFormatters: [
                                  FilteringTextInputFormatter.deny(RegExp(
                                      r"^(\d*);(\d*);(\w+(?: \w+)?)?;(\d*);$")),
                                ],
                                controller: _plateNumberController,
                                keyboardType: TextInputType.text,
                                maxLength: 60,
                                maxLines: 1,
                                style: const TextStyle(
                                  color: Color(0xFF3a3a3a),
                                  fontSize: 14,
                                ),
                                focusNode: plateFocus,
                                autofocus: false,
                                decoration: InputDecoration(
                                  errorMaxLines: 1,
                                  counterText: "",
                                  labelText: 'Plate Number',
                                  hintText: 'ABC-1234',
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
                              SizedBox(
                                width: 300,
                                child: DropdownButtonFormField(
                                  validator: (isValid) {
                                    if (isValid == null) {
                                      return "Unselected Bus Type";
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
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
                                      borderSide:
                                          BorderSide(color: Colors.green),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                      borderSide: BorderSide(color: Colors.red),
                                    ),
                                  ),
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
                              ),
                              const SizedBox(
                                height: 20,
                              ),
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
                                  }
                                  if (!passwordRegex
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
                                  }
                                  if (_passwordController.text !=
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
                                obscureText: confirmedPasswordVisible,
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
                                    icon: Icon(confirmedPasswordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off),
                                    onPressed: () {
                                      setState(
                                        () {
                                          confirmedPasswordVisible =
                                              !confirmedPasswordVisible;
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
                                  const EdgeInsets.only(top: 20, bottom: 10),
                              child: ElevatedButton(
                                  onPressed: () {
                                    if (!_validationKey.currentState!
                                        .validate()) {
                                      return;
                                    }
                                    saveDriverInfo();
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
