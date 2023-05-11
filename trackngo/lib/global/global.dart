import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:trackngo/models/directions_details_info.dart';

final FirebaseAuth fAuth = FirebaseAuth.instance;
User? currentFirebaseUser;
StreamSubscription<Position>? streamStreamSubscription;
List dList = [];
DirectionDetailsInfo? tripDrirectionDetailsInfo;
