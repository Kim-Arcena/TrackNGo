import 'dart:async';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:trackngo/models/choosen_driver_information.dart';
import 'package:trackngo/models/directions_details_info.dart';
import 'package:trackngo/models/driver_data.dart';
import 'package:trackngo/models/user_model.dart';
import 'package:trackngo/models/user_ride_request_information.dart';

final FirebaseAuth fAuth = FirebaseAuth.instance;
User? currentFirebaseUser;
UserModel? userModelCurrentInfo;
StreamSubscription<Position>? streamStreamSubscription;
StreamSubscription<Position>? streamSubscriptionDriverLivePosition;
List dList = [];
List acceptedRideRequestList = [];
List rideRequestList = [];
DirectionDetailsInfo? tripDrirectionDetailsInfo;
AssetsAudioPlayer? audioPlayer = AssetsAudioPlayer();
String? chosenDriverId = "";
String? userResponse = "";
bool isChecked = false;
List<UserRideRequestInformation> acceptedRideRequestDetailsList = [];
DriverData onlineDriverData = DriverData();
Position? currentPosition;
int numberOfSeats = 0;
ChosenDriverInformation? chosenDriverInformation;
