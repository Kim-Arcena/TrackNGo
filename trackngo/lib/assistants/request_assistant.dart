import 'dart:convert';

import 'package:http/http.dart' as http;

class RequestAssistant {
  static Future<dynamic> receiveRequest(String url) async {
    http.Response response = await http.get(Uri.parse(url));

    try {
      if (response.statusCode == 200) {
        String responseData = response.body;

        var decodedData = jsonDecode(responseData);
        return decodedData;
      } else {
        return "Error Occurred,  Status Code: ${response.statusCode}";
      }
    } catch (e) {
      return "Error Occurred";
    }
  }
}
