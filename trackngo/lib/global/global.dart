import 'dart:async';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:trackngo/models/directions_details_info.dart';
import 'package:trackngo/models/user_model.dart';

final FirebaseAuth fAuth = FirebaseAuth.instance;
User? currentFirebaseUser;
UserModel? userModelCurrentInfo;
StreamSubscription<Position>? streamStreamSubscription;
List dList = [];
List requestList = [];
DirectionDetailsInfo? tripDrirectionDetailsInfo;
AssetsAudioPlayer? audioPlayer = AssetsAudioPlayer();
String? choosenDriverId = "";
String? userResponse = "";
bool isChecked = false;
