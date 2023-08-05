import 'package:flutter/material.dart';
import 'package:trackngo/global/global.dart';
import 'package:trackngo/mainScreen/driver_screen.dart';
import 'package:trackngo/tabPages/earning_tab.dart';

class ProfileTabPage extends StatefulWidget {
  const ProfileTabPage({super.key});

  @override
  State<ProfileTabPage> createState() => _ProfileTabPage();
}

class _ProfileTabPage extends State<ProfileTabPage> {
  TabController? tabController;
  int selectedIndex = 2;
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
          context, MaterialPageRoute(builder: (context) => MainScreen()));
    } else if (index == 1) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => EarningsTabPage()));
    } else {
      setState(() {
        selectedIndex = index;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Stack(
          children: <Widget>[
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Material(
                elevation: 0,
                child: Container(
                  height: 200,
                  child: Image.asset('images/bannerTop.png', height: 120.0),
                ),
              ),
            ),
            Positioned(
              top: 110,
              left: 0,
              right: 0,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.topCenter,
                      child: Column(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  blurRadius: 10.0,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: ClipOval(
                                child: Image.asset(
                                  'images/driver.png',
                                  width: 100.0,
                                  height: 100.0,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            onlineDriverData.firstName.toString() +
                                " " +
                                onlineDriverData.lastName
                                    .toString(), // Add the name here
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.only(left: 10, right: 30),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Earning Details",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.email_outlined,
                                  color: Color(0xFFc2c6d3),
                                  size: 25.0,
                                ),
                                SizedBox(width: 5),
                                Text(
                                  'Email',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF7f7f84),
                                  ),
                                ),
                                Spacer(),
                                Text(
                                  onlineDriverData.email.toString(),
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              ],
                            ),
                            SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(
                                  Icons.phone,
                                  color: Color(0xFFc2c6d3),
                                  size: 25.0,
                                ),
                                SizedBox(width: 5),
                                Text(
                                  'Phone',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF7f7f84),
                                  ),
                                ),
                                Spacer(),
                                Text(
                                  onlineDriverData.contactNumber.toString(),
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              ],
                            ),
                            SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(
                                  Icons.verified_user_outlined,
                                  color: Color(0xFFc2c6d3),
                                  size: 25.0,
                                ),
                                SizedBox(width: 5),
                                Text(
                                  'Driver License',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF7f7f84),
                                  ),
                                ),
                                Spacer(),
                                Text(
                                  onlineDriverData.licenseNumber.toString(),
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              ],
                            ),
                            SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(
                                  Icons.people_alt_rounded,
                                  color: Color(0xFFc2c6d3),
                                  size: 25.0,
                                ),
                                SizedBox(width: 5),
                                Text(
                                  'Operator Id',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF7f7f84),
                                  ),
                                ),
                                Spacer(),
                                Text(
                                  onlineDriverData.operatorId.toString(),
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              ],
                            ),
                            SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(
                                  Icons.directions_bus_filled_rounded,
                                  color: Color(0xFFc2c6d3),
                                  size: 25.0,
                                ),
                                SizedBox(width: 5),
                                Text(
                                  'Bus Type',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF7f7f84),
                                  ),
                                ),
                                Spacer(),
                                Text(
                                  onlineDriverData.busType.toString(),
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              ],
                            ),
                            SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(
                                  Icons.confirmation_num_outlined,
                                  color: Color(0xFFc2c6d3),
                                  size: 25.0,
                                ),
                                SizedBox(width: 5),
                                Text(
                                  'Plate Number',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF7f7f84),
                                  ),
                                ),
                                Spacer(),
                                Text(
                                  onlineDriverData.plateNumber.toString(),
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
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
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFF2D9D69),
                ),
                child: BottomNavigationBar(
                  items: [
                    BottomNavigationBarItem(
                      icon: Container(
                        height: 0,
                        child: Icon(
                          Icons.explore,
                          size: 30,
                        ),
                      ),
                      label: '',
                    ),
                    BottomNavigationBarItem(
                      icon: Container(
                        height: 0,
                        child: Icon(
                          Icons.wallet,
                          size: 30,
                        ),
                      ),
                      label: '',
                    ),
                    BottomNavigationBarItem(
                      icon: Container(
                        height: 0,
                        child: Icon(
                          Icons.person,
                          size: 30,
                        ),
                      ),
                      label: '',
                    ),
                  ],
                  unselectedItemColor: Color(0xFFe3efe7),
                  selectedItemColor: Colors.white,
                  backgroundColor: Color(0xFF2D9D69),
                  type: BottomNavigationBarType.fixed,
                  selectedLabelStyle:
                      const TextStyle(fontWeight: FontWeight.bold),
                  showUnselectedLabels: true,
                  currentIndex: selectedIndex,
                  onTap: onItemSelected,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
