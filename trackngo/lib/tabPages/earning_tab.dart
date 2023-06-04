import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:provider/provider.dart';
import 'package:trackngo/infoHandler/app_info.dart';
import 'package:trackngo/mainScreen/driver_trip_screen.dart';
import 'package:trackngo/tabPages/history_design_ui.dart';
import 'package:trackngo/tabPages/profile_tab.dart';

class EarningsTabPage extends StatefulWidget {
  @override
  State<EarningsTabPage> createState() => _EarningsTabPageState();
}

class _EarningsTabPageState extends State<EarningsTabPage> {
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
    } else if (index == 2) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => ProfileTabPage()));
    } else {
      setState(() {
        selectedIndex = index;
      });
    }
  }

  double totalFare = 0;
  void calculateTotalFare() {
    for (int i = 0;
        i <
            Provider.of<AppInfo>(context, listen: false)
                .allTripsHistoryInformationList
                .length;
        i++) {
      double fare = double.tryParse(Provider.of<AppInfo>(context, listen: false)
              .allTripsHistoryInformationList[i]
              .passengerFare!) ??
          0.0;
      totalFare += fare;
    }
    print("total fare is: " + totalFare.toString());
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    calculateTotalFare();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(top: 90),
            constraints: const BoxConstraints.expand(),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/background.png"),
                fit: BoxFit.fill,
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 0),
                  child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Earning Summary",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 20),
                          child: Neumorphic(
                            style: NeumorphicStyle(
                              boxShape: NeumorphicBoxShape.roundRect(
                                BorderRadius.circular(20),
                              ),
                              depth: 5,
                              lightSource: LightSource.topLeft,
                              color: Colors.white,
                              shadowDarkColor: Color(0xFFDFDFDF),
                              shadowLightColor: Color(0xFFDFDFDF),
                            ),
                            child: Container(
                              height: 100,
                              child: Padding(
                                padding: const EdgeInsets.all(25),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Wallet Balance",
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black,
                                          ),
                                        ),
                                        Text(
                                          "P" + totalFare.toStringAsFixed(2),
                                          style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Spacer(),
                                    ElevatedButton(
                                      onPressed: () {},
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Color(0xFF4E8C6F),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        minimumSize: Size(110, 35),
                                      ),
                                      child: Text(
                                        "WITHDRAW",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.only(left: 40, right: 30),
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
                      ListView.separated(
                        separatorBuilder: (context, i) => const Divider(),
                        itemBuilder: (context, i) {
                          return HistoryDesignUIWidget(
                            tripsHistoryModel:
                                Provider.of<AppInfo>(context, listen: false)
                                    .allTripsHistoryInformationList[i],
                            fare: totalFare,
                          );
                        },
                        itemCount: Provider.of<AppInfo>(context, listen: false)
                            .allTripsHistoryInformationList
                            .length,
                        physics: const ClampingScrollPhysics(),
                        shrinkWrap: true,
                      ),
                    ],
                  ),
                ),
              ],
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
          ),
        ],
      ),
    );
  }
}
