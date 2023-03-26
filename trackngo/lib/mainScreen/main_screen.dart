import 'dart:async';

import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trackngo/tabPages/earning_tab.dart';
import 'package:trackngo/tabPages/home_tab.dart';
import 'package:trackngo/tabPages/ratings_tab.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  TabController? tabController;
  int selectedIndex = 0;

  onItemClicked(int index) {
    setState(() {
      selectedIndex = index;
      tabController!.index = index;
    });
  }

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
  }

  LatLng _initialcameraposition = LatLng(20.5937, 78.9629);
  final Completer<GoogleMapController> _controllerGoogleMap =
      Completer<GoogleMapController>();
  GoogleMapController? newGoogleMapController;
  Location _location = Location();

  void _onMapCreated(GoogleMapController _cntlr) {
    newGoogleMapController = _cntlr;
    _location.onLocationChanged.listen((l) {
      newGoogleMapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(l.latitude!, l.longitude!), zoom: 25),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition:
                      CameraPosition(target: _initialcameraposition),
                  mapType: MapType.normal,
                  onMapCreated: _onMapCreated,
                  myLocationEnabled: true,
                ),
                Positioned(
                    left: 40.0,
                    top: 80.0,
                    child: Container(
                      width: 50.0,
                      height: 50.0,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xffd4dbdd),
                            blurRadius: 10,
                            spreadRadius: 2,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.qr_code_rounded),
                      ),
                    )),
                Positioned(
                    right: 40.0,
                    top: 80.0,
                    child: Container(
                      width: 50.0,
                      height: 50.0,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xffd4dbdd),
                            blurRadius: 12,
                            spreadRadius: 2,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.location_on_sharp,
                        ),
                      ),
                    )),
              ],
            ),
          ),
          TabBarView(
            physics: const NeverScrollableScrollPhysics(),
            controller: tabController, // pass tabController to TabBarView
            children: const [
              HomeTabPage(),
              EarningsTabPage(),
              RatingsTabPage(),
            ],
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 25.0,
              offset: Offset(0, -15), // changes position of shadow
            ),
          ],
        ),
        child: SizedBox(
          height: 90,
          child: Material(
            elevation: 10,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            borderOnForeground: true,
            clipBehavior: Clip.antiAlias,
            child: BottomNavigationBar(
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.explore),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.attach_money),
                  label: 'Earnings',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings),
                  label: 'Settings',
                ),
              ],
              unselectedItemColor: Color(0xFF7c7c7c),
              selectedItemColor: Color(0xFF4E8C6F),
              backgroundColor: Color.fromARGB(255, 240, 255, 244),
              type: BottomNavigationBarType.fixed,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
              showUnselectedLabels: true,
              currentIndex: selectedIndex,
              onTap: onItemClicked,
              elevation: 22,
            ),
          ),
        ),
      ),
    );
  }
}
