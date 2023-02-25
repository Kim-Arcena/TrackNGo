import 'package:flutter/material.dart';
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
    tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        physics: const NeverScrollableScrollPhysics(),
        controller: tabController, // pass tabController to TabBarView
        children: const [
          HomeTabPage(),
          EarningsTabPage(),
          RatingsTabPage(),
        ],
      ),
      bottomNavigationBar: SizedBox(
        height: 90,
        child: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.attach_money),
              label: 'Earnings',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.star),
              label: 'Ratings',
            ),
          ],
          unselectedItemColor: Color(0xFFc4c4c4),
          selectedItemColor: Color(0xFF4E8C6F), // set selected color to green
          backgroundColor: Color(0xFFF1FFF8),
          type: BottomNavigationBarType.fixed,
          showUnselectedLabels: true,
          currentIndex: selectedIndex,
          onTap: onItemClicked,
        ),
      ),
    );
  }
}
