import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:trackngo/assistants/assistant_methods.dart';
import 'package:trackngo/global/global.dart';
import 'package:trackngo/models/choosen_driver_information.dart';

var maxChildSize = 0.8;

class MyBottomSheetFourContainer extends StatefulWidget {
  final void Function(int) moveToPage;
  final ScrollController scrollController;

  const MyBottomSheetFourContainer(
      {required this.scrollController, required this.moveToPage});

  @override
  _MyBottomSheetFourContainerState createState() =>
      _MyBottomSheetFourContainerState();
}

class _MyBottomSheetFourContainerState
    extends State<MyBottomSheetFourContainer> {
  moveToPage(int page) {
    widget.moveToPage(page);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0XFF358855),
            Color(0XFF247D47),
            Color(0XFF1C9B4E),
            Color(0XFF358855),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: ListView(
        padding: EdgeInsets.zero,
        controller: widget.scrollController,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(
                left: 40.0, top: 40.0, right: 40, bottom: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Ride Confirmation",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 30,
                ),
                Container(
                  child: CustomPaint(
                    painter: DottedLinePainter(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 40.0,
                          height: 40.0,
                          decoration: BoxDecoration(
                            color: Color(0XFFDFF1E9),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: TextButton(
                            onPressed: () {
                              widget.moveToPage(0);
                            },
                            child: Text(
                              "1",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: 40.0,
                          height: 40.0,
                          decoration: BoxDecoration(
                            color: Color(0XFFDFF1E9),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: TextButton(
                            onPressed: () {
                              widget.moveToPage(1);
                            },
                            child: Text(
                              "2",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: 40.0,
                          height: 40.0,
                          decoration: BoxDecoration(
                            color: Color(0XFFDFF1E9),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: TextButton(
                            onPressed: () {
                              widget.moveToPage(2);
                            },
                            child: Text(
                              "3",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: 40.0,
                          height: 40.0,
                          decoration: BoxDecoration(
                            color: Color(0XFFDFF1E9),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: TextButton(
                            onPressed: () {},
                            child: Text(
                              "4",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 30,
          ),
          //add another container box here
          InnerContainer(moveToPage),
        ],
      ),
    );
  }
}

class InnerContainer extends StatefulWidget {
  final void Function(int page) moveToPage;

  InnerContainer(this.moveToPage);
  // use this
  @override
  _InnerContainerState createState() => _InnerContainerState();
}

class _InnerContainerState extends State<InnerContainer> {
  bool _flag = false;
  bool _flagTwo = false;
  bool _flagThree = false;
  String? selectedImage;

  @override
  void initState() {
    // TODO: implement initState
    getChosenDriverInformation();
  }

  getChosenDriverInformation() async {
    print(chosenDriverId!);
    DatabaseReference usersRef =
        await FirebaseDatabase.instance.ref().child("driver");
    usersRef.child(chosenDriverId!).once().then((snap) {
      chosenDriverInformation ??= ChosenDriverInformation();
      chosenDriverInformation?.driverFirstName =
          (snap.snapshot.value as Map)["firstName"];
      chosenDriverInformation?.driverLastName =
          (snap.snapshot.value as Map)["lastName"];
      chosenDriverInformation?.driverContactNumber =
          (snap.snapshot.value as Map)["contactNumber"];
      chosenDriverInformation?.busNumber =
          (snap.snapshot.value as Map)["operatorId"];
      chosenDriverInformation?.driverContactNumber =
          (snap.snapshot.value as Map)["contactNumber"];
      chosenDriverInformation?.busType =
          (snap.snapshot.value as Map)["busType"];
    });
    print(chosenDriverInformation?.busNumber ?? "No driver found");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: maxChildSize * MediaQuery.of(context).size.height * 0.735,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            top: 0,
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                              fit: BoxFit.fill,
                              image: AssetImage('images/driver.png')
                          ),
                          boxShadow: [
                            BoxShadow(
                              offset: Offset(0, 1),
                              blurRadius: 5,
                              color: Colors.black.withOpacity(0.2),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 30,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          AutoSizeText(
                            '${chosenDriverInformation?.driverFirstName ?? ''} ${chosenDriverInformation?.driverLastName ?? ''}',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            minFontSize: 10,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Positioned(
            top: 115,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          AutoSizeText(
                            chosenDriverInformation?.busNumber ?? '',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            minFontSize: 10,
                          ),
                          AutoSizeText(
                            chosenDriverInformation?.driverContactNumber ?? '',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            minFontSize: 10,
                          ),
                        ],
                      ),
                    ],
                  ),
                  AutoSizeText(
                    chosenDriverInformation?.busType ?? '',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    minFontSize: 10,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 170,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.only(top: 20, left: 40, right: 40),
              child: Column(
                children: <Widget>[
                  Divider(
                      height: 40.0, thickness: 2.0, color: Color(0xFF929895)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Row(
                        children: [
                          Icon(
                            Icons.map_outlined,
                            color: Color(0xFF282828),
                            size: 25.0,
                          ),
                          AutoSizeText(
                            tripDrirectionDetailsInfo != null
                                ? tripDrirectionDetailsInfo!.distance_text!
                                : "",
                            style: TextStyle(
                                fontSize: 13.0,
                                color: Color(0xFF282828),
                                fontWeight: FontWeight.bold),
                            minFontSize: 10,
                            maxLines: 1,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.watch_later_outlined,
                            color: Color(0xFF282828),
                            size: 25.0,
                          ),
                          AutoSizeText(
                            tripDrirectionDetailsInfo != null
                                ? tripDrirectionDetailsInfo!.duration_text!
                                : "",
                            style: TextStyle(
                                fontSize: 13.0,
                                color: Color(0xFF282828),
                                fontWeight: FontWeight.bold),
                            minFontSize: 10,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.account_balance_wallet_outlined,
                        color: Color(0xFF282828),
                        size: 25.0,
                      ),
                      AutoSizeText(
                        "Php " +
                            AssistantMethods
                                .calculateFairAmountFromOriginToDestination(
                                tripDrirectionDetailsInfo!)
                                .toString(),
                        style: TextStyle(
                            fontSize: 13.0,
                            color: Color(0xFF282828),
                            fontWeight: FontWeight.bold),
                        minFontSize: 10,
                        maxLines: 1,
                      ),
                    ],
                  ),
                  Divider(
                      height: 40.0, thickness: 2.0, color: Color(0xFF929895)),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 40,
            child: Container(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: () {
                  widget.moveToPage(2);
                },
                child: Center(
                  child: Icon(
                    Icons.arrow_drop_up_sharp,
                    color: Colors.black,
                    size: 30,
                  ),
                ),
                style: ButtonStyle(
                  minimumSize: MaterialStateProperty.all<Size>(Size(45, 45)),
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Color(0xFFDAD9E2)),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 1,
          ),
          Positioned(
            bottom: 40,
            right: 40,
            child: Container(
              child: ElevatedButton(
                onPressed: () {},
                child: Text(
                  'Book',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  primary: Color(0xFF53906B),
                  minimumSize: Size(200, 45),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
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

class DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Color(0xFF021C0F)
      ..strokeWidth = 2.7
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true
      ..strokeJoin = StrokeJoin.round;

    double dashWidth = 4;
    double dashSpace = 5;
    double startY = size.height / 2;
    double endY = size.height / 2;
    double currentX = 0;

    while (currentX < size.width) {
      canvas.drawLine(
        Offset(currentX, startY),
        Offset(currentX + dashWidth, endY),
        paint,
      );
      currentX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
