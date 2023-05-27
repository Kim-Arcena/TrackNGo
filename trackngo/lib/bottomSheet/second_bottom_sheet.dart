import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:smooth_star_rating_null_safety/smooth_star_rating_null_safety.dart';
import 'package:trackngo/assistants/assistant_methods.dart';
import 'package:trackngo/global/global.dart';

var maxChildSize = 0.8;

class MyBottomSheetTwoContainer extends StatefulWidget {
  final void Function(int) moveToPage;
  final ScrollController scrollController;

  const MyBottomSheetTwoContainer(
      {required this.scrollController, required this.moveToPage});

  @override
  _MyBottomSheetTwoContainerState createState() =>
      _MyBottomSheetTwoContainerState();
}

class _MyBottomSheetTwoContainerState extends State<MyBottomSheetTwoContainer> {
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
                  "Select a Bus",
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
                              // Navigator.pop(context);
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
                            onPressed: () {},
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
                            color: Color(0XFF021C0F),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: TextButton(
                            onPressed: () {},
                            child: Text(
                              "3",
                              style: TextStyle(
                                color: Colors.white,
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
                            color: Color(0XFF021C0F),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: TextButton(
                            onPressed: () {},
                            child: Text(
                              "4",
                              style: TextStyle(
                                color: Colors.white,
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

  @override
  _InnerContainerState createState() => _InnerContainerState();
}

class _InnerContainerState extends State<InnerContainer> {
  bool _flag = false;
  bool _flagTwo = false;
  bool _flagThree = false;
  String? selectedImage;
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
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      "Bus Selected",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 50,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Container(
                  padding: EdgeInsetsDirectional.zero,
                  height: 130,
                  child: ListView.builder(
                    itemCount: dList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        height: 90,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedImage = 'images/commuter.png';
                              chosenDriverId = dList[index]["id"].toString();
                              userResponse = "Driver Selected";
                            });
                            widget.moveToPage(2);
                          },
                          child: Neumorphic(
                            margin: const EdgeInsets.all(5),
                            style: NeumorphicStyle(
                              boxShape: NeumorphicBoxShape.roundRect(
                                  BorderRadius.circular(20)),
                              depth: 5,
                              lightSource: LightSource.topLeft,
                              color: Colors.white,
                              shadowDarkColor:
                                  selectedImage == 'images/commuter.png'
                                      ? Color(0xFFf9dea7)
                                      : Color(0xFFDFDFDF),
                              shadowLightColor:
                                  selectedImage == 'images/commuter.png'
                                      ? Color(0xFFf9dea7)
                                      : Color(0xFFDFDFDF),
                            ),
                            child: ListTile(
                              leading: Container(
                                child: Image.asset(
                                  "images/" +
                                      dList[index]["busType"].toString() +
                                      ".png",
                                  width: 60,
                                ),
                              ),
                              title: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      AutoSizeText(
                                          dList[index]["firstName"] +
                                              " " +
                                              dList[index]["lastName"],
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        maxLines: 2,
                                        minFontSize: 12,
                                      ),
                                    ],
                                  ),
                                  AutoSizeText(dList[index]["licenseNumber"],
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black,
                                      ),
                                    maxLines: 2,
                                    minFontSize: 12,
                                  ),
                                  SmoothStarRating(
                                    rating: 3,
                                    color: Colors.yellow,
                                    borderColor: Colors.grey,
                                    allowHalfRating: true,
                                    starCount: 5,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 90,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 30.0, vertical: 10.0),
                child: Column(
                  children: [
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
                    widget.moveToPage(0);
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
                  onPressed: () {
                    if(userResponse == Null) {
                      Fluttertoast.showToast(
                          msg: "Select a Driver",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Color(0xFF7d9988),
                          textColor: Colors.white,
                          fontSize: 16.0);
                      return;
                    }
                    widget.moveToPage(2);
                  },
                  child: Text(
                    'Next',
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
        ));
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
