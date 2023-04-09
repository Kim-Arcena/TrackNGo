import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:trackngo/assistants/request_assistant.dart';

import '../global/map_key.dart';

class SearchPlacesScreen extends StatefulWidget {
  const SearchPlacesScreen({super.key});

  @override
  State<SearchPlacesScreen> createState() => _SearchPlacesScreenState();
}

class _SearchPlacesScreenState extends State<SearchPlacesScreen> {
  void findPlaceAutoCompleteSearch(String inputText) async {
    if (inputText.length > 1) {
      String urlAutoCompleteSearch =
          "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$inputText&key=$mapKey&components=country:PH";
      var responseAutoCompleteSearch =
          await RequestAssistant.receiveRequest(urlAutoCompleteSearch);

      if (responseAutoCompleteSearch == "Error Occurred") {
        return;
      }
      print("this is the response: $responseAutoCompleteSearch");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color(0xffd4dbdd),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(top: 40, left: 20),
                            child: const Icon(
                              Icons.arrow_back,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Center(
                          child: Container(
                            margin: const EdgeInsets.only(top: 40),
                            child: const Text(
                              "Search Drop Off",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.search,
                            color: Colors.black,
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: TextField(
                              onChanged: (valueTyped) {
                                findPlaceAutoCompleteSearch(valueTyped);
                              },
                              decoration: const InputDecoration(
                                hintText: "Search Drop Off",
                                hintStyle: TextStyle(
                                  color: Colors.black,
                                ),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
