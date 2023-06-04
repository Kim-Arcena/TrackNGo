import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:trackngo/models/trip_history_model.dart';

// ignore: must_be_immutable
class HistoryDesignUIWidget extends StatefulWidget {
  TripsHistoryModel? tripsHistoryModel;

  HistoryDesignUIWidget({this.tripsHistoryModel});

  @override
  State<HistoryDesignUIWidget> createState() => _HistoryDesignUIWidgetState();
}

class _HistoryDesignUIWidgetState extends State<HistoryDesignUIWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 0),
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
            height: 90,
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: Align(
                alignment: Alignment.center,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AutoSizeText(
                          widget.tripsHistoryModel!.userFirstName! +
                              " " +
                              widget.tripsHistoryModel!.userLastName!,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          maxLines: 3,
                          minFontSize: 10,
                          maxFontSize: 12,
                        ),
                        SizedBox(height: 5),
                        AutoSizeText(
                          widget.tripsHistoryModel!.userContactNumber!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black,
                          ),
                          maxLines: 3,
                          minFontSize: 10,
                          maxFontSize: 12,
                        ),
                      ],
                    ),
                    Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AutoSizeText(
                          "P " + widget.tripsHistoryModel!.passengerFare!,
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          maxLines: 3,
                          minFontSize: 10,
                          maxFontSize: 21,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
