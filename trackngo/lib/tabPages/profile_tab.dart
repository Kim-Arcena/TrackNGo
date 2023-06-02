import 'package:flutter/material.dart';
import 'package:trackngo/mainScreen/driver_trip_screen.dart';
import 'package:trackngo/tabPages/earning_tab.dart';

class ProfileTabPage extends StatefulWidget {
  const ProfileTabPage({super.key});

  @override
  State<ProfileTabPage> createState() => _ProfileTabPage();
}

class _ProfileTabPage extends State<ProfileTabPage> {
  TabController? tabController;
  int selectedIndex = 1;
  onItemClicked(int index) {
    setState(() {
      selectedIndex = index;
      tabController!.index = index;
    });
  }

  void onItemSelected(int index) {
    if (index == 0) {
      // Check if the "Earnings" item is clicked (index 1)
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => DriverTripScreen()));
    } else if (index == 1) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => EarningsTabPage()));
    } else if (index == 2) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => ProfileTabPage()));
    } else {
      setState(() {
        selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: <Widget>[
          Container(
            constraints: const BoxConstraints.expand(),
            decoration: new BoxDecoration(
                image: new DecorationImage(
                    image: new AssetImage("images/background.png"),
                    fit: BoxFit.fill)),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text("Profile",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          )),
                      const Text("Hello again, you've been missed!",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                          )),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(250),
                  topRight: Radius.circular(250),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 25.0,
                    offset: Offset(0, -15), // changes position of shadow
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                child: SizedBox(
                  height: 90,
                  child: Material(
                    elevation: 10,
                    borderOnForeground: true,
                    child: BottomNavigationBar(
                      items: [
                        BottomNavigationBarItem(
                          icon: Icon(Icons.explore),
                          label: 'Home',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.attach_money),
                          label: 'Earnings',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.person),
                          label: 'Profile',
                        ),
                      ],
                      unselectedItemColor: Color(0xFF7c7c7c),
                      selectedItemColor: Color(0xFF4E8C6F),
                      backgroundColor: Color.fromARGB(255, 240, 255, 244),
                      type: BottomNavigationBarType.fixed,
                      selectedLabelStyle:
                          const TextStyle(fontWeight: FontWeight.bold),
                      showUnselectedLabels: true,
                      currentIndex: selectedIndex,
                      onTap: onItemSelected,
                      elevation: 22,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
