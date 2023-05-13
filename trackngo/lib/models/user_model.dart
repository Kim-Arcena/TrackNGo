import 'package:firebase_database/firebase_database.dart';

class UserModel {
  String? firstName;
  String? lastName;
  String? number;
  String? id;

  UserModel({
    this.firstName,
    this.lastName,
    this.number,
    this.id,
  });

  UserModel.fromSnapshot(DataSnapshot snap) {
    firstName = (snap.value as dynamic)["firstName"];
    lastName = (snap.value as dynamic)["lastName"];
    number = (snap.value as dynamic)["contactNumber"];
    id = snap.key;
  }
}
