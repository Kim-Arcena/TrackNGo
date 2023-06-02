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
List uniqueList = [];
List acceptedRideRequestList = [];
List rideRequestList = [];
List<String> rideRequestIdList = [];
DirectionDetailsInfo? tripDrirectionDetailsInfo;
AssetsAudioPlayer? audioPlayer = AssetsAudioPlayer();
AssetsAudioPlayer? arrivedAudio = AssetsAudioPlayer();
String? chosenDriverId = "";
String? userResponse = "";
bool isChecked = false;
List<UserRideRequestInformation> acceptedRideRequestDetailsList = [];
DriverData onlineDriverData = DriverData();
Position? currentPosition;
int numberOfSeats = 0;
ChosenDriverInformation? chosenDriverInformation;
String? referenceIdValue = "";
String? driverRideStatus = "Rider is on the way";
String cloudMessagingServerToken =
    "key=AAAAwdoQeAI:APA91bGe6W2SeClvRAK16lnY3aSOSTh9_mYDhAI86AtpJNNC_ge_k75f372XjVtS5xdjDQ00e81VaCJimbYdj7n7-x17QzAWWCsJdCxkyjvlXNyRzOj7zA9FJ75jqSFF25P0H30REw1o";
